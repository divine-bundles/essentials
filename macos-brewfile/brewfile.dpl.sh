#:title:        Divine deployment: brewfile
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    13
#:revdate:      2019.08.16
#:revremark:    dprompt_key -> dprompt
#:created_at:   2019.06.30

D_DPL_NAME='brewfile'
D_DPL_DESC='Taps, bottles, and casks from Brewfile (no upgrades)'
D_DPL_PRIORITY=3000
D_DPL_FLAGS=!
D_DPL_WARNING=

## Exit codes and their meaning:
#.  0 - Unknown
#.  1 - Installed
#.  2 - Not installed
#.  3 - Irrelevant
#.  4 - Partly installed
d_dpl_check()
{
  # Quickly check package manager
  [ "$D__OS_PKGMGR" = brew ] || {
    dprint_debug 'Brewfile is only relevant for macOS Homebrew'
    return 3
  }

  # Check if Brewfile is readable
  [ -r "$D__DPL_ASSET_DIR/Brewfile" -a -f "$D__DPL_ASSET_DIR/Brewfile" ] || {
    dprint_debug 'Failed to read Brewfile at:' -i "$D__DPL_ASSET_DIR/Brewfile"
    return 3
  }

  # Additional warnings
  case $D__REQ_ROUTINE in
    check)    dprompt -- 'Checking Brewfile is not very reliable'
              case $? in 1) return 3;; *) :;; esac
              ;;
    remove)   D_DPL_NEEDS_ANOTHER_PROMPT=true
              D_DPL_NEEDS_ANOTHER_WARNING='Uninstalling Brewfile is dangerous'
              ;;
    *)        :;;
  esac  

  # brew bundle requires Brewfile to be in current directory
  cd "$D__DPL_ASSET_DIR"

  ## Non-zero exit code of brew bundle check does not translate exactly to 
  #. 'Not installed.' It is rather 'Not fully installed or not up to date, or 
  #. maybe not installed at all, or maybe I just don't know.'
  brew bundle check --verbose && return 1 || return 0
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
  # brew bundle requires Brewfile in current directory
  cd "$D__DPL_ASSET_DIR"

  # Launch the routine
  brew bundle install --verbose --no-upgrade && return 0 || return 1
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
  ## Homebrew's bundler does not provide removal mechanism. Below code simply 
  #. reads Brewfile in reverse order and calls uninstall commands. This really 
  #. is a nuclear option, so additional user prompt is in place.
  #
  ## If any uninstallation reports failure, Divine intervention is halted 
  #. immediately, to give user chance to react.

  # Prompt user (yes, again)
  if dprompt -b --color "$RED" --prompt 'Proceed?' -- \
    'This will call uninstall/untap command on every valid entry in Brewfile' \
    -n '(File will be read in reverse order)'
  then
    # Proceed
    :
  else
    dprint_debug 'Declined to uninstall Brewfile entries'
    return 2
  fi

  # Storage variables
  local num_of_lines i
  local line name
  local all_green=true

  # Get number of lines in Brewfile
  num_of_lines=$( awk '{ print $1 }' <( wc -l "$D__DPL_ASSET_DIR/Brewfile" ) )

  # Iterate over line numbers in reverse order
  for (( i=$num_of_lines; i>0; i-- )); do

    # Extract a line from Brewfile by its number
    line="$( sed "${i}q;d" "$D__DPL_ASSET_DIR/Brewfile" )"

    # Trim line from whitespace and comments
    line=$( dtrim -h -- "$line" )

    # Extract name
    name="$( perl -pe 's/^(brew|cask|tap) \"(.+?)\".*$/\2/' <<<"$line" )"

    # Check if there is any name to process
    [ -n "$name" ] || continue

    # Check if line is a tap, cask, or a bottle
    if [[ $line == tap* ]]; then
      # Untap
      brew untap "$name" || {
        all_green=false
        $D__OPT_FORCE || break
      }
    elif [[ $line == cask* ]]; then
      # Uninstall cask
      brew cask uninstall "$name" || {
        all_green=false
        $D__OPT_FORCE || break
      }
    elif [[ $line == brew* ]]; then
      # Uninstall bottle
      brew uninstall "$name" || {
        all_green=false
        $D__OPT_FORCE || break
      }
    fi

  done

  # Report and return
  if $all_green; then
    return 0
  else
    if $D__OPT_FORCE; then
      dprint_failure 'At least one uninstallation failed'
      return 1
    else
      dprint_failure 'Latest uninstallation failed' \
        -n 'Divine intervention was halted just in case' \
        -n '(Restart with --force to ignore pathetic failures like that)'
      return 101
    fi
  fi
}