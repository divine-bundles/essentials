#:title:        Divine zsh runcom: 00-frameworks
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    3
#:revdate:      2019.08.28
#:revremark:    Update to new queue API
#:created_at:   2019.04.09

# zsh shell framework initialization

##
## oh-my-zsh <https://ohmyz.sh>
##

## Assumes it is cloned to ~/.oh-my-zsh, and that entry script in its root is 
#. called oh-my-zsh.sh, which is unlikely to change.
#
## Deployment oh-my-zsh.dpl.sh clones oh-my-zsh in that exact fashion.
#

# Require that entry script is present for the entire configuration
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" \
  -a -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then

  # Path to oh-my-zsh installation
  export ZSH="$HOME/.oh-my-zsh"

  # Display red dots whilst waiting for completion.
  COMPLETION_WAITING_DOTS=true

  # Disable marking untracked files under VCS as dirty.
  # This makes repository status check for large repositories much, much faster.
  DISABLE_UNTRACKED_FILES_DIRTY=false

  # Prevent oh-my-zsh from bugging for updates
  DISABLE_UPDATE_PROMPT=true
  DISABLE_AUTO_UPDATE=true

  # Clear tab title
  # DISABLE_AUTO_TITLE="true"

  # List of oh-my-zsh plugins from ~/.oh-my-zsh/plugins/*
  # Custom plugins added to ~/.oh-my-zsh/custom/plugins/
  # Format: plugins=(rails git textmate ruby lighthouse)
  plugins=( \
    # vi-mode-custom \
  )

  # oh-my-zsh theme
  ZSH_THEME=laidbare

  # User name
  DEFAULT_USER="$( whoami )"

  # Source config
  source "$ZSH/oh-my-zsh.sh"

fi