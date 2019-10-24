#:title:        Divine deployment: config-shell
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.24
#:revremark:    Print into env file instead of stdout
#:created_at:   2019.06.30

D_DPL_NAME='config-shell'
D_DPL_DESC='Startup commands for common shells (Bash, zsh)'
D_DPL_PRIORITY=333
D_DPL_FLAGS=
D_DPL_WARNING=

D_DPL_TARGET_DIR="$HOME"
D_ENV_FLP="$HOME/.env.sh"
D_ENV_VNM=( 'D__OS_FAMILY' 'D__OS_DISTRO' 'D__OS_PKGMGR' )
D_ENV_VVL=( "$D__OS_FAMILY" "$D__OS_DISTRO" "$D__OS_PKGMGR" )

d_dpl_check()   { assemble_tasks; d__mltsk_check;   }
d_dpl_install() {                 d__mltsk_install; }
d_dpl_remove()  {                 d__mltsk_remove;  }

assemble_tasks() { D_MLTSK_MAIN=( 'runcoms' 'blanks' 'env_vars' ); }

d_runcoms_check()   { d__link_queue_check;    }
d_runcoms_install() { d__link_queue_install;  }
d_runcoms_remove()  { d__link_queue_remove;   }

d_blanks_check()    { d__copy_queue_check;    }
d_blanks_install()  { d__copy_queue_install;  }
d_blanks_remove()   { d__copy_queue_remove;   }

d_env_vars_check()
{
  # Check if env file exists; init storate variables
  if [ -f "$D_ENV_FLP" ]
  then d__notify -nq -- "Reading env file: $D_ENV_FLP"
  else d__notify -nq -- "Missing env file: $D_ENV_FLP"; return 2; fi
  local cnm=0 vnm vvl ii

  # Check each variable presence in env file
  for ((ii=0;ii<${#D_ENV_VNM[@]};++ii)); do
    vnm="${D_ENV_VNM[$ii]}" vvl="${D_ENV_VVL[$ii]}"
    if grep -q "^[[:space:]]*export $vnm='$vvl'" "$D_ENV_FLP" 2>/dev/null
    then ((++cnm))
      d__notify -q -- "Installed        : $vnm variable definition"
    else
      d__notify -q -- "Not installed    : $vnm variable definition"
    fi
  done

  # Report based on number of chunks installed
  if (($cnm)); then [ $cnm -eq 3 ] && return 1 || return 4; else return 2; fi
}

d_env_vars_install()
{
  # Announce start; init storage variables
  d__notify -nq -- "Installing env file: $D_ENV_FLP"
  local ii etm="$(mktemp)" lbf

  # Copy env file, but without possibly previously installed lines
  while read -r lbf; do
    if [[ $lbf = 'export D__OS_'* ]]; then
      for ((ii=0;ii<${#D_ENV_VNM[@]};++ii)); do
        [ "$lbf" = "export ${D_ENV_VNM[$ii]}='${D_ENV_VVL[$ii]}'" ] \
          && continue 2
      done
    fi
    printf '%s\n' "$lbf"
  done <"$D_ENV_FLP" >$etm

  # Now, append the assignments at the bottom
  for ((ii=0;ii<${#D_ENV_VNM[@]};++ii))
  do printf '%s\n' "export ${D_ENV_VNM[$ii]}='${D_ENV_VVL[$ii]}'" >>$etm; done

  # Move temp file into place
  if mv -f -- $etm "$D_ENV_FLP" &>/dev/null; then return 0
  else
    d__notify -lx -- "Failed to move temp file into place: $D_ENV_FLP"
    rm -f -- $etm; return 1
  fi
}

d_env_vars_remove()
{
  # Announce start; init storage variables
  d__notify -nq -- "Cleaning env file: $D_ENV_FLP"
  local ii etm="$(mktemp)" lbf

  # Copy env file, but without possibly previously installed lines
  while read -r lbf; do
    if [[ $lbf = 'export D__OS_'* ]]; then
      for ((ii=0;ii<${#D_ENV_VNM[@]};++ii)); do
        [ "$lbf" = "export ${D_ENV_VNM[$ii]}='${D_ENV_VVL[$ii]}'" ] \
          && continue 2
      done
    fi
    printf '%s\n' "$lbf"
  done <"$D_ENV_FLP" >$etm

  # Move temp file into place
  if mv -f -- $etm "$D_ENV_FLP" &>/dev/null; then return 0
  else
    d__notify -lx -- "Failed to move temp file into place: $D_ENV_FLP"
    rm -f -- $etm; return 1
  fi
}