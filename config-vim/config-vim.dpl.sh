#:title:        Divine deployment: config-vim
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D_DPL_NAME='config-vim'
D_DPL_DESC='Vim - configuration and startup commands'
D_DPL_PRIORITY=333
D_DPL_FLAGS=
D_DPL_WARNING=

D_DPL_DIR+='/configs'
D_DPL_TARGET_DIR="$HOME"

# Delegate to built-in helpers
dcheck()    { __dln_hlp__dcheck;    }
dinstall()  { __dln_hlp__dinstall;  }
dremove()   { __dln_hlp__dremove;   }