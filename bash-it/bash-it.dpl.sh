#:title:        Divine deployment: bash-it
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.26
#:revremark:    Always return zero from hooks
#:created_at:   2019.06.30

D_DPL_NAME='bash-it'
D_DPL_DESC='A community Bash framework'
D_DPL_PRIORITY=3333
D_DPL_FLAGS=
D_DPL_WARNING=

D_BASH_IT_PATH="$HOME/.bash-it"
D_BASH_IT_REPO='Bash-it/bash-it'

d_dpl_check()   { assemble_tasks; d__mltsk_check;   }
d_dpl_install() {                 d__mltsk_install; }
d_dpl_remove()  {                 d__mltsk_remove;  }

d_bash_it_fmwk_check()      { d__gh_queue_check;      }
d_bash_it_fmwk_install()    { d__gh_queue_install;    }
d_bash_it_fmwk_remove()     { d__gh_queue_remove;     }

d_bash_it_assets_check()    { d__link_queue_check;    }
d_bash_it_assets_install()  { d__link_queue_install;  }
d_bash_it_assets_remove()   { d__link_queue_remove;   }

d_bash_it_fmwk_post_install()
{ (($D__TASK_INSTALL_CODE)) && D_ADDST_MLTSK_HALT=true; return 0; }

assemble_tasks()
{
  # Assemble multitask deployment
  D_MLTSK_MAIN=( 'bash_it_fmwk' 'bash_it_assets' )

  # Assemble Github queue for retrieving Bash-it repo
  D_QUEUE_MAIN=("$D_BASH_IT_REPO")
  D_DPL_ASSET_PATHS=('')
  D_DPL_TARGET_PATHS=("$D_BASH_IT_PATH")

  # Split queue; assemble link queue for implanting custom assets
  d__queue_split; assemble_asset_queue
}

assemble_asset_queue()
{
  # Init storage variables; enable 'dotglob' and 'nullglob' options
  local tgtp astp tgtap=() astap=() astarp=()
  $D__ENABLE_DOTGLOB; $D__ENABLE_NULLGLOB

  # Assemble aliases
  for astp in "$D__DPL_ASSET_DIR/aliases/"*.aliases.bash; do
    [ -f "$astp" ] || continue
    tgtp="$D_BASH_IT_PATH/aliases/available/$( basename -- "$astp" )"
    tgtap+=("$tgtp") astap+=("$astp")
    astarp+=("${astp#"$D__DPL_ASSET_DIR/"}")
  done

  # Assemble completions
  for astp in "$D__DPL_ASSET_DIR/completion/"*.completion.bash; do
    [ -f "$astp" ] || continue
    tgtp="$D_BASH_IT_PATH/completion/available/$( basename -- "$astp" )"
    tgtap+=("$tgtp") astap+=("$astp")
    astarp+=("${astp#"$D__DPL_ASSET_DIR/"}")
  done

  # Assemble lib
  for astp in "$D__DPL_ASSET_DIR/lib/"*.bash; do
    [ -f "$astp" ] || continue
    tgtp="$D_BASH_IT_PATH/lib/$( basename -- "$astp" )"
    tgtap+=("$tgtp") astap+=("$astp")
    astarp+=("${astp#"$D__DPL_ASSET_DIR/"}")
  done

  # Assemble plugins
  for astp in "$D__DPL_ASSET_DIR/plugins/"*.plugin.bash; do
    [ -f "$astp" ] || continue
    tgtp="$D_BASH_IT_PATH/plugins/available/$( basename -- "$astp" )"
    tgtap+=("$tgtp") astap+=("$astp")
    astarp+=("${astp#"$D__DPL_ASSET_DIR/"}")
  done

  # Assemble themes
  for astp in "$D__DPL_ASSET_DIR/themes/"*/*.theme.bash; do
    astp="$( dirname -- "$astp" )"; [ -d "$astp" ] || continue
    tgtp="$D_BASH_IT_PATH/themes/$( basename -- "$astp" )"
    tgtap+=("$tgtp") astap+=("$astp")
    astarp+=("${astp#"$D__DPL_ASSET_DIR/"}")
  done

  $D__RESTORE_DOTGLOB; $D__RESTORE_NULLGLOB
  D_QUEUE_MAIN+=("${astarp[@]}")
  D_DPL_ASSET_PATHS+=("${astap[@]}")
  D_DPL_TARGET_PATHS+=("${tgtap[@]}")
}