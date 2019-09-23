#:title:        Divine deployment: zsh-default
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    6
#:revdate:      2019.09.23
#:revremark:    Restore double underscore to stash function
#:created_at:   2019.06.30

D_DPL_NAME='zsh-default'
D_DPL_DESC='zsh as default shell'
D_DPL_PRIORITY=1333
D_DPL_FLAGS=
D_DPL_WARNING=

## Ensures zsh is default shell
#
## Assumes that first zsh that comes up with command -v is the one desired
#
## Stores path to previous default shell in a file in this directory, and uses 
#. it to restore default shell upon removal of this deployment. If no backup is 
#. stored, removal does nothing.

## Exit codes and their meaning:
#.  0 - Unknown
#.  1 - Installed
#.  2 - Not installed
#.  3 - Irrelevant
#.  4 - Partly installed
d_dpl_check()
{
  # Rely on $SHELL to be populated
  [ -n "$SHELL" ] || {
    dprint_debug '$SHELL variable is not populated' \
      '(it normally holds current default shell)'
    return 3
  }

  # Rely on stashing
  d__stash ready || return 3

  # Assume that first zsh on the PATH is the one desired
  D_ZSH_PATH="$( type -P zsh 2>/dev/null )"

  # Rely on zsh to be installed
  if [ -x "$D_ZSH_PATH" ]; then
    dprint_debug 'Using zsh detected at:' -i "$D_ZSH_PATH"
  else
    dprint_debug 'zsh is required but not found' \
      '(it has to be pre-installed)'
    return 3
  fi

  # Global marker about stash status
  D_GOOD_STASH=true

  # Check if there is a stash record of this deployment being installed
  if d__stash -s has installed; then

    # Stash record exists: extract parts of it
    local old_shell="$( d__stash -s get old_shell )"
    local new_shell="$( d__stash -s get new_shell )"
    local chsh_installed="$( d__stash -s has chsh_installed \
      && printf yes || printf no )"
    local etc_added="$( d__stash -s has etc_added \
      && printf yes || printf no )"

    # Print debug summary
    dprint_debug 'Detected record of previous installation:' \
      -i 'Old shell:' "$old_shell" \
      -i 'New shell:' "$new_shell" \
      -i 'chsh installed:' "$chsh_installed" \
      -i '/etc/shells record added:' "$etc_added"

    # Check if old shell still exists
    if ! [ -x "$old_shell" ]; then
      dprint_debug "Previous shell '$old_shell' is currently not installed"
      D_GOOD_STASH=false
    fi

    # Check if old shell is still in /etc/shells
    if ! grep -Fxq "$old_shell" /etc/shells &>/dev/null; then
      dprint_debug \
        "Previous shell '$old_shell' is currently not listed in '/etc/shells'"
      D_GOOD_STASH=false
    fi

    # Check if detected zsh is the one installed
    if ! [ "$SHELL" = "$new_shell" ]; then
      dprint_debug \
        'Despite record of previously changing default shell' \
        "to '$new_shell'," \
        -n "current default shell is '$SHELL'"
      D_GOOD_STASH=false
    fi

    # Check if previously installed chsh is still installed
    if [ "$chsh_installed" = yes ] && ! type -P chsh &>/dev/null; then
      dprint_debug \
        "Previously installed 'chsh' is currently not found on \$PATH"
      D_GOOD_STASH=false
    fi

    # Check if previously added /etc/shells record is still in place
    if [ "$etc_added" = yes ] \
      && ! grep -Fxq "$new_shell" /etc/shells &>/dev/null
    then
      dprint_debug \
        "Line '$new_shell', previously added to '/etc/shells'," \
        'is currently not found'
      D_GOOD_STASH=false
    fi

    # Check if stash is reliable
    if $D_GOOD_STASH; then

      # Reliable stash, dpl is installed
      return 1

    else

      # Unreliable stash: announce the fact loudly
      dprint_alert 'Stash records are inconsistent with current set-up'

      # Check if current default shell is already zsh
      if [ "$( basename -- "$SHELL" )" = zsh ]; then

        # Current default is still zsh: report and return installed
        dprint_debug "Current default shell is still zsh ('$SHELL')"
        return 1
      
      else

        # Current default is not zsh: report and return not installed
        dprint_debug "Current default shell is not zsh ('$SHELL')"
        return 2

      fi

    fi

  else

    # No stash record
    dprint_debug 'No record of previous installation'

    # Check if current default shell is nevertheless zsh
    [ "$( basename -- "$SHELL" )" = zsh ] && {
      dprint_debug 'Current default shell is already zsh'
      D_DPL_INSTALLED_BY_USER_OR_OS=true
      return 1
    }

    # Otherwise, return not installed
    return 2

  fi
}

## Exit codes and their meaning:
#.  0   - Successfully installed
#.  1   - Failed to install
#.  2   - Skipped completely
#.  100 - Reboot needed
#.  101 - User attention needed
#.  102 - Critical failure
d_dpl_install()
{
  # Rely on chsh to be available
  if ! type -P chsh &>/dev/null; then

    # If package manager is not detected, there are no options
    if [ -z ${D__OS_PKGMGR+isset} ]; then
      dprint_debug 'chsh is required but not found' \
        '(no way to auto-install)'
      return 1
    fi

    # If chsh is not available, offer to install it
    if ! dprompt --bare --prompt 'Attempt to install?' \
      --answer "$D__OPT_ANSWER" -- \
      'Deployment relies on chsh, but it is not found on $PATH' \
      -n "It may be possible to install it using $D__OS_PKGMGR"
    then
      # User declined
      dprint_debug 'chsh is required but not found' \
        '(declined to auto-install)'
      return 1
    fi

    # Auto-install chsh with verbosity in mind
    if $D__OPT_QUIET; then

      # Launch quietly
      d__os_pkgmgr install chsh &>/dev/null

    else

      # Launch normally, but re-paint output
      local stdout_line
      d__os_pkgmgr install chsh 2>&1 \
        | while IFS= read -r stdout_line || [ -n "$stdout_line" ]
        do
          printf "${CYAN}==> %s${NORMAL}\n" "$stdout_line"
        done
      
    fi

    # Check return status
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then
      # Successfully installed: record this to stash
      dprint_debug 'Auto-installed chsh'
      d__stash -s set chsh_installed
    else
      # Failed to install
      dprint_debug 'chsh is required but not found' \
        '(failed to auto-install)'
      return 1
    fi

  fi

  # Check if /etc/shells contains desired zsh
  if ! grep ^"$D_ZSH_PATH"$ /etc/shells &>/dev/null; then

    # Announce addition
    dprint_debug "Adding desired shell '$D_ZSH_PATH' to '/etc/shells'"

    # If not, add it (sudo may be required)
    if [ -w /etc/shells ]; then
      printf '%s\n' "$D_ZSH_PATH" >>/etc/shells
    else
      if ! sudo -n true 2>/dev/null; then
        dprint_alert 'Modifying /etc/shells requires sudo password'
      fi
      sudo tee -a /etc/shells &>/dev/null <<<"$D_ZSH_PATH"
    fi
      
    [ $? -eq 0 ] || {
      dprint_debug "Failed to add '$D_ZSH_PATH' to '/etc/shells'"
      return 1
    }

    # Successfully added: record this to stash
    dprint_debug "Added '$D_ZSH_PATH' to '/etc/shells'"
    d__stash -s set etc_added

  fi

  # Record current (old) shell
  local old_shell="$SHELL"

  # Warn about upcoming password prompt
  dprint_alert 'Changing default shell requires user password'

  # Now, CHange SHell with chsh
  if chsh -s "$D_ZSH_PATH"; then

    # Announce success
    dprint_debug 'Successfully changed default shell to:' -i "$D_ZSH_PATH"

    # Ask user to reload shell
    case $D__OS_FAMILY in
      macos)
        dprint_alert \
          'Please, re-log into the system to finilize shell change';;
      *)
        dprint_alert \
          'Please, reload your shell to finilize shell change';;
    esac

    # Flip stash flags
    d__stash -s set old_shell "$old_shell"
    d__stash -s set new_shell "$D_ZSH_PATH"
    d__stash -s set installed

    # Return success
    return 0

  else

    # Announce and return failure
    dprint_debug 'Failed to change default shell to:' -i "$D_ZSH_PATH"
    return 1

  fi
}

## Exit codes and their meaning:
#.  0   - Successfully removed
#.  1   - Failed to remove
#.  2   - Skipped completely
#.  100 - Reboot needed
#.  101 - User attention needed
#.  102 - Critical failure
d_dpl_remove()
{
  # Check if there is record of previous installation
  d__stash -s has installed || {
    dprint_debug 'No record of previous installation'
    return 2
  }

  # Otherwise, undo what can be undone
  local old_shell="$( d__stash -s get old_shell )"
  local new_shell="$( d__stash -s get new_shell )"
  local chsh_installed="$( d__stash -s has chsh_installed \
    && printf yes || printf no )"
  local etc_added="$( d__stash -s has etc_added \
    && printf yes || printf no )"

  # Attempt to change shell back
  if [ "$SHELL" != "$old_shell" ] \
    && type -P chsh &>/dev/null \
    && [ -x "$old_shell" ]
  then

    local shell_is_ok=true

    # Check if /etc/shells still contains original shell
    if ! grep ^"$old_shell"$ /etc/shells &>/dev/null; then

      # Announce addition
      dprint_debug "Adding original shell '$old_shell' to '/etc/shells'"

      # If not, add it (sudo may be required)
      if [ -w /etc/shells ]; then
        printf '%s\n' "$old_shell" >>/etc/shells
      else
        if ! sudo -n true 2>/dev/null; then
          dprint_alert 'Modifying /etc/shells requires sudo password'
        fi
        sudo tee -a /etc/shells &>/dev/null <<<"$old_shell"
      fi
        
      if [ $? -eq 0 ]; then
        dprint_debug "Added original shell '$old_shell' to '/etc/shells'"
      else
        dprint_debug \
          "Failed to add original shell '$old_shell' to '/etc/shells'"
        shell_is_ok=false
      fi

    fi

    # Warn about upcoming password prompt
    if $shell_is_ok; then
      dprint_alert 'Changing default shell requires user password'
    fi

    # CHange SHell back to old default
    if $shell_is_ok && chsh -s "$old_shell"; then

      # Announce success
      dprint_debug 'Successfully restored default shell to:' -i "$old_shell"

      # Ask user to reload shell
      case $D__OS_FAMILY in
        macos)
          dprint_alert \
            'Please, re-log into the system to finilize shell change';;
        *)
          dprint_alert \
            'Please, reload your shell to finilize shell change';;
      esac

      # Flip stash flags
      d__stash -s unset new_shell
      d__stash -s unset old_shell
      # d__stash -s unset installed

    else

      # Announce failure
      dprint_debug 'Failed to restore default shell to:' -i "$old_shell"

    fi
  
  else

    # Reasoning should be apparent from d_dpl_check output
    dprint_debug 'Skipped restoring original shell'

  fi

  # Attempt to uninstall chsh
  if [ "$chsh_installed" = yes -a -n "${D__OS_PKGMGR+isset}" ]; then

    # Auto-uninstall chsh with verbosity in mind
    if $D__OPT_QUIET; then

      # Launch quietly
      d__os_pkgmgr remove chsh &>/dev/null

    else

      # Launch normally, but re-paint output
      local stdout_line
      d__os_pkgmgr remove chsh 2>&1 \
        | while IFS= read -r stdout_line || [ -n "$stdout_line" ]
        do
          printf "${CYAN}==> %s${NORMAL}\n" "$stdout_line"
        done
      
    fi

    # Check return status
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then
      # Successfully removed
      dprint_debug 'Auto-removed chsh'
      d__stash -s unset chsh_installed
    else
      # Failed to remove
      dprint_debug 'Failed to auto-remove chsh'
    fi

  else

    dprint_debug 'Skipped restoring original status of chsh'

  fi

  # Attempt to remove $new_shell from /etc/shells
  if [ "$etc_added" = yes \
    -a -r /etc/shells \
    -a -n "$new_shell" ]
  then

    # Make temporary file
    local temp="$( mktemp )" line

    # Copy install file to temp, except the line being deleted
    while read -r line; do
      [ "$line" = "$new_shell" ] || printf '%s\n' "$line"
    done </etc/shells >"$temp"

    # Move temp to location of install file (sudo may be required)
    if [ -w /etc/shells ]; then
      mv -f -- "$temp" /etc/shells
    else
      if ! sudo -n true 2>/dev/null; then
        dprint_alert 'Modifying /etc/shells requires sudo password'
      fi
      sudo mv -f -- "$temp" /etc/shells
    fi

    if [ $? -eq 0 ]; then
      dprint_debug "Restored original state of '/etc/shells'"
    else
      dprint_debug "Failed to restore original state of '/etc/shells'"
    fi

  else

    dprint_debug "Skipped restoring original state of '/etc/shells'"

  fi

  # Clean up stash and return
  if ! d__stash -s has old_shell \
    && ! d__stash -s has new_shell \
    && ! d__stash -s has chsh_installed \
    && ! d__stash -s has etc_added
  then
    d__stash -s unset installed
    return 0
  else
    return 1
  fi
}