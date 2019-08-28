#:title:        Divine runcom: .bashrc
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    5
#:revdate:      2019.08.28
#:revremark:    Update to new queue API
#:created_at:   2019.04.05

## Startup file for interactive Bash shells
#
## Content:
#.  * Fail-safe against non-interactive shells
#.  * Set and export environmental D__* variables
#.  * Source all *.bash and *.sh files in ~/.runcoms dir, sorted 
#.    alphanumerically
#.  * Source ~/.runcoms.bash, if it exists, for box-specific corrections
#.  * Source ~/.runcoms.sh, if it exists, for box-specific corrections
#

##
## Fail-safe against non-interactive shells
##

# Rely on $PS1 to be empty in a non-interactive shell
[ -n "$PS1" ] || return


##
## Set and export environmental D__* variables
##

# Current shell is Bash, obviously
export D__SHELL=bash

# Source ~/.env.sh, if it exists, for box-specific environment variables
[ -f ~/.env.sh -a -r ~/.env.sh ] && source ~/.env.sh


##
## Source all *.bash and *.sh files in ~/.runcoms dir, sorted 
#. alphanumerically
##

# Save current state of 'dotglob' and 'nullglob' options
restore_opts=( "$( shopt -p dotglob )" "$( shopt -p nullglob )" )

# Set both 'dotglob' and 'nullglob' options
shopt -s dotglob nullglob

## Globbing sorts entries alphanumerically. This can be taken advantage of to 
#. provide for overriding.
for script_path in ~/.runcoms/*; do
  [[ $script_path = *.bash || $script_path = *.sh ]] && source "$script_path"
done; unset script_path

# Restore state of 'dotglob' and 'nullglob' options
for cmd in "${restore_opts[@]}"; do $cmd; done; unset cmd restore_opts


##
## Source ~/.runcoms.bash, if it exists, for box-specific corrections
## Source ~/.runcoms.sh, if it exists, for box-specific corrections
##

[ -f ~/.runcoms.bash -a -r ~/.runcoms.bash ] && source ~/.runcoms.bash
[ -f ~/.runcoms.sh -a -r ~/.runcoms.sh ] && source ~/.runcoms.sh


##
## Graceful exit
##

return 0