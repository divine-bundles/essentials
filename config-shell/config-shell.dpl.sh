#:title:        Divine deployment: config-shell
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.06.30

D_DPL_NAME='config-shell'
D_DPL_DESC='Startup commands for common shells (Bash, zsh)'
D_DPL_PRIORITY=333
D_DPL_FLAGS=
D_DPL_WARNING=

D_DPL_TARGET_DIR="$HOME"

D_ENV_FILEPATH="$HOME/.env.sh"
D_BLANKS_DIRNAME='blanks'
D_BLANK_RELPATHS=( \
  '.env.sh' \
  '.runcoms.bash' \
  '.runcoms.sh' \
  '.runcoms.zsh' \
  '.hushlogin' \
)

# Delegate to built-in checking routine
d_dpl_check()
{
  # Compile task names
  D_MULTITASK_NAMES+=( runcoms )
  D_MULTITASK_NAMES+=( blanks )
  D_MULTITASK_NAMES+=( env_vars )

  # Delegate to built-in helper
  d__multitask_check
}

# d_dpl_install and d_dpl_remove are fully delegated to built-in helpers
d_dpl_install()  {   d__multitask_install;  }
d_dpl_remove()   {   d__multitask_remove;   }

# Implement primaries for runcoms
d_runcoms_check()    { d__link_queue_check;    }
d_runcoms_install()  { d__link_queue_install;  }
d_runcoms_remove()   { d__link_queue_remove;   }

# Implement primaries for blanks
d_blanks_check()     { d_add_blanks_to_queue; d__copy_queue_check; }
d_blanks_install()   { d__copy_queue_install;   }
d_blanks_remove()    { d__copy_queue_remove;    }

# Implement addition of second chunk of the queue
d_add_blanks_to_queue()
{
  # Split queue at current length (which is number of items in manifest)
  d__queue_split

  # Compose path to directory containing blank files
  local blanks_dir="$D__DPL_DIR/$D_BLANKS_DIRNAME"

  # Storage variable
  local relpath

  # Add files to main queue and other arrays
  for relpath in "${D_BLANK_RELPATHS[@]}"; do
    D__QUEUE_MAIN+=( "$relpath" )
    D_DPL_ASSET_RELPATHS+=( "$relpath" )
    D_DPL_ASSET_PATHS+=( "$blanks_dir/$relpath" )
    D_DPL_TARGET_PATHS+=( "$D_DPL_TARGET_DIR/$relpath" )
  done
}

#
# Implement primaries for env_vars
#

# Implement checking of whether env file is properly populated
d_env_vars_check()
{
  # Check if env file exists
  if [ -f "$D_ENV_FILEPATH" ]; then

    # Announce
    dprint_debug -n 'Checking content of ~/.env.sh'

  else

    # No env file: announce and return not installed
    dprint_debug -n 'Not an existing file: ~/.env.sh'
    return 2

  fi

  # Status variable (a total of 3 chunks must be installed)
  local num_of_chunks_installed=0

  # Check if OS_FAMILY line is present in temp file
  if grep -q "^[[:space:]]*export D__OS_FAMILY='$D__OS_FAMILY'" \
    "$D_ENV_FILEPATH" 2>/dev/null
  then

    # Chunk 1: OS_FAMILY line

    # Announce status and increment counter
    dprint_debug 'Installed        : D__OS_FAMILY variable definition'
    (( ++num_of_chunks_installed ))

  else

    # Announce status
    dprint_debug 'Not installed    : D__OS_FAMILY variable definition'

  fi

  # Check if OS_DISTRO line is present in temp file
  if grep -q "^[[:space:]]*export D__OS_DISTRO='$D__OS_DISTRO'" \
    "$D_ENV_FILEPATH" 2>/dev/null
  then

    # Chunk 2: OS_DISTRO line

    # Announce status and increment counter
    dprint_debug 'Installed        : D__OS_DISTRO variable definition'
    (( ++num_of_chunks_installed ))

  else

    # Announce status
    dprint_debug 'Not installed    : D__OS_DISTRO variable definition'

  fi

  # Check if OS_PKGMGR line is present in temp file
  if grep -q "^[[:space:]]*export D__OS_PKGMGR='$D__OS_PKGMGR'" \
    "$D_ENV_FILEPATH" 2>/dev/null
  then

    # Chunk 3: OS_PKGMGR line

    # Announce status and increment counter
    dprint_debug 'Installed        : D__OS_PKGMGR variable definition'
    (( ++num_of_chunks_installed ))

  else

    # Announce status
    dprint_debug 'Not installed    : D__OS_PKGMGR variable definition'

  fi

  # Report based on number of chunks installed
  if [ $num_of_chunks_installed -eq 0 ]; then
    
    # Return not installed
    return 2

  elif [ $num_of_chunks_installed -ge 3 ]; then

    # Return fully installed
    return 1
  
  else

    # Return partly installed
    return 4

  fi
}

# Implement populating env file
d_env_vars_install()
{
  # Announce start
  dprint_debug -n 'Installing ~/.env.sh file'

  # Storage variables
  local temp_filepath=$( mktemp ) sed_cmd sed_cmds=() all_good=true
  
  # Dump current env file content into a temp file
  cat "$D_ENV_FILEPATH" >$temp_filepath 2>/dev/null

  # Check if OS_FAMILY line is present in temp file
  if grep -q '^[[:space:]]*export D__OS_FAMILY=' $temp_filepath 2>/dev/null
  then

    # At least one line is present: save sed command for future correction
    sed_cmd='s/^([[:space:]]*)export D__OS_FAMILY=.*$/'
    sed_cmd+="\\1export D__OS_FAMILY='$D__OS_FAMILY'/"
    sed_cmds+=( -e "$sed_cmd" )

    # Announce status
    dprint_debug 'Will modify      : D__OS_FAMILY variable definition'

  else

    # Line not present: append it to the bottom of temp file
    if printf "export D__OS_FAMILY='%s'\n" "$D__OS_FAMILY" >>"$temp_filepath"
    then

      # Announce status
      dprint_debug 'Appended         : D__OS_FAMILY variable definition'

    else

      # Announce and mark failure
      dprint_debug 'Failed to append : D__OS_FAMILY variable definition'
      all_good=false

    fi

  fi

  # Check if OS_DISTRO line is present in temp file
  if grep -q '^[[:space:]]*export D__OS_DISTRO=' $temp_filepath 2>/dev/null
  then

    # At least one line is present: save sed command for future correction
    sed_cmd='s/^([[:space:]]*)export D__OS_DISTRO=.*$/'
    sed_cmd+="\\1export D__OS_DISTRO='$D__OS_DISTRO'/"
    sed_cmds+=( -e "$sed_cmd" )

    # Announce status
    dprint_debug 'Will modify      : D__OS_DISTRO variable definition'

  else

    # Line not present: append it to the bottom of temp file
    if printf "export D__OS_DISTRO='%s'\n" "$D__OS_DISTRO" >>"$temp_filepath"
    then

      # Announce status
      dprint_debug 'Appended         : D__OS_DISTRO variable definition'

    else

      # Announce and mark failure
      dprint_debug 'Failed to append : D__OS_DISTRO variable definition'
      all_good=false

    fi

  fi

  # Check if OS_PKGMGR line is present in temp file
  if grep -q '^[[:space:]]*export D__OS_PKGMGR=' $temp_filepath 2>/dev/null
  then

    # At least one line is present: save sed command for future correction
    sed_cmd='s/^([[:space:]]*)export D__OS_PKGMGR=.*$/'
    sed_cmd+="\\1export D__OS_PKGMGR='$D__OS_PKGMGR'/"
    sed_cmds+=( -e "$sed_cmd" )

    # Announce status
    dprint_debug 'Will modify      : D__OS_PKGMGR variable definition'

  else

    # Line not present: append it to the bottom of temp file
    if printf "export D__OS_PKGMGR='%s'\n" "$D__OS_PKGMGR" >>"$temp_filepath"
    then

      # Announce status
      dprint_debug 'Appended         : D__OS_PKGMGR variable definition'

    else

      # Announce and mark failure
      dprint_debug 'Failed to append : D__OS_PKGMGR variable definition'
      all_good=false

    fi

  fi

  # If any sed commands must be carried out, do so
  if [ ${#sed_cmds[@]} -gt 0 ]; then

    # Fork depending of version of sed available
    if sed -r &>/dev/null; then
      sed -r "${sed_cmds[@]}" $temp_filepath >$temp_filepath
    else
      sed -E "${sed_cmds[@]}" $temp_filepath >$temp_filepath
    fi

    # Check status
    if [ $? -eq 0 ]; then

      # Announce status
      dprint_debug 'Modified         : Pre-existing variable definitions'

    else
    
      # Announce and mark failure
      dprint_debug 'Failed to modify : Pre-existing variable definitions'
      all_good=false
    
    fi

  fi

  # Check if there were errors
  if ! $all_good; then

    # Failed to properly modify temp file

    # Expunge temp file
    rm -f -- $temp_filepath

    # Report and return error
    dprint_debug "Failed to modify temporary copy of ~/.env.sh file"
    return 1

  fi

  # Remove original file
  if ! rm -f -- "$D_ENV_FILEPATH"; then

    # Expunge temp file
    rm -f -- $temp_filepath

    # Report and return error
    dprint_debug "Failed to overwrite ~/.env.sh file"
    return 1

  fi

  # Move modified temporary file into place
  if mv -n -- $temp_filepath "$D_ENV_FILEPATH"; then

    # All good: return success
    return 0

  else

    # Expunge temp file
    rm -f -- $temp_filepath

    # Failed to move: report and return error
    dprint_debug "Failed to move ~/.env.sh file into place"
    return 1
  
  fi
}

# Implement removing env file
d_env_vars_remove()
{
  # Check if env file exists
  if [ -f "$D_ENV_FILEPATH" ]; then

    # Announce
    dprint_debug -n 'Cleaning content of ~/.env.sh'

  else

    # No env file: announce and return success
    dprint_debug -n 'Nothing to remove: ~/.env.sh is not an existing file'
    return 0

  fi

  # Storage variables
  local temp_filepath=$( mktemp ) sed_cmd sed_cmds=() all_good=true
  
  # Dump current env file content into a temp file
  cat "$D_ENV_FILEPATH" >$temp_filepath 2>/dev/null

  # Check if OS_FAMILY line is present in temp file
  if grep -q '^[[:space:]]*export D__OS_FAMILY=' $temp_filepath 2>/dev/null
  then

    # At least one line is present: save sed command for future correction
    sed_cmd='s/^([[:space:]]*)export D__OS_FAMILY=.*$/'
    sed_cmd+="\\1export D__OS_FAMILY=/"
    sed_cmds+=( -e "$sed_cmd" )

    # Announce status
    dprint_debug 'Will modify      : D__OS_FAMILY variable definition'

  fi

  # Check if OS_DISTRO line is present in temp file
  if grep -q '^[[:space:]]*export D__OS_DISTRO=' $temp_filepath 2>/dev/null
  then

    # At least one line is present: save sed command for future correction
    sed_cmd='s/^([[:space:]]*)export D__OS_DISTRO=.*$/'
    sed_cmd+="\\1export D__OS_DISTRO=/"
    sed_cmds+=( -e "$sed_cmd" )

    # Announce status
    dprint_debug 'Will modify      : D__OS_DISTRO variable definition'

  fi

  # Check if OS_PKGMGR line is present in temp file
  if grep -q '^[[:space:]]*export D__OS_PKGMGR=' $temp_filepath 2>/dev/null
  then

    # At least one line is present: save sed command for future correction
    sed_cmd='s/^([[:space:]]*)export D__OS_PKGMGR=.*$/'
    sed_cmd+="\\1export D__OS_PKGMGR=/"
    sed_cmds+=( -e "$sed_cmd" )

    # Announce status
    dprint_debug 'Will modify      : D__OS_PKGMGR variable definition'

  fi

  # If any sed commands must be carried out, do so
  if [ ${#sed_cmds[@]} -gt 0 ]; then

    # Fork depending of version of sed available
    if sed -r &>/dev/null; then
      sed -r "${sed_cmds[@]}" $temp_filepath >$temp_filepath
    else
      sed -E "${sed_cmds[@]}" $temp_filepath >$temp_filepath
    fi

    # Check status
    if [ $? -eq 0 ]; then

      # Announce status
      dprint_debug 'Cleared          : Pre-existing variable definitions'

    else
    
      # Announce and mark failure
      dprint_debug 'Failed to clear  : Pre-existing variable definitions'
      all_good=false
    
    fi

  fi

  # Check if there were errors
  if ! $all_good; then

    # Failed to properly modify temp file

    # Expunge temp file
    rm -f -- $temp_filepath

    # Report and return error
    dprint_debug "Failed to modify temporary copy of ~/.env.sh file"
    return 1

  fi

  # Remove original file
  if ! rm -f -- "$D_ENV_FILEPATH"; then

    # Expunge temp file
    rm -f -- $temp_filepath

    # Report and return error
    dprint_debug "Failed to overwrite ~/.env.sh file"
    return 1

  fi

  # Move modified temporary file into place
  if mv -n -- $temp_filepath "$D_ENV_FILEPATH"; then

    # All good: return success
    return 0

  else

    # Expunge temp file
    rm -f -- $temp_filepath

    # Failed to move: report and return error
    dprint_debug "Failed to move ~/.env.sh file into place"
    return 1
  
  fi
}