#:title:        Divine deployment: config-shell
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D__DPL_NAME='config-shell'
D__DPL_DESC='Startup commands for common shells (Bash, zsh)'
D__DPL_PRIORITY=333
D__DPL_FLAGS=
D__DPL_WARNING=

D__DPL_TARGET_DIR="$HOME"

D_BLANKS_DIRNAME='blanks'
D_BLANK_RELPATHS=( \
  '.runcoms.bash' \
  '.runcoms.sh' \
  '.runcoms.zsh' \
  '.hushlogin' \
)

# Delegate to built-in checking routine
dcheck()
{
  # Compile task names
  D__DPL_TASK_NAMES+=( runcoms )
  D__DPL_TASK_NAMES+=( blanks )

  # Delegate to built-in helper
  __multitask_hlp__dcheck
}

# dinstall and dremove are fully delegated to built-in helpers
dinstall()  {   __multitask_hlp__dinstall;  }
dremove()   {   __multitask_hlp__dremove;   }

# Implement primaries for runcoms
d_runcoms_dcheck()    { __dln_hlp__dcheck;    }
d_runcoms_dinstall()  { __dln_hlp__dinstall;  }
d_runcoms_dremove()   { __dln_hlp__dremove;   }

# Implement primaries for blanks
d_blanks_dcheck()     { d_add_blanks_to_queue; __cp_hlp__dcheck; }
d_blanks_dinstall()   { __cp_hlp__dinstall;   }
d_blanks_dremove()    { __cp_hlp__dremove;    }

# Add second chunk of the queue
d_add_blanks_to_queue()
{
  # Split queue at current length (which is number of items in manifest)
  __split_queue

  # Compose path to directory containing blank files
  local blanks_dir="$D__DPL_DIR/$D_BLANKS_DIRNAME"

  # Storage variable
  local relpath

  # Add files to main queue and other arrays
  for relpath in "${D_BLANK_RELPATHS[@]}"; do
    D__DPL_QUEUE_MAIN+=( "$relpath" )
    D__DPL_ASSET_RELPATHS+=( "$relpath" )
    D__DPL_ASSET_PATHS+=( "$blanks_dir/$relpath" )
    D__DPL_TARGET_PATHS+=( "$D__DPL_TARGET_DIR/$relpath" )
  done
}