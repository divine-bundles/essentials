#:title:        Divine deployment: bash-it
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D_DPL_NAME='bash-it'
D_DPL_DESC='A community Bash framework'
D_DPL_PRIORITY=3333
D_DPL_FLAGS=
D_DPL_WARNING=

D_DPL_DIR+='/bash-it-custom'
D_BASH_IT_PATH="$HOME/.bash-it"
D_BASH_IT_REPO='https://github.com/Bash-it/bash-it.git'

## Exit codes and their meaning:
#.  0 - Unknown
#.  1 - Installed
#.  2 - Not installed
#.  3 - Irrelevant
#.  4 - Partly installed
dcheck()
{
  # Task 1: framework itself
  __d__bi_fmwk_dcheck; __catch_dcheck_code

  # Task 2: framework assets (use dln queue)
  __d__bi_assemble_asset_queue
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
  __task_is_installable && __d__bi_fmwk_dinstall
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
  __task_is_removable && __d__bi_fmwk_dremove
  __catch_dremove_code || return $?

  # Task 2: framework assets (use dln queue)
  __task_is_removable && __dln_hlp__dremove
  __catch_dremove_code || return $?

  # Tie them all up
  __reconcile_dremove_codes
}

__d__bi_fmwk_dcheck()
{
  # Rely on stashing
  dstash ready || return 3

  # Check if framework directory is readable
  if [ -r "$D_BASH_IT_PATH" -a -d "$D_BASH_IT_PATH" ]; then
  
    # Check if there is record of previous installation
    if dstash -s has fmwk_installed; then
      dprint_debug 'Bash-it framework appears to be installed'
      D_USER_OR_OS=false
    else
      dprint_debug 'Bash-it framework appears to be installed by user'
      D_USER_OR_OS=true
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

__d__bi_fmwk_dinstall()
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
  if /usr/bin/env git clone --depth=1 "$D_BASH_IT_REPO" "$D_BASH_IT_PATH"
  then

    ## Run installation script without modifying RC files. (Bash-it is 
    #. supported by ‘shell-rc’ deployment.)
    #
    if "$D_BASH_IT_PATH"/install.sh --no-modify-config; then

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

__d__bi_fmwk_dremove()
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

__d__bi_assemble_asset_queue()
{
  # Storage variables
  local restore_opts cmd orig_path replacement_path
  local d_orig=() d_replacements=() d_relatives=()

  # Save current state of ‘dotglob’ and ‘nullglob’ options
  restore_opts=( "$( shopt -p dotglob )" "$( shopt -p nullglob )" )

  # Set both ‘dotglob’ and ‘nullglob’ options
  shopt -s dotglob nullglob

  #
  # Populate aliases
  #
  for replacement_path in "$D_DPL_ASSETS_DIR/aliases/"*.aliases.bash; do

    # Check if replacement if a readable file
    [ -r "$replacement_path" -a -f "$replacement_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $replacement_path (not a readable file)"
      continue
    }

    # Compose target path
    orig_path="$D_BASH_IT_PATH/aliases/available/$( basename -- \
      "$replacement_path" )"

    # Push pair of paths onto the stack
    d_orig+=( "$orig_path" )
    d_replacements+=( "$replacement_path" )
    d_relatives+=("${replacement_path#"$D_DPL_ASSETS_DIR/"}")
    
  done

  #
  # Populate completions
  #
  for replacement_path in "$D_DPL_ASSETS_DIR/completion/"*.completion.bash; do

    # Check if replacement if a readable file
    [ -r "$replacement_path" -a -f "$replacement_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $replacement_path (not a readable file)"
      continue
    }

    # Compose target path
    orig_path="$D_BASH_IT_PATH/completion/available/$( basename -- \
      "$replacement_path" )"

    # Push pair of paths onto the stack
    d_orig+=( "$orig_path" )
    d_replacements+=( "$replacement_path" )
    d_relatives+=("${replacement_path#"$D_DPL_ASSETS_DIR/"}")
    
  done

  #
  # Populate lib
  #
  for replacement_path in "$D_DPL_ASSETS_DIR/lib/"*.bash; do

    # Check if replacement if a readable file
    [ -r "$replacement_path" -a -f "$replacement_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $replacement_path (not a readable file)"
      continue
    }

    # Compose target path
    orig_path="$D_BASH_IT_PATH/lib/$( basename -- "$replacement_path" )"

    # Push pair of paths onto the stack
    d_orig+=( "$orig_path" )
    d_replacements+=( "$replacement_path" )
    d_relatives+=("${replacement_path#"$D_DPL_ASSETS_DIR/"}")
    
  done

  #
  # Populate plugins
  #
  for replacement_path in "$D_DPL_ASSETS_DIR/plugins/"*.plugin.bash; do

    # Check if replacement if a readable file
    [ -r "$replacement_path" -a -f "$replacement_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $replacement_path (not a readable file)"
      continue
    }

    # Compose target path
    orig_path="$D_BASH_IT_PATH/plugins/available/$( basename -- \
      "$replacement_path" )"

    # Push pair of paths onto the stack
    d_orig+=( "$orig_path" )
    d_replacements+=( "$replacement_path" )
    d_relatives+=("${replacement_path#"$D_DPL_ASSETS_DIR/"}")
    
  done

  #
  # Populate themes
  #
  for replacement_path in "$D_DPL_ASSETS_DIR/themes/"*/*.theme.bash; do

    # Make actual replacement the parent directory
    replacement_path="$( dirname -- "$replacement_path" )"

    # Check if replacement if a readable file
    [ -r "$replacement_path" -a -d "$replacement_path" ] || {
      dprint_debug \
        "Ignoring custom asset: $replacement_path (not a readable dir)"
      continue
    }

    # Compose target path
    orig_path="$D_BASH_IT_PATH/themes/$( basename -- "$replacement_path" )"

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