#:title:        Divine deployment: zsh-default
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.26
#:revremark:    Set leader task in zsh-default
#:created_at:   2019.06.30

D_DPL_NAME='zsh-default'
D_DPL_DESC='zsh as default shell'
D_DPL_PRIORITY=1333
D_DPL_FLAGS=
D_DPL_WARNING=

d_dpl_check()   { assemble_tasks; d__mltsk_check;   }
d_dpl_install() {                 d__mltsk_install; }
d_dpl_remove()  {                 d__mltsk_remove;  }

assemble_tasks()
{ D_MLTSK_MAIN=( 'etc_new' 'chsh' 'zsh_default' 'etc_old' ) D_MLTSK_LEADER=2; }

d_mltsk_pre_check()
{
  # Cut-off check; status variable
  d__stash -- ready || return 3; local algd=true

  # Extract and validate $SHELL system variable
  if ! [ -n "$SHELL" ]; then algd=false
    d__notify -l! -- '$SHELL variable is not populated' \
      '(it normally holds current default shell)'
  fi
  if [ -x "$SHELL" ]; then
    d__notify -qq -- "Current default shell detected: $SHELL"
  else algd=false
    d__notify -l! -- "Current default shell is not executable: $SHELL"
  fi

  # Extract and validate path to installed zsh
  D_ZSH_PATH="$( type -P zsh 2>/dev/null )"
  if [ -x "$D_ZSH_PATH" ]; then
    d__notify -qq -- "Using zsh at: $D_ZSH_PATH"
  else algd=false
    d__notify -l! -- 'Failed to detect zsh (must be pre-installed)'
  fi

  # Extract stash records of possible previous installation
  if d__stash -s -- has old_shell
  then D_OLD_SHELL="$( d__stash -s -- get old_shell )"; else D_OLD_SHELL=; fi
  if d__stash -s -- has new_shell
  then D_NEW_SHELL="$( d__stash -s -- get new_shell )"; else D_NEW_SHELL=; fi

  # Check consistency of records, set statuses
  D_ALREADY_ZSH=false D_SHELL_MANUALLY_CHANGED=false
  if [ -n "$D_OLD_SHELL" ]; then
    if [ -n "$D_NEW_SHELL" ]; then
      if [ "$D_OLD_SHELL" = "$D_NEW_SHELL" ]; then algd=false
        d__notify -lx -- 'Inconsistent records: old and new shells' \
          "are the same, '$D_OLD_SHELL'"
      else
        d__notify -qq -- 'Previously changed default shell:' \
          "'$D_OLD_SHELL' -> '$D_NEW_SHELL'"
        $algd && [ "$D_NEW_SHELL" != "$SHELL" ] \
          && D_SHELL_MANUALLY_CHANGED=true
      fi
    else algd=false
      d__notify -lx -- 'Inconsistent records:' \
        "old shell is recorded as '$D_OLD_SHELL', but no record of new shell"
    fi
  else
    if [ -n "$D_NEW_SHELL" ]; then algd=false
      d__notify -lx -- 'Inconsistent records:' \
        "no record of old shell, but new shell is recorded as '$D_NEW_SHELL'"
    else
      d__notify -qq -- 'No record of previous installation'
      $algd && [ "$( basename -- "$SHELL" )" = zsh ] && D_ALREADY_ZSH=true
    fi
  fi

  # Return appropriately
  $algd && return 0 || return 3
}

d_etc_new_check()
{
  # This step makes sense only when (un)installing
  case $D__REQ_ROUTINE in
    check)    return 3;;
    install)  local shp="$D_ZSH_PATH";;
    remove)   local shp="$D_NEW_SHELL";;
  esac
  if grep -Fxq "$shp" /etc/shells &>/dev/null
  then d__stash -s -- has etc_added "$shp" && return 1 || return 7
  else d__stash -s -- has etc_added "$shp" && return 6 || return 2; fi
}

d_etc_new_install()
{
  d__context -- notch
  d__context -- push "Adding shell '$D_ZSH_PATH' to /etc/shells"
  local cmd=tee; d__require_wfile /etc/shells || cmd='sudo tee'
  if ! d__cmd --sb-- $cmd -a /etc/shells <<<"$D_ZSH_PATH" \
    --else-- 'Unable to change default shell'
  then D_ADDST_MLTSK_HALT=true; return 1; fi
  d__cmd d__stash -s -- add etc_added "$D_ZSH_PATH" \
    --else-- 'Records will be inconsistent' && d__context -- lop
  return 0
}

d_etc_new_remove()
{
  d__context -- notch
  d__context -- push "Removing shell '$D_NEW_SHELL' from /etc/shells"
  local tmp="$(mktemp)" lbf; while read -r lbf; do
    [ "$lbf" = "$D_NEW_SHELL" ] || printf '%s\n' "$lbf"
  done </etc/shells >$tmp
  local cmd=mv; d__require_wfile /etc/shells || cmd='sudo mv'
  d__cmd --sb-- $cmd -f $tmp /etc/shells \
    --else-- 'zsh will remain in /etc/shells' || return 1
  d__cmd d__stash -s -- unset etc_added "$D_NEW_SHELL" \
    --else-- 'Records will be inconsistent' && d__context -- lop
  return 0
}

d_chsh_check()
{
  if [ "$D__REQ_ROUTINE" = check ] \
    && ( $D_ALREADY_ZSH || $D_SHELL_MANUALLY_CHANGED ); then return 3; fi
  if type -P -- chsh &>/dev/null
  then d__stash -s -- has chsh_installed && return 1 || return 7
  else d__stash -s -- has chsh_installed && return 6 || return 2; fi
}

d_chsh_install()
{
  d__context -- notch; d__context -- push "Auto-installing 'chsh' utility"
  d__require [ -z "$D__OS_PKGMGR" ] \
    --else-- 'Unable to auto-install without a supported package manager' \
    || return 1
  d__context -- push "Using '$D__OS_PKGMGR'"
  if ! d__cmd d__os_pkgmgr install chsh \
    --else-- 'Refusing to proceed with current deployment'
  then D_ADDST_MLTSK_HALT=true; return 1; fi
  d__cmd d__stash -s -- set chsh_installed \
    --else-- 'Deployment will not uninstall properly' && d__context -- lop
  return 0
}

d_chsh_remove()
{
  d__context -- notch; d__context -- push "Auto-removing 'chsh' utility"
  d__require [ -z "$D__OS_PKGMGR" ] \
    --else-- 'Unable to auto-remove without a supported package manager' \
    || return 1
  d__context -- push "Using '$D__OS_PKGMGR'"
  d__cmd d__os_pkgmgr remove chsh \
    --else-- "'chsh' may need to be removed manually" || return 1
  d__cmd d__stash -s -- set chsh_installed \
    --else-- 'Deployment will appear partly installed' && d__context -- lop
  return 0
}

d_zsh_default_check()
{
  # Ensure default shell has not been changed manually
  if $D_SHELL_MANUALLY_CHANGED; then
    d__notify -lx -- 'Default shell has been manually changed' \
      "from '$D_NEW_SHELL' to '$SHELL'"
    return 6
  fi

  # Ensure default shell is not already zsh
  if $D_ALREADY_ZSH; then
    if [ "$D_ZSH_PATH" = "$SHELL"]; then
      d__notify -ls -- "Default shell is already zsh: $SHELL"; return 3
    else
      d__notify -lv -- "Default shell is already zsh: $SHELL"; return 7
    fi
  fi

  # Final verdict
  if [ -n "$D_NEW_SHELL" ]; then return 1; else return 2; fi
}

d_zsh_default_install()
{
  d__context -- notch; local ols="$SHELL"
  d__context -- push "Changing default shell from '$SHELL' to '$D_ZSH_PATH'"
  d__notify -l!h -- 'User password might be required'
  d__cmd chsh -s "$D_ZSH_PATH" \
    --else-- 'Unable to change default shell' || return 1
  local asr='to finilize default shell change'; case $D__OS_FAMILY in
    macos)  asr="Please, re-log into the system $asr";;
    *)      asr="Please, reload your shell $asr";;
  esac; D_ADDST_REBOOT+=("$asr")
  local els=( --else-- 'Records will be inconsistent' )
  if [ -n "$D_OLD_SHELL" ]; then
    d__cmd d__stash -s -- set new_shell "$D_ZSH_PATH" "${els[@]}" \
      && d__context -- lop
  else local algd=true
    d__cmd d__stash -s -- set old_shell "$ols" "${els[@]}" || algd=false
    d__cmd d__stash -s -- set new_shell "$D_ZSH_PATH" "${els[@]}" || algd=false
    $algd && d__context -- lop
  fi
  return 0
}

d_zsh_default_remove()
{
  d__context -- notch; d__context -- push 'Reverting default shell from' \
    "'$D_NEW_SHELL' to '$D_OLD_SHELL'"
  d__notify -l!h -- 'User password might be required'
  d__cmd chsh -s "$D_OLD_SHELL" \
    --else-- 'Unable to revert default shell' || return 1
  local asr='to finilize default shell reversal'; case $D__OS_FAMILY in
    macos)  asr="Please, re-log into the system $asr";;
    *)      asr="Please, reload your shell $asr";;
  esac; D_ADDST_REBOOT+=("$asr")
  local els=( --else-- 'Records will be inconsistent' ) algd=true
  d__cmd d__stash -s -- unset old_shell "${els[@]}" || algd=false
  d__cmd d__stash -s -- unset new_shell "${els[@]}" || algd=false
  $algd && d__context -- lop
  return 0
}

d_etc_old_check()
{
  # This step makes sense only when reverting to previous default shell
  case $D__REQ_ROUTINE in
    check)    return 3;;
    install)  return 3;;
    remove)
      # Ensure old shell is still in existence
      if ! [ -x "$D_OLD_SHELL" ]; then algd=false
        d__notify -lx -- "Previous default shell '$D_OLD_SHELL'" \
          'is currently not an executable'
        D_ADDST_MLTSK_HALT=true; return 3
      fi
      # Perform actual check
      if grep -Fxq "$D_OLD_SHELL" /etc/shells &>/dev/null
      then return 2; else return 1; fi;;
  esac
}

d_etc_old_install() { :; }

d_etc_old_remove()
{
  d__context -- notch
  d__context -- push "Restoring old shell '$D_OLD_SHELL' to /etc/shells"
  local cmd=tee; d__require_wfile /etc/shells || cmd='sudo tee'
  if ! d__cmd --sb-- $cmd -a /etc/shells <<<"$D_OLD_SHELL" \
    --else-- 'Unable to change to previous default shell'
  then D_ADDST_MLTSK_HALT=true; return 1; fi
  d__context -- lop; return 0
}