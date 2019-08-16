#:title:        Divine deployment: portable-bin
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    2
#:revdate:      2019.07.29
#:revremark:    Fix erroneous var name
#:created_at:   2019.07.26

D_DPL_NAME='portable-bin'
D_DPL_DESC='Portable collection of personal executable scripts'
D_DPL_PRIORITY=500
D_DPL_FLAGS=
D_DPL_WARNING=

d_dpl_check()    { d_assemble_link_queue; d__link_queue_check; }
d_dpl_install()  { d__link_queue_install; }
d_dpl_remove()   { d__link_queue_remove;  }

d_assemble_link_queue()
{
  # Populate essential global variables for helper functions
  D_DPL_ASSET_PATHS=( "$D__DPL_ASSET_DIR" )
  D_DPL_ASSET_RELPATHS=( '.pbin' )
  D_DPL_TARGET_PATHS=( "$HOME/.pbin" )
  D__QUEUE_MAIN=( "${D_DPL_ASSET_RELPATHS[@]}" )
}