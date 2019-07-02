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

D_RUNCOMS_DIRNAME='runcoms'
D_BLANKS_DIRNAME='blanks'
D_BLANK_RELPATHS=( \
  '.runcoms.bash' \
  '.runcoms.sh' \
  '.runcoms.zsh' \
  '.hushlogin' \
)

D_DPL_DIR+="/$D_RUNCOMS_DIRNAME"
D_DPL_TARGET_DIR="$HOME"

# Delegate to built-in checking routine
dcheck()
{
  # Task 1: primary runcom files (use dln queue)
  __dln_hlp__dcheck; __catch_dcheck_code

  # Task 2: blank runcoms and hushlogin file (use cp queue)
  __d__rc_add_blanks_to_queue
  __cp_hlp__dcheck; __catch_dcheck_code

  # Tie them all up
  __reconcile_dcheck_codes
}

# Modify built-in installation routine
dinstall()
{
  # Task 1: primary runcom files (use dln queue)
  __task_is_installable && __dln_hlp__dinstall
  __catch_dinstall_code || return $?

  # Task 2: blank runcoms and hushlogin file (use cp queue)
  __task_is_installable && __cp_hlp__dinstall
  __catch_dinstall_code || return $?

  # Tie them all up
  __reconcile_dinstall_codes
}

# Modify built-in removal routine
dremove()
{
  # Task 1: primary runcom files (use dln queue)
  __task_is_removable && __dln_hlp__dremove
  __catch_dremove_code || return $?

  # Task 2: blank runcoms and hushlogin file (use cp queue)
  __task_is_removable && __cp_hlp__dremove
  __catch_dremove_code || return $?

  # Tie them all up
  __reconcile_dremove_codes
}

__d__rc_add_blanks_to_queue()
{
  # Split queue at current length
  __split_queue

  # Compose path to directory containing blank files
  local blanks_dir="${D_DPL_DIR%"/$D_RUNCOMS_DIRNAME"}/$D_BLANKS_DIRNAME"

  # Storage variable
  local relpath

  # Add files to main queue and other arrays
  for relpath in "${D_BLANK_RELPATHS[@]}"; do
    D_DPL_QUEUE_MAIN+=( "$relpath" )
    D_DPL_ASSET_RELPATHS+=( "$relpath" )
    D_DPL_ASSET_PATHS+=( "$blanks_dir/$relpath" )
    D_DPL_TARGET_PATHS+=( "$HOME/$relpath" )
  done
}