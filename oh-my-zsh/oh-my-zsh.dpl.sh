#:title:        Divine deployment: oh-my-zsh
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.24
#:revremark:    Rewrite for D.d v2
#:created_at:   2019.06.30

D_DPL_NAME='oh-my-zsh'
D_DPL_DESC='Your terminal never felt this good before'
D_DPL_PRIORITY=3333
D_DPL_FLAGS=
D_DPL_WARNING=

D_OMZ_PATH="$HOME/.oh-my-zsh"
D_OMZ_REPO='robbyrussell/oh-my-zsh'

d_dpl_check()   { assemble_tasks; d__mltsk_check;   }
d_dpl_install() {                 d__mltsk_install; }
d_dpl_remove()  {                 d__mltsk_remove;  }

d_omz_fmwk_check()      { d__gh_queue_check;      }
d_omz_fmwk_install()    { d__gh_queue_install;    }
d_omz_fmwk_remove()     { d__gh_queue_remove;     }

d_omz_assets_check()    { d__link_queue_check;    }
d_omz_assets_install()  { d__link_queue_install;  }
d_omz_assets_remove()   { d__link_queue_remove;   }

d_omz_fmwk_post_install()
{ (($D__TASK_CHECK_CODE)) && D_ADDST_MLTSK_HALT=true; }

assemble_tasks()
{
  # Assemble multitask deployment
  D_MLTSK_MAIN=( 'omz_fmwk' 'omz_assets' )

  # Assemble Github queue for retrieving Bash-it repo
  D_QUEUE_MAIN=("$D_OMZ_REPO")
  D_DPL_ASSET_PATHS=('')
  D_DPL_TARGET_PATHS=("$D_OMZ_PATH")

  # Split queue; assemble link queue for implanting custom assets
  d__queue_split; assemble_asset_queue
}

assemble_asset_queue()
{
  # Init storage variables; enable 'dotglob' and 'nullglob' options
  local tgtp astp tgtap=() astap=() astarp=()
  $D__ENABLE_DOTGLOB; $D__ENABLE_NULLGLOB

  # Assemble themes
  for astp in "$D__DPL_ASSET_DIR/themes/"*.zsh-theme; do
    [ -f "$astp" ] || continue
    tgtp="$D_OMZ_PATH/custom/themes/$( basename -- "$astp" )"
    tgtap+=( "$tgtp" ) astap+=( "$astp" )
    astarp+=("${astp#"$D__DPL_ASSET_DIR/"}")
  done

  # Assemble plugins
  for astp in "$D__DPL_ASSET_DIR/plugins/"*/*.plugin.zsh; do
    astp="$( dirname -- "$astp" )"; [ -d "$astp" ] || continue
    tgtp="$D_OMZ_PATH/custom/plugins/$( basename -- "$astp" )"
    tgtap+=( "$tgtp" ) astap+=( "$astp" )
    astarp+=("${astp#"$D__DPL_ASSET_DIR/"}")
  done

  $D__RESTORE_DOTGLOB; $D__RESTORE_NULLGLOB
  D_QUEUE_MAIN+=("${astarp[@]}")
  D_DPL_ASSET_PATHS+=("${astap[@]}")
  D_DPL_TARGET_PATHS+=("${tgtap[@]}")
}