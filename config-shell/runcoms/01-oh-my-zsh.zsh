#:title:        Divine runcom sample: 01-oh-my-zsh.zsh
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.12.12
#:revremark:    Mirror move of official oh-my-zsh repository
#:created_at:   2019.04.09

# Zsh shell framework initialization

##
## oh-my-zsh <https://ohmyz.sh>
##

## Assumes oh-my-zsh is cloned to ~/.oh-my-zsh, and that entry script in its 
#. root is called oh-my-zsh.sh, which is unlikely to change.
#
## Deployment oh-my-zsh.dpl.sh clones oh-my-zsh in that same fashion.
#

# Check if oh-my-zsh main script is a readable file
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" -a -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]
then

  ## oh-my-zsh startup configuration follows within the if-statement. Latest 
  #. template from the developers of oh-my-zsh can be found at:
  #.  https://github.com/ohmyzsh/ohmyzsh/blob/master/templates/zshrc.zsh-template

  # Only the (*)-marked commands are required to run oh-my-zsh

  # (*) Path to oh-my-zsh installation
  export ZSH="$HOME/.oh-my-zsh"

  # Load theme
  ZSH_THEME=laidbare

  # Load plugins
  plugins=()

  # Disable marking untracked files under VCS as dirty (faster repo checks)
  DISABLE_UNTRACKED_FILES_DIRTY=false

  # Prevent oh-my-zsh update prompts
  DISABLE_UPDATE_PROMPT=true
  DISABLE_AUTO_UPDATE=true

  # (*) Load oh-my-zsh
  source "$ZSH/oh-my-zsh.sh"

fi