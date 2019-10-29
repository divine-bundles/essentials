#:title:        Divine deployment: zsh-addons
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.29
#:revremark:    Update for D.d v2
#:created_at:   2019.10.28

D_DPL_NAME='zsh-addons'
D_DPL_DESC='Useful community plugins for zsh'
D_DPL_PRIORITY=1000
D_DPL_FLAGS=
D_DPL_WARNING=

D_QUEUE_MAIN=( \
  'zsh-users/zsh-completions' \
  'zsh-users/zsh-syntax-highlighting' \
  'zsh-users/zsh-autosuggestions' \
)
D_DPL_TARGET_DIR="$HOME/.zsh"
D_RC_FP="$HOME/.runcoms.zsh"

d_dpl_check()   { assemble_tasks; d__mltsk_check;   }
d_dpl_install() {                 d__mltsk_install; }
d_dpl_remove()  {                 d__mltsk_remove;  }

assemble_tasks() { D_MLTSK_MAIN=( 'zsh_users' 'src_cmds' ); }

d_zsh_users_check()   { d__gh_queue_check;    }
d_zsh_users_install() { d__gh_queue_install;  }
d_zsh_users_remove()  { d__gh_queue_remove;   }

d_src_cmds_pre_check()
{
  D_INJECT_SRC="$(mktemp)"
  D_INJECT_TGT="$D_RC_FP"
  D_INJECT_CMT='#'
  cat <<'EOF' >$D_INJECT_SRC
fpath=($HOME/.zsh/zsh-users/zsh-completions/src $fpath)
for II in zsh-syntax-highlighting zsh-autosuggestions; do
  II="$HOME/.zsh/zsh-users/$II/$II.zsh"; [ -f "$II" ] && source "$II"
done; unset II
EOF
  return 0
}

d_src_cmds_post_install() { rm -f -- $D_INJECT_SRC; return 0; }
d_src_cmds_post_remove()  { rm -f -- $D_INJECT_SRC; return 0; }

d_src_cmds_check()    { d__inject_check;    }
d_src_cmds_install()  { d__inject_install;  }
d_src_cmds_remove()   { d__inject_remove;   }