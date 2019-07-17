#:title:        Divine deployment: dutils
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D__DPL_NAME='dutils'
D__DPL_DESC='Some of Divine utils, adapted for interactive use'
D__DPL_PRIORITY=3500
D__DPL_FLAGS=
D__DPL_WARNING=

# Make following Divine.dotfiles utilities available on $PATH
D__DPL_QUEUE_MAIN=( \
  'dln' \
  'dmv' \
  'dreadlink' \
)

# Use first available among these installation locations
D_UTIL_DESTINATION_DIR_CANDIDATES=( \
  "$HOME/bin" \
  "$HOME/.bin" \
  '/usr/local/bin' \
  '/usr/bin' \
  '/bin' \
)

d_dpl_check()    { d__queue_check;    }
d_dpl_install()  { d__queue_install;  }
d_dpl_remove()   { d__queue_remove;   }

d_queue_item_pre_check()
{
  D__DPL_ITEM_STASH_KEY="$D__DPL_ITEM_TITLE"
}

## Exit codes and their meaning:
#.  0 - Unknown
#.  1 - Installed
#.  2 - Not installed
#.  3 - Invalid
d_queue_item_is_installed()
{
  # Construct util’s name and location within framework and as installed
  local util_name="$D__DPL_ITEM_TITLE"
  local util_fmwk_path="${D__DIR_UTILS}/${util_name}${D__SUFFIX_UTIL}"
  local util_install_path="$D__DPL_ITEM_STASH_VALUE"

  # Storage variables
  local installed=true not_installed=true report_card=()

  # Start filling report card just in case
  report_card+=( "Utility '$util_name' is partially installed:" )

  # Check if installation path is recorded
  if [ -n "$util_install_path" ]; then

    # Flip flag and add to report card
    not_installed=false
    report_card+=( -n "Recorded installation path: $util_install_path" )

    # Check if installation path is an executable file
    if [ -x "$util_install_path" -a -f "$util_install_path" ]; then

      # Add to report card
      report_card+=( -n 'Installation path is an executable file' )

      # Check if file at installation path contains path to framework file
      if grep -Fq "$util_fmwk_path" "$util_install_path"; then

        # Add to report card
        report_card+=( -n \
          'File at installation path contains path to framework file' \
        )

      else

        # Flip flag and add to report card
        installed=false
        report_card+=( -n \
          'File at installation path does NOT contain path to framework file' \
        )

      fi

    else

      # Flip flag and add to report card
      installed=false
      report_card+=( -n 'Installation path is NOT an executable file' )

    fi

  else

    # Flip flag and add to report card
    installed=false
    report_card+=( -n 'Recorded installation path: [none]' )

  fi

  # Check if utility with such name is on $PATH
  if type -P "$util_name" &>/dev/null; then

    # Flip flag and add to report card
    not_installed=false
    report_card+=( -n "Utility named '$util_name' is on \$PATH" )

    # Check if command behaves like it is part of framework
    if $util_name --version 2>&1 | grep -Fq "$D__FMWK_NAME"; then

      # Add to report card
      report_card+=( -n \
        "Utility named '$util_name' is properly part of $D__FMWK_NAME" \
      )

    else

      # Flip flag and add to report card
      installed=false
      report_card+=( -n \
        "Utility named '$util_name' is NOT part of $D__FMWK_NAME" \
      )

    fi

  else

    # Flip flag and add to report card
    installed=false
    report_card+=( -n "Utility named '$util_name' is NOT on \$PATH" )

  fi

  # Report and return
  if $installed; then return 1
  elif $not_installed; then return 2
  else

    # Partially/incorrectly installed: report and mark invalid
    dprint_debug "${report_card[@]}"
    return 3

  fi
}

## Exit codes and their meaning:
#.  0 - Successfully installed
#.  1 - Failed to install
#.  2 - Invalid item
d_queue_item_install()
{
  # Construct util’s name and location within framework
  local util_name="$D__DPL_ITEM_TITLE"
  local util_fmwk_path="${D__DIR_UTILS}/${util_name}${D__SUFFIX_UTIL}"
  local util_install_dir util_install_path
  local tempfile="$( mktemp )"
  
  # Announce
  dprint_debug "Installing utility '$util_name' from:" -i "$util_fmwk_path"

  # Iterate over candidate installation directories
  for util_install_dir in "${D_UTIL_DESTINATION_DIR_CANDIDATES[@]}"; do

    # Check if shortcut directory exists and is on $PATH
    if ! [[ -d "$util_install_dir" && ":$PATH:" == *":$util_install_dir:"* ]]
    then
      dprint_debug "Skipping install directory candidate: $util_install_dir" \
        -n '(Not a directory or not on $PATH)'
      continue
    fi

    # Construct full path
    util_install_path="$util_install_dir/$util_name"

    # If file path is occupied, it is likely some namesake directory: skip
    if [ -e "$util_install_path" ]; then
      dprint_debug "Refusing to install shortcut to: $util_install_path" \
        'Path is occupied'
      continue
    fi

    # Install directory is accepteble: create utility file
    cat >"$tempfile" <<EOF
#!/usr/bin/env bash
[ -r "$util_fmwk_path" -a -f "$util_fmwk_path" ] || {
  printf >&2 '%s\n' "$util_name: Missing script file: $util_fmwk_path"
  exit -1
}
declare -f $util_name &>/dev/null && {
  printf >&2 '%s\n' "$util_name: Function already defined: $util_name"
  exit -1
}
source "$util_fmwk_path"
declare -f $util_name &>/dev/null || {
  printf >&2 '%s\n' "$util_name: Function not defined in $util_fmwk_path"
  exit -1
}
$util_name "\$@"
EOF

    # Check if succeeded
    if [ $? -ne 0 ]; then
      dprint_debug 'Failed to create temporary executable at:' -i "$tempfile"
      rm -f -- "$tempfile"
      break
    fi

    # Check if sudo is needed for installation directory
    if [ -w "$util_install_dir" ]; then
      mv -n -- "$tempfile" "$util_install_path"
    else
      if ! sudo -n true 2>/dev/null; then
        dprint_start -l \
          "Installation to $util_install_dir requires sudo password"
      fi
      sudo mv -n -- "$tempfile" "$util_install_path"
    fi

    # Check if succeeded
    if [ $? -ne 0 ]; then
      dprint_debug 'Failed to move executable from temporary location at:' \
        -i "$tempfile" -n 'to intended location at:' -i "$util_install_path"
      continue
    fi

    # Make it executable
    if ! chmod +x "$util_install_path"; then
      dprint_failure -l 'Failed to make installed script executable at:' \
        -i "$util_install_path"
      break
    fi

    # Announce success
    dprint_debug "Successfully installed utility '$util_name' to:" \
      -i "$util_install_path"
    D__DPL_ITEM_STASH_VALUE="$util_install_path"
    return 0
    
  done

  # If got here, report failure
  dprint_debug "Failed to install utility '$util_name'"
  return 1
}

## Exit codes and their meaning:
#.  0 - Successfully removed
#.  1 - Failed to remove
#.  2 - Invalid item
d_queue_item_remove()
{
  # Construct util’s name and location within framework and as installed
  local util_name="$D__DPL_ITEM_TITLE"
  local util_install_path="$D__DPL_ITEM_STASH_VALUE"
  local util_install_dir="$( dirname -- "$util_install_path" )"

  # Check if removal premission is granted for path
  if [ -w "$util_install_dir" ]; then
    rm -f -- "$util_install_path"
  else
    if ! sudo -n true 2>/dev/null; then
      dprint_start -l "Removal inside $util_install_dir requires sudo password"
    fi
    sudo rm -f -- "$util_install_path"
  fi

  # Check status
  if [ $? -eq 0 ]; then
    dprint_debug "Removed utility '$util_name' from:" \
      -i "$util_install_path"
    return 0
  else
    dprint_debug "Failed to remove utility '$util_name' from:" \
      -i "$util_install_path"
    return 1
  fi
}