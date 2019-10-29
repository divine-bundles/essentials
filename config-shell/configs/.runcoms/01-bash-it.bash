#:title:        Divine Bash runcom: 00-bash-it
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.29
#:revremark:    Update for D.d v2
#:created_at:   2019.04.09

## Bash shell framework initialization

##
## Bash-it <https://github.com/Bash-it/bash-it>
##

## Assumes Bash-it is cloned to ~/.bash-it (with dash), and that entry script 
#. in its root is called bash_it.sh (with underscore), which is unlikely to 
#. change.
#
## Deployment bash-it.dpl.sh clones Bash-it in that same fashion.
#

# Check if Bash-it main script is a readable file
if [ -f "$HOME/.bash-it/bash_it.sh" -a -r "$HOME/.bash-it/bash_it.sh" ]; then

  ## Bash-it startup configuration follows within the if-statement. Latest 
  #. template from the developers of Bash-it can be found at:
  #.  https://github.com/Bash-it/bash-it/blob/master/template/bash_profile.template.bash

  # Only the (*)-marked commands are required to run Bash-it

  # (*) Path to Bash-it installation
  export BASH_IT="$HOME/.bash-it"

  # Load theme
  export BASH_IT_THEME=laidbare

  # Turn off version control status checking within the prompt for all themes
  export SCM_CHECK=false

  # (*) Load Bash-it
  source "$BASH_IT/bash_it.sh"

fi