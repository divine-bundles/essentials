#:title:        Divine deployment: oh-my-zsh
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D_DPL_NAME='oh-my-zsh'
D_DPL_DESC='Your terminal never felt this good before'
D_DPL_PRIORITY=3333
D_DPL_FLAGS=
D_DPL_WARNING=

D_DPL_DIR+='/oh-my-zsh-custom'
D_OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
D_OH_MY_ZSH_REPO='https://github.com/robbyrussell/oh-my-zsh.git'

## Exit codes and their meaning:
#.  0 - Unknown
#.  1 - Installed
#.  2 - Not installed
#.  3 - Irrelevant
#.  4 - Partly installed
dcheck()
{
  # Task 1: framework itself
  __d__omz_fmwk_dcheck; __catch_dcheck_code

  # Task 2: framework assets (use dln queue)
  __d__omz_assemble_asset_queue
  __dln_hlp__dcheck; __catch_dcheck_code

  # Tie them all up
  __reconcile_dcheck_codes
}

## Exit codes and their meaning:
#.  0   - Successfully installed
#.  1   - Failed to install
#.  2   - Skipped completely
#.  100 - Reboot needed
#.  101 - User attention needed
#.  666 - Critical failure
dinstall()
{
  # Task 1: framework itself
  __task_is_installable && __d__omz_fmwk_dinstall
  __catch_dinstall_code || return $?

  # Task 2: framework assets (use dln queue)
  __task_is_installable && __dln_hlp__dinstall
  __catch_dinstall_code || return $?

  # Tie them all up
  __reconcile_dinstall_codes
}

## Exit codes and their meaning:
#.  0   - Successfully removed
#.  1   - Failed to remove
#.  2   - Skipped completely
#.  100 - Reboot needed
#.  101 - User attention needed
#.  666 - Critical failure
dremove()
{
  # Task 1: framework itself
  __task_is_removable && __d__omz_fmwk_dremove
  __catch_dremove_code || return $?

  # Task 2: framework assets (use dln queue)
  __task_is_removable && __dln_hlp__dremove
  __catch_dremove_code || return $?

  # Tie them all up
  __reconcile_dremove_codes
}

__d__omz_fmwk_dcheck()
{
  # Rely on stashing
  dstash ready || return 3

  # Check if framework directory is readable
  if [ -r "$D_OH_MY_ZSH_PATH" -a -d "$D_OH_MY_ZSH_PATH" ]; then
  
    # Check if there is record of previous installation
    if dstash -s has fmwk_installed; then
      dprint_debug 'oh-my-zsh framework appears to be installed'
      D_USER_OR_OS=false
    else
      dprint_debug 'oh-my-zsh framework appears to be installed by user'
      D_USER_OR_OS=true
    fi

    # Return
    return 1
  
  else

    # Check if path nevertheless exists
    if [ -e "$D_OH_MY_ZSH_PATH" ]; then

      # Do not touch pre-existing non-directory
      dprint_debug \
        'oh-my-zsh framework path exists, but is not a readable directory:' \
        -i "$D_OH_MY_ZSH_PATH"
      return 3

    else

      # Path is free: consider this not installed
      dprint_debug 'oh-my-zsh framework appears to be not installed'
      return 2

    fi

  fi
}

__d__omz_fmwk_dinstall()
{
  # Check if oh-my-zsh path exists
  if [ -e "$D_OH_MY_ZSH_PATH" ]; then

    # Pre-erase and check status
    if rm -rf -- "$D_OH_MY_ZSH_PATH"; then

      # Report
      dprint_debug "Pre-erased existing oh-my-zsh directory: $D_OH_MY_ZSH_PATH"
    
    else

      # Failed to erase
      dprint_debug \
        "Failed to pre-erase existing oh-my-zsh directory: $D_OH_MY_ZSH_PATH"
      return 1
    
    fi

  fi

  # Require git
  command -v git &>/dev/null || {
    dprint_debug "Git is required, but not found"
    return 1
  }

  # On Cygwin, require particular git
  if [[ $OS_FAMILY =~ ^(cygwin|msys)$ ]] \
    && git --version | grep msysgit >/dev/null
  then
    dprint_debug 'Windows/MSYS Git is not supported on Cygwin'
    return 1
  fi

  # Clone repo to install directory
  if /usr/bin/env git clone --depth=1 "$D_OH_MY_ZSH_REPO" "$D_OH_MY_ZSH_PATH"
  then

    ## Cloned successfully, no further installation required (oh-my-zsh is 
    #. supported by ‘shell-rc’ deployment.)
    #
    dprint_debug "Cloned oh-my-zsh from: $D_OH_MY_ZSH_REPO" \
      -n "to: $D_OH_MY_ZSH_PATH"
    dstash -s set fmwk_installed

  else

    # Failed to clone
    dprint_debug "Failed to clone oh-my-zsh from: $D_OH_MY_ZSH_REPO" \
      -n "to: $D_OH_MY_ZSH_PATH"
    return 1

  fi
}

__d__omz_fmwk_dremove()
{
  # Check if already removed
  if ! [ -e "$D_OH_MY_ZSH_PATH" ]; then

    # Report
    dprint_debug "Already does not exist: $D_OH_MY_ZSH_PATH"
    dstash -s unset fmwk_installed
    return 0

  fi

  # Remove install directory and check status
  if rm -rf -- "$D_OH_MY_ZSH_PATH"; then
    
    # Report, unset stash record, and return
    dprint_debug "Erased oh-my-zsh path at: $D_OH_MY_ZSH_PATH"
    dstash -s unset fmwk_installed
    return 0

  else

    # Report and return
    dprint_debug "Failed to erase oh-my-zsh path at: $D_OH_MY_ZSH_PATH"
    return 1

  fi
}

__d__omz_assemble_asset_queue()
{
  # Storage variables
  local restore_opts cmd orig_path replacement_path
  local d_orig=() d_replacements=() d_relatives=()

  # Save current state of ‘dotglob’ and ‘nullglob’ options
  restore_opts=( "$( shopt -p dotglob )" "$( shopt -p nullglob )" )

  # Set both ‘dotglob’ and ‘nullglob’ options
  shopt -s dotglob nullglob

  #
  # Populate themes
  #
  for replacement_path in "$D_DPL_ASSETS_DIR/themes/"*.zsh-theme; do

    # Check if replacement if a readable file
    [ -r "$replacement_path" -a -f "$replacement_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $replacement_path (not a readable file)"
      continue
    }

    # Compose target path
    orig_path="$D_OH_MY_ZSH_PATH/custom/themes/$( basename -- \
      "$replacement_path" )"

    # Push pair of paths onto the stack
    d_orig+=( "$orig_path" )
    d_replacements+=( "$replacement_path" )
    d_relatives+=("${replacement_path#"$D_DPL_ASSETS_DIR/"}")
    
  done

  #
  # Populate plugins
  #
  for replacement_path in "$D_DPL_ASSETS_DIR/plugins/"*/*.plugin.zsh; do

    # Make actual replacement the parent directory
    replacement_path="$( dirname -- "$replacement_path" )"

    # Check if replacement if a readable directory
    [ -r "$replacement_path" -a -d "$replacement_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $replacement_path (not a readable dir)"
      continue
    }

    # Compose target path
    orig_path="$D_OH_MY_ZSH_PATH/custom/plugins/$( basename -- \
      "$replacement_path" )"

    # Push pair of paths onto the stack
    d_orig+=( "$orig_path" )
    d_replacements+=( "$replacement_path" )
    d_relatives+=("${replacement_path#"$D_DPL_ASSETS_DIR/"}")
    
  done

  #
  # Done populating
  #

  # Restore state of ‘dotglob’ and ‘nullglob’ options
  for cmd in "${restore_opts[@]}"; do $cmd; done

  # Populate globals
  D_DPL_TARGET_PATHS=( "${d_orig[@]}" )
  D_DPL_ASSET_PATHS=( "${d_replacements[@]}" )
  D_DPL_ASSET_RELPATHS=( "${d_relatives[@]}" )
  D_DPL_QUEUE_MAIN=( "${d_relatives[@]}" )

  # Return success
  return 0
}