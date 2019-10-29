#:title:        Divine Bash runcom: 01-config
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.29
#:revremark:    Update for D.d v2
#:created_at:   2019.04.09

## Bash shell configuration

##
## General configuration
##

# Disable mail checks:
shopt -u mailwarn
unset MAILCHECK


##
## bash_completion
##

## Load bash_completion, if it is available, but only if not in 'posix' mode, 
#. where a Tab key should produce a tab character
#
if ! shopt -oq posix; then case $D__OS_FAMILY in
  macos)
    ## This will pull Homebrew's built-in completions and also those from 
    #. 'bash-completion' formula, should it be installed.
    #
    ## Reference: https://docs.brew.sh/Shell-Completion
    #
    if [ "$D__OS_PKGMGR" = brew ]; then HOMEBREW_PREFIX="$( brew --prefix )"
      if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
      else
        for II in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
        do [[ -r "$II" ]] && source "$II"; done; unset II
      fi
    fi;;
  *)
    # Try possible locations for 'bash-completion' init script
    if [ -f /etc/bash_completion ]; then source /etc/bash_completion
    elif [ -f /etc/profile.d/bash_completion.sh ]
    then source /etc/profile.d/bash_completion.sh
    elif [ -f /usr/share/bash-completion/bash_completion ]
    then source /usr/share/bash-completion/bash_completion; fi;;
esac; fi