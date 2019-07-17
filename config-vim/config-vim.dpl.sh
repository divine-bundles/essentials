#:title:        Divine deployment: config-vim
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D__DPL_NAME='config-vim'
D__DPL_DESC='Vim - configuration and startup commands'
D__DPL_PRIORITY=333
D__DPL_FLAGS=
D__DPL_WARNING=

D__DPL_TARGET_DIR="$HOME"

# Delegate to built-in helpers
d_dpl_check()    { d__link_queue_check;    }
d_dpl_install()  { d__link_queue_install;  }
d_dpl_remove()   { d__link_queue_remove;   }