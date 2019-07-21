#:title:        Divine deployment: config-shell
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D_DPL_NAME='config-shell'
D_DPL_DESC='Startup commands for common shells (Bash, zsh)'
D_DPL_PRIORITY=333
D_DPL_FLAGS=
D_DPL_WARNING=

D_DPL_TARGET_DIR="$HOME"

D_BLANKS_DIRNAME='blanks'
D_BLANK_RELPATHS=( \
  '.runcoms.bash' \
  '.runcoms.sh' \
  '.runcoms.zsh' \
  '.hushlogin' \
)

# Delegate to built-in checking routine
d_dpl_check()
{
  # Compile task names
  D_MULTITASK_NAMES+=( runcoms )
  D_MULTITASK_NAMES+=( blanks )

  # Delegate to built-in helper
  d__multitask_check
}

# d_dpl_install and d_dpl_remove are fully delegated to built-in helpers
d_dpl_install()  {   d__multitask_install;  }
d_dpl_remove()   {   d__multitask_remove;   }

# Implement primaries for runcoms
d_runcoms_check()    { d__link_queue_check;    }
d_runcoms_install()  { d__link_queue_install;  }
d_runcoms_remove()   { d__link_queue_remove;   }

# Implement primaries for blanks
d_blanks_check()     { d_add_blanks_to_queue; d__copy_queue_check; }
d_blanks_install()   { d__copy_queue_install;   }
d_blanks_remove()    { d__copy_queue_remove;    }

# Add second chunk of the queue
d_add_blanks_to_queue()
{
  # Split queue at current length (which is number of items in manifest)
  d__queue_split

  # Compose path to directory containing blank files
  local blanks_dir="$D__DPL_DIR/$D_BLANKS_DIRNAME"

  # Storage variable
  local relpath

  # Add files to main queue and other arrays
  for relpath in "${D_BLANK_RELPATHS[@]}"; do
    D__QUEUE_MAIN+=( "$relpath" )
    D_DPL_ASSET_RELPATHS+=( "$relpath" )
    D_DPL_ASSET_PATHS+=( "$blanks_dir/$relpath" )
    D_DPL_TARGET_PATHS+=( "$D_DPL_TARGET_DIR/$relpath" )
  done
}