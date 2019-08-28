#:title:        Divine deployment: fonts
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    13
#:revdate:      2019.08.28
#:revremark:    Update to new queue API
#:created_at:   2019.06.30

D_DPL_NAME='fonts'
D_DPL_DESC='Personal collection of hard-to-come-by font faces'
D_DPL_PRIORITY=4096
D_DPL_FLAGS=
D_DPL_WARNING=

# Destinations for font files
D_DPL_TARGET_DIR_MACOS="$HOME/Library/Fonts"
D_DPL_TARGET_DIR_UBUNTU='/usr/share/fonts'

# Delegate to built-in helpers
d_dpl_check()   { assemble_tasks; d__multitask_check;   }
d_dpl_install() {                 d__multitask_install; }
d_dpl_remove()  {                 d__multitask_remove;  }

# Assemble multitask names
assemble_tasks() { D_MULTITASK_NAMES=( ttf otf ); }

# Delegate to built-in helpers for *.ttf fonts
d_ttf_check()   { d__copy_queue_check;    }
d_ttf_install() { d__copy_queue_install;  }
d_ttf_remove()  { d__copy_queue_remove;   }

# Delegate to built-in helpers for *.otf fonts
d_otf_check()   { tweak_target_dir; d__copy_queue_check;    }
d_otf_install() {                   d__copy_queue_install;  }
d_otf_remove()  {                   d__copy_queue_remove;   }

tweak_target_dir()
{
  # On Ubuntu, install *.otf fonts into 'opentype' sub-directory
  [ "$D__OS_DISTRO" = ubuntu ] && D_DPL_TARGET_DIR+="/opentype"
}