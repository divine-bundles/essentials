#:title:        Divine deployment: config-git
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.11.11
#:revremark:    Rename queue arrays
#:created_at:   2019.06.30

D_DPL_NAME='config-git'
D_DPL_DESC='Git - global configuration'
D_DPL_PRIORITY=333
D_DPL_FLAGS=
D_DPL_WARNING=

D_QUEUE_TARGET_DIR="$HOME"

d_dpl_check()    { d__link_queue_check;    }
d_dpl_install()  { d__link_queue_install;  }
d_dpl_remove()   { d__link_queue_remove;   }