#:title:        Divine deployment: bash-it
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    15
#:revdate:      2019.08.20
#:revremark:    Merge D_DPL_ASSET_RELPATHS into D_QUEUE_MAIN
#:created_at:   2019.06.30

D_DPL_NAME='bash-it'
D_DPL_DESC='A community Bash framework'
D_DPL_PRIORITY=3333
D_DPL_FLAGS=
D_DPL_WARNING=

D_BASH_IT_PATH="$HOME/.bash-it"
D_BASH_IT_REPO='https://github.com/Bash-it/bash-it.git'

# Delegate to built-in checking routine
d_dpl_check()
{
  # Compile task names; and split queue in two parts
  D_MULTITASK_NAMES+=( bash_it_fmwk )
  D_MULTITASK_NAMES+=( bash_it_assets )

  # Delegate to built-in helper
  d__multitask_check
}

# d_dpl_install and d_dpl_remove are fully delegated to built-in helpers
d_dpl_install()  {   d__multitask_install;  }
d_dpl_remove()   {   d__multitask_remove;   }

d_bash_it_fmwk_check()
{
  # Rely on stashing
  dstash ready || return 3

  # Check if framework directory is readable
  if [ -r "$D_BASH_IT_PATH" -a -d "$D_BASH_IT_PATH" ]; then
  
    # Check if there is record of previous installation
    if dstash -s has fmwk_installed; then
      dprint_debug 'Bash-it framework appears to be installed'
      D_DPL_INSTALLED_BY_USER_OR_OS=false
    else
      dprint_debug 'Bash-it framework appears to be installed by user'
      D_DPL_INSTALLED_BY_USER_OR_OS=true
    fi

    # Return
    return 1
  
  else

    # Check if path nevertheless exists
    if [ -e "$D_BASH_IT_PATH" ]; then

      # Do not touch pre-existing non-directory
      dprint_debug \
        'Bash-it framework path exists, but is not a readable directory:' \
        -i "$D_BASH_IT_PATH"
      return 3

    else

      # Path is free: consider this not installed
      dprint_debug 'Bash-it framework appears to be not installed'
      return 2

    fi

  fi
}

d_bash_it_fmwk_install()
{
  # Check if Bash-it path exists
  if [ -e "$D_BASH_IT_PATH" ]; then

    # Pre-erase and check status
    if rm -rf -- "$D_BASH_IT_PATH"; then

      # Report
      dprint_debug "Pre-erased existing Bash-it directory: $D_BASH_IT_PATH"
    
    else

      # Failed to erase
      dprint_debug \
        "Failed to pre-erase existing Bash-it directory: $D_BASH_IT_PATH"
      return 1
    
    fi

  fi

  # Require git
  command -v git &>/dev/null || {
    dprint_debug "Git is required, but not found"
    return 1
  }

  # Clone repo to install directory
  if /usr/bin/env git clone --depth=1 "$D_BASH_IT_REPO" "$D_BASH_IT_PATH" \
    &>/dev/null
  then

    ## Run installation script without modifying RC files. (Bash-it is 
    #. supported by 'shell-rc' deployment.) Mind verbosity.
    #
    if $D__OPT_QUIET; then
      
      # Run script quietly
      "$D_BASH_IT_PATH"/install.sh --no-modify-config &>/dev/null

    else

      # Run script normally, but re-paint output
      local line
      "$D_BASH_IT_PATH"/install.sh --no-modify-config 2>&1 \
        | while IFS= read -r line || [ -n "$line" ]; do
        printf "${CYAN}==> %s${NORMAL}\n" "$line"
      done

    fi

    # Check return status
    if [ "${PIPESTATUS[0]}" -eq 0 ]; then

      # Successfully installed: report and set stash record
      dprint_debug "Cloned and installed Bash-it from: $D_BASH_IT_REPO" \
        -n "to: $D_BASH_IT_PATH"
      dstash -s set fmwk_installed
      return 0

    else

      # Failed to install
      dprint_debug "Failed to install Bash-it from: $D_BASH_IT_REPO" \
        -n "using installation script at: $D_BASH_IT_PATH/install.sh"
      return 1

    fi

  else

    # Failed to clone
    dprint_debug "Failed to clone Bash-it from: $D_BASH_IT_REPO" \
      -n "to: $D_BASH_IT_PATH"
    return 1

  fi
}

d_bash_it_fmwk_remove()
{
  # Check if already removed
  if ! [ -e "$D_BASH_IT_PATH" ]; then

    # Report
    dprint_debug "Already does not exist: $D_BASH_IT_PATH"
    dstash -s unset fmwk_installed
    return 0

  fi

  # Remove install directory and check status
  if rm -rf -- "$D_BASH_IT_PATH"; then
    
    # Report, unset stash record, and return
    dprint_debug "Erased Bash-it path at: $D_BASH_IT_PATH"
    dstash -s unset fmwk_installed
    return 0

  else

    # Report and return
    dprint_debug "Failed to erase Bash-it path at: $D_BASH_IT_PATH"
    return 1

  fi
}

d_assemble_asset_queue()
{
  # Storage variables
  local restore_opts cmd target_path asset_path
  local target_paths=() asset_paths=() asset_relpaths=()

  # Save current state of 'dotglob' and 'nullglob' options
  restore_opts=( "$( shopt -p dotglob )" "$( shopt -p nullglob )" )

  # Set both 'dotglob' and 'nullglob' options
  shopt -s dotglob nullglob

  #
  # Populate aliases
  #
  for asset_path in "$D__DPL_ASSET_DIR/aliases/"*.aliases.bash; do

    # Check if replacement if a readable file
    [ -r "$asset_path" -a -f "$asset_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $asset_path (not a readable file)"
      continue
    }

    # Compose target path
    target_path="$D_BASH_IT_PATH/aliases/available/$( basename -- \
      "$asset_path" )"

    # Push pair of paths onto the stack
    target_paths+=( "$target_path" )
    asset_paths+=( "$asset_path" )
    asset_relpaths+=("${asset_path#"$D__DPL_ASSET_DIR/"}")
    
  done

  #
  # Populate completions
  #
  for asset_path in "$D__DPL_ASSET_DIR/completion/"*.completion.bash; do

    # Check if replacement if a readable file
    [ -r "$asset_path" -a -f "$asset_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $asset_path (not a readable file)"
      continue
    }

    # Compose target path
    target_path="$D_BASH_IT_PATH/completion/available/$( basename -- \
      "$asset_path" )"

    # Push pair of paths onto the stack
    target_paths+=( "$target_path" )
    asset_paths+=( "$asset_path" )
    asset_relpaths+=("${asset_path#"$D__DPL_ASSET_DIR/"}")
    
  done

  #
  # Populate lib
  #
  for asset_path in "$D__DPL_ASSET_DIR/lib/"*.bash; do

    # Check if replacement if a readable file
    [ -r "$asset_path" -a -f "$asset_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $asset_path (not a readable file)"
      continue
    }

    # Compose target path
    target_path="$D_BASH_IT_PATH/lib/$( basename -- "$asset_path" )"

    # Push pair of paths onto the stack
    target_paths+=( "$target_path" )
    asset_paths+=( "$asset_path" )
    asset_relpaths+=("${asset_path#"$D__DPL_ASSET_DIR/"}")
    
  done

  #
  # Populate plugins
  #
  for asset_path in "$D__DPL_ASSET_DIR/plugins/"*.plugin.bash; do

    # Check if replacement if a readable file
    [ -r "$asset_path" -a -f "$asset_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $asset_path (not a readable file)"
      continue
    }

    # Compose target path
    target_path="$D_BASH_IT_PATH/plugins/available/$( basename -- \
      "$asset_path" )"

    # Push pair of paths onto the stack
    target_paths+=( "$target_path" )
    asset_paths+=( "$asset_path" )
    asset_relpaths+=("${asset_path#"$D__DPL_ASSET_DIR/"}")
    
  done

  #
  # Populate themes
  #
  for asset_path in "$D__DPL_ASSET_DIR/themes/"*/*.theme.bash; do

    # Make actual replacement the parent directory
    asset_path="$( dirname -- "$asset_path" )"

    # Check if replacement if a readable file
    [ -r "$asset_path" -a -d "$asset_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $asset_path (not a readable dir)"
      continue
    }

    # Compose target path
    target_path="$D_BASH_IT_PATH/themes/$( basename -- "$asset_path" )"

    # Push pair of paths onto the stack
    target_paths+=( "$target_path" )
    asset_paths+=( "$asset_path" )
    asset_relpaths+=("${asset_path#"$D__DPL_ASSET_DIR/"}")
    
  done

  #
  # Done populating
  #

  # Restore state of 'dotglob' and 'nullglob' options
  for cmd in "${restore_opts[@]}"; do $cmd; done

  # Populate globals
  D_QUEUE_MAIN=( "${asset_relpaths[@]}" )
  D_DPL_ASSET_PATHS=( "${asset_paths[@]}" )
  D_DPL_TARGET_PATHS=( "${target_paths[@]}" )

  # Return success
  return 0
}

# Implement primaries for assets
d_bash_it_assets_check()    { d_assemble_asset_queue; d__link_queue_check; }
d_bash_it_assets_install()  { d__link_queue_install;  }
d_bash_it_assets_remove()   { d__link_queue_remove;   }