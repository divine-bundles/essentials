#:title:        Divine deployment: home-dirs
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.12.03
#:revremark:    Make home-dirs use stash
#:created_at:   2019.06.30

D_DPL_NAME='home-dirs'
D_DPL_DESC='Commonly used directories within home directory'
D_DPL_PRIORITY=500
D_DPL_FLAGS=
D_DPL_WARNING=
D_DPL_OS=( any )

D_ADDST_QUEUE_MNF_PATH="$D__DPL_ASSET_DIR/home-dirs.cfg"

d_dpl_check()    { d__queue_check;    }
d_dpl_install()  { d__queue_install;  }
d_dpl_remove()   { d__queue_remove;   }

d_queue_pre_check()
{
  # Ensure stash is available
  d__stash -- ready || return 3
}

d_item_check()
{
  # Compose directory path; perform check
  local hdr="$HOME/$D__ITEM_NAME"
  if [ -d "$hdr" ]; then
    if [ "$D__REQ_ROUTINE" = remove -a -n "$( ls -Aq -- "$hdr" 2>/dev/null )" ]
    then
      D_ADDST_PROMPT=true
      D_ADDST_WARNING+=("Directory not empty: $D__ITEM_NAME")
    fi
    d__stash -s -- has "$D__ITEM_NAME" && return 1 || return 7
  elif [ -e "$hdr" ]; then
    [ "$D__REQ_ROUTINE" = remove ] && D_ADDST_PROMPT=true
    D_ADDST_ATTENTION+=("Existing non-directory: $hdr")
    return 3
  else
    d__stash -s -- has "$D__ITEM_NAME" && return 6 || return 2
  fi
}

d_item_install()
{
  # Compose directory path; make directory
  local hdr="$HOME/$D__ITEM_NAME"
  if mkdir -p -m 0700 -- "$hdr" &>/dev/null; then
    if ! d__stash -s -- set "$D__ITEM_NAME"; then
      d__notify -lx -- \
        "Failed to set stash record for directory: $D__ITEM_NAME"
    fi
    return 0
  else
    d__notify -lx -- "Failed to create directory: $hdr"
    return 1
  fi
}

d_item_remove()
{
  # Compose directory path
  local hdr="$HOME/$D__ITEM_NAME"

  # If not empty, prompt user
  if [ -n "$( ls -Aq -- "$hdr" 2>/dev/null )" ]; then
    d__prompt -xqp 'Erase?' -- \
      "This will ${BOLD}completely erase$NORMAL non-empty directory at:" \
      -i- "$BOLD$RED$REVERSE $hdr $NORMAL"
    case $? in
      1)  return 2;;
      2)  D_ADDST_QUEUE_HALT=true
          return 2
          ;;
      *)  :;;
    esac
  fi

  # Proceed to removal
  if rm -rf -- "$hdr" &>/dev/null; then
    if ! d__stash -s -- unset "$D__ITEM_NAME"; then
      d__notify -lx -- \
        "Failed to unset stash record for directory: $D__ITEM_NAME"
    fi
    return 0
  else
    return 1
  fi
}