#:title:        Divine deployment: home-dirs
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D_DPL_NAME='home-dirs'
D_DPL_DESC='Commonly used directories within home directory'
D_DPL_PRIORITY=500
D_DPL_FLAGS=
D_DPL_WARNING=

# Where to grab main queue file
D_DPL_QUE_PATH="$D_DPL_ASSETS_DIR/home-dirs.cfg"

dcheck()    { __queue_hlp__dcheck;    }
dinstall()  { __queue_hlp__dinstall;  }
dremove()   { __queue_hlp__dremove;   }

## Exit codes and their meaning:
#.  0 - Unknown
#.  1 - Installed
#.  2 - Not installed
#.  3 - Invalid
__d__queue_hlp__item_is_installed()
{
  # Compose directory path
  local dir="$HOME/$D_DPL_ITEM_TITLE"

  # Check if directory exists
  if [ -d "$dir" ]; then

    # Directory exists

    # Check if in removal routine
    if [ "$D_REQ_ROUTINE" = remove ]; then

      # Check if directory contains anything
      if [ -n "$( ls -A -- "$dir" )" ]; then

        # Set up another user prompt
        D_ANOTHER_PROMPT=true
        D_ANOTHER_WARNING='At least one of the directories is not empty'

      fi

    fi

    # Return appropriate status
    return 1

  else

    # Not a directory: report and return mindful of path’s existence
    if [ -e "$dir" ]; then
      dprint_debug "Not a directory: $dir"
      return 3
    else
      return 2
    fi

  fi
}

## Exit codes and their meaning:
#.  0 - Successfully installed
#.  1 - Failed to install
#.  2 - Invalid item
#.  3 - Success: stop any further installations
#.  4 - Failure: stop any further installations
__d__queue_hlp__install_item()
{
  # Compose directory path
  local dir="$HOME/$D_DPL_ITEM_TITLE"

  # Make directory and check result
  if mkdir -p -m 0700 -- "$dir" &>/dev/null; then

    # Return success
    return 0

  else

    # Report and return failure
    dprint_debug "Failed to create directory at: $dir"
    return 1

  fi
}

## Exit codes and their meaning:
#.  0 - Successfully removed
#.  1 - Failed to remove
#.  2 - Invalid item
#.  3 - Success: stop any further removals
#.  4 - Failure: stop any further removals
__d__queue_hlp__remove_item()
{
  # Compose directory path
  local dir="$HOME/$D_DPL_ITEM_TITLE"

  # Check if directory is already non-existent
  if ! [ -e "$dir" ]; then
    # Already removed: report success
    dprint_skip -l 'Already removed      :' "$dir"
    return 0
  fi

  # Check if directory is empty
  if [ -n "$( ls -A -- "$dir" )" ]; then

    # Directory is not empty: prompt for directory removal
    dprompt_key -b --color "$RED" --prompt 'Erase?' --or-quit -- \
      "This will ${BOLD}completely erase${NORMAL} non-empty directory at:" \
      -i "${BOLD}${RED}${REVERSE} ${dir} ${NORMAL}"

  else

    # Directory is empty: remove without asking
    :

  fi

  # Check user’s answer
  case $? in
    0)  # Remove directory
        if rm -rf -- "$dir"; then
          dprint_success -l 'Successfully removed :' "$dir"
          return 0
        else
          dprint_failure -l 'Failed to remove     :' "$dir"
          return 1
        fi
        ;;
    1)  # Skip removing directory
        dprint_skip -l 'Skipped removing     :' "$dir"
        return 1
        ;;
    2)  # Stop entire process
        dprint_skip -l 'Aborting removal of directories'
        return 4
        ;;
    *)  # Invalid code
        return 2
        ;;
  esac
}