#:title:        Divine runcom: .zshrc
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.04.05

## Startup file for interactive zsh shells
#
## Content:
#.  * Fail-safe against non-interactive shells
#.  * Set and export environmental D__* variables
#.  * Source all *.zsh and *.sh files in ~/.runcoms dir, sorted 
#.    alphanumerically
#.  * Source ~/.runcoms.zsh, if it exists, for box-specific corrections
#.  * Source ~/.runcoms.sh, if it exists, for box-specific corrections
#

##
## Fail-safe against non-interactive shells
##

# Rely on ‘interactive’ option to be set
[[ -o interactive ]] || return


##
## Set and export environmental D__* variables
##

# Current shell is zsh, obviously
export D__SHELL=zsh

# Source ~/.env.sh, if it exists, for box-specific environment variables
[ -f ~/.env.sh -a -r ~/.env.sh ] && source ~/.env.sh


##
## Source all *.zsh and *.sh files in ~/.runcoms dir, sorted 
#. alphanumerically
##

# If ‘nullglob’ option is unset, set it and remember to restore it after
[[ -o G ]] || { set -G; restore_nullglob=( set +G ); }

## Globbing sorts entries alphanumerically. This can be taken advantage of to 
#. provide for overriding.
for script_path in ~/.runcoms/*(D); do
  [[ $script_path = *.zsh || $script_path = *.sh ]] && source "$script_path"
done; unset script_path

# Restore state of ‘nullglob’ option
$restore_nullglob; unset restore_nullglob


##
## Source ~/.runcoms.zsh, if it exists, for box-specific corrections
## Source ~/.runcoms.sh, if it exists, for box-specific corrections
##

[ -f ~/.runcoms.zsh -a -r ~/.runcoms.zsh ] && source ~/.runcoms.zsh
[ -f ~/.runcoms.sh -a -r ~/.runcoms.sh ] && source ~/.runcoms.sh


##
## Graceful exit
##

return 0