#:title:        Divine Bash runcom: 01-config
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.24
#:revremark:    Rewrite for D.d v2
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
if ! shopt -oq posix; then
  case $D__OS_FAMILY in
    macos)  [ -f /usr/local/etc/bash_completion ] \
              && source /usr/local/etc/bash_completion
            ;;
    *)      [ -f /etc/bash_completion ] && source /etc/bash_completion;;
  esac
fi