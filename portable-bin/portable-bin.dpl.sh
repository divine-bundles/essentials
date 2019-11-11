#:title:        Divine deployment: portable-bin
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.11.11
#:revremark:    Rename queue arrays
#:created_at:   2019.07.26

D_DPL_NAME='portable-bin'
D_DPL_DESC='Portable collection of personal executable scripts'
D_DPL_PRIORITY=500
D_DPL_FLAGS=
D_DPL_WARNING=

d_dpl_check()   { assemble_queue; d__link_queue_check;    }
d_dpl_install() {                 d__link_queue_install;  }
d_dpl_remove()  {                 d__link_queue_remove;   }

assemble_queue()
{
  D_QUEUE_MAIN=('.pbin')
  D_QUEUE_ASSETS=("$D__DPL_ASSET_DIR")
  D_QUEUE_TARGETS=("$HOME/.pbin")
}