#:title:        Divine deployment: fonts
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    11
#:revdate:      2019.08.19
#:revremark:    D__QUEUE_MAIN -> D_QUEUE_MAIN
#:created_at:   2019.06.30

D_DPL_NAME='fonts'
D_DPL_DESC='Personal collection of hard-to-come-by font faces'
D_DPL_PRIORITY=4096
D_DPL_FLAGS=
D_DPL_WARNING=

# Destinations for font files
D_DPL_TARGET_DIR_MACOS="$HOME/Library/Fonts"
D_DPL_TARGET_DIR_UBUNTU='/usr/share/fonts'

## Exit codes and their meaning:
#.  0 - Unknown
#.  1 - Installed
#.  2 - Not installed
#.  3 - Irrelevant
#.  4 - Partly installed
d_dpl_check()
{
  # Populate essential global variables for helper functions
  D_QUEUE_MAIN=()
  D_DPL_ASSET_PATHS=()
  D_DPL_ASSET_RELPATHS=()

  # Save current state of 'dotglob', 'nullglob', 'nocasematch' options
  local restore_opts cmd
  restore_opts=( \
    "$( shopt -p dotglob )" \
    "$( shopt -p nullglob )" \
    "$( shopt -p nocasematch )" \
  )

  # Set 'dotglob', 'nullglob', 'nocasematch' options
  shopt -s dotglob nullglob nocasematch

  # Scan fonts
  local font_filepath font_relpath
  for font_filepath in "$D__DPL_ASSET_DIR/"*.otf "$D__DPL_ASSET_DIR/"*.ttf; do

    # Skip symlinks (to stay consistent with 'find' behavior above)
    [ -L "$font_filepath" ] && continue

    # Skip non-files, e.g., directories (and report, since this is abnormal)
    [ ! -f "$font_filepath" ] && {
      dprint_debug 'Non-file named as a font:' -i "$font_filepath"
      continue
    }

    # Extract relpath
    font_relpath="${font_filepath#"$D__DPL_ASSET_DIR/"}"

    # Push source path
    D_QUEUE_MAIN+=( "$font_relpath" )
    D_DPL_ASSET_PATHS+=( "$font_filepath" )
    D_DPL_ASSET_RELPATHS+=( "$font_relpath" )

  done

  # Restore state of 'dotglob', 'nullglob', 'nocasematch' options
  for cmd in "${restore_opts[@]}"; do $cmd; done

  # Check if at least one path is present
  if [ ${#D_DPL_ASSET_PATHS[@]} -eq 0 ]; then
    dprint_debug 'No font files detected in assets directory at:' \
      -i "$D__DPL_ASSET_DIR"
    return 3
  fi

  # Delegate to helper function
  d__copy_queue_check
}

## Exit codes and their meaning:
#.  0   - Successfully installed
#.  1   - Failed to install
#.  2   - Skipped completely
#.  100 - Reboot needed
#.  101 - User attention needed
#.  102 - Critical failure
d_dpl_install()
{
  # Delegate to helper function
  d__copy_queue_install
}

## Exit codes and their meaning:
#.  0   - Successfully removed
#.  1   - Failed to remove
#.  2   - Skipped completely
#.  100 - Reboot needed
#.  101 - User attention needed
#.  102 - Critical failure
d_dpl_remove()
{
  # Delegate to helper function
  d__copy_queue_remove
}

d_copy_queue_pre_process()
{
  # Store current case sensitivity setting, then turn it off
  local restore_nocasematch="$( shopt -p nocasematch )"
  shopt -s nocasematch

  # For Ubuntu, modify target location of *.otf files
  if [[ $D__OS_DISTRO = ubuntu ]]; then

    # Iterate over entries in $D_DPL_TARGET_PATHS
    local i dest_filepath dest_filename
    for (( i=0; i<${#D_DPL_TARGET_PATHS[@]}; i++ )); do

      # Extract array member
      dest_filepath="${D_DPL_TARGET_PATHS[$i]}"

      # Check if *.otf file
      if [[ $dest_filepath = *.otf ]]; then

        # Extract font filename
        dest_filename="$( basename -- "$dest_filepath" )"

        # On Ubuntu, install *.otf fonts into 'opentype' sub-directory
        D_DPL_TARGET_PATHS[$i]="$D_DPL_TARGET_DIR/opentype/$dest_filename"

      fi
    
    done

  fi

  # Restore case sensitivity
  eval "$restore_nocasematch"
}