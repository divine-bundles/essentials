#:title:        Divine deployment: config-shell
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.11.29
#:revremark:    Revert config-shell to keeping base runcoms in asset dir
#:created_at:   2019.06.30

D_DPL_NAME='config-shell'
D_DPL_DESC='Startup commands for common shells (Bash, zsh)'
D_DPL_PRIORITY=333
D_DPL_FLAGS=
D_DPL_WARNING=
D_DPL_OS=( any )

d_dpl_check()   { assemble_tasks; d__mltsk_check;   }
d_dpl_install() {                 d__mltsk_install; }
d_dpl_remove()  {                 d__mltsk_remove;  }

assemble_tasks()
{
  # Assemble multitask deployment
  D_MLTSK_MAIN=( 'blanks' 'runcoms' 'env_vars' )

  # Auto-target the asset queue
  d__queue_target "$HOME"

  # Manually add a second queue section
  d__queue_split
  D_QUEUE_MAIN+=( \
    '.runcoms' \
    'base/.bash_profile' \
    'base/.bashrc' \
    'base/.zprofile' \
    'base/.zshrc' \
  )
  D_QUEUE_ASSETS+=( \
    "$D__DPL_ASSET_DIR" \
    "$D__DPL_ASSET_DIR/base/.bash_profile" \
    "$D__DPL_ASSET_DIR/base/.bashrc" \
    "$D__DPL_ASSET_DIR/base/.zprofile" \
    "$D__DPL_ASSET_DIR/base/.zshrc" \
  )
  D_QUEUE_TARGETS+=( \
    "$HOME/.runcoms" \
    "$HOME/.bash_profile" \
    "$HOME/.bashrc" \
    "$HOME/.zprofile" \
    "$HOME/.zshrc" \
  )
}

d_blanks_check()    { d__copy_queue_check;    }
d_blanks_install()  { d__copy_queue_install;  }
d_blanks_remove()   { d__copy_queue_remove;   }

d_runcoms_check()   { d__link_queue_check;    }
d_runcoms_install() { d__link_queue_install;  }
d_runcoms_remove()  { d__link_queue_remove;   }

d_env_vars_pre_check()
{
  D_INJECT_SRC="$(mktemp)"
  D_INJECT_TGT="$HOME/.pre.sh"
  D_INJECT_CMT='#'
  printf >>$D_INJECT_SRC '%s\n' "export D__OS_FAMILY='$D__OS_FAMILY'"
  printf >>$D_INJECT_SRC '%s\n' "export D__OS_DISTRO='$D__OS_DISTRO'"
  printf >>$D_INJECT_SRC '%s\n' "export D__OS_PKGMGR='$D__OS_PKGMGR'"
  return 0
}

d_env_vars_post_install() { rm -f -- $D_INJECT_SRC; return 0; }
d_env_vars_post_remove()  { rm -f -- $D_INJECT_SRC; return 0; }

d_env_vars_check()    { d__inject_check;    }
d_env_vars_install()  { d__inject_install;  }
d_env_vars_remove()   { d__inject_remove;   }