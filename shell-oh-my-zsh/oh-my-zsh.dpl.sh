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

D_OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
D_OH_MY_ZSH_REPO='https://github.com/robbyrussell/oh-my-zsh.git'

# Delegate to built-in checking routine
dcheck()
{
  # Compile task names; and split queue in two parts
  D_DPL_TASK_NAMES+=( omz_fmwk )
  D_DPL_TASK_NAMES+=( omz_assets )

  # Assemble assets
  d_assemble_asset_queue

  # Delegate to built-in helper
  __multitask_hlp__dcheck
}

# dinstall and dremove are fully delegated to built-in helpers
dinstall()  {   __multitask_hlp__dinstall;  }
dremove()   {   __multitask_hlp__dremove;   }

d_omz_fmwk_dcheck()
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

d_omz_fmwk_dinstall()
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

d_omz_fmwk_dremove()
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

d_assemble_asset_queue()
{
  # Storage variables
  local restore_opts cmd target_path asset_path
  local target_paths=() asset_paths=() asset_relpaths=()

  # Save current state of ‘dotglob’ and ‘nullglob’ options
  restore_opts=( "$( shopt -p dotglob )" "$( shopt -p nullglob )" )

  # Set both ‘dotglob’ and ‘nullglob’ options
  shopt -s dotglob nullglob

  #
  # Populate themes
  #
  for asset_path in "$D_DPL_ASSETS_DIR/themes/"*.zsh-theme; do

    # Check if replacement if a readable file
    [ -r "$asset_path" -a -f "$asset_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $asset_path (not a readable file)"
      continue
    }

    # Compose target path
    target_path="$D_OH_MY_ZSH_PATH/custom/themes/$( basename -- \
      "$asset_path" )"

    # Push pair of paths onto the stack
    target_paths+=( "$target_path" )
    asset_paths+=( "$asset_path" )
    asset_relpaths+=("${asset_path#"$D_DPL_ASSETS_DIR/"}")
    
  done

  #
  # Populate plugins
  #
  for asset_path in "$D_DPL_ASSETS_DIR/plugins/"*/*.plugin.zsh; do

    # Make actual replacement the parent directory
    asset_path="$( dirname -- "$asset_path" )"

    # Check if replacement if a readable directory
    [ -r "$asset_path" -a -d "$asset_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $asset_path (not a readable dir)"
      continue
    }

    # Compose target path
    target_path="$D_OH_MY_ZSH_PATH/custom/plugins/$( basename -- \
      "$asset_path" )"

    # Push pair of paths onto the stack
    target_paths+=( "$target_path" )
    asset_paths+=( "$asset_path" )
    asset_relpaths+=("${asset_path#"$D_DPL_ASSETS_DIR/"}")
    
  done

  #
  # Done populating
  #

  # Restore state of ‘dotglob’ and ‘nullglob’ options
  for cmd in "${restore_opts[@]}"; do $cmd; done

  # Populate globals
  D_DPL_TARGET_PATHS=( "${target_paths[@]}" )
  D_DPL_ASSET_PATHS=( "${asset_paths[@]}" )
  D_DPL_ASSET_RELPATHS=( "${asset_relpaths[@]}" )
  D_DPL_QUEUE_MAIN=( "${asset_relpaths[@]}" )

  # Return success
  return 0
}