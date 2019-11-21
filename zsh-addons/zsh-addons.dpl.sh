#:title:        Divine deployment: zsh-addons
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.11.21
#:revremark:    Update to D.d v2.2 API
#:created_at:   2019.10.28

D_DPL_NAME='zsh-addons'
D_DPL_DESC='Useful community plugins for zsh'
D_DPL_PRIORITY=1000
D_DPL_FLAGS=
D_DPL_WARNING=
D_DPL_OS=( any )

D_QUEUE_MAIN=( \
  'zsh-users/zsh-completions' \
  'zsh-users/zsh-syntax-highlighting' \
  'zsh-users/zsh-autosuggestions' \
)
d__queue_target "$HOME/.zsh"

d_dpl_check()   { d__gh_queue_check;    }
d_dpl_install() { d__gh_queue_install;  }
d_dpl_remove()  { d__gh_queue_remove;   }