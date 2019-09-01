#:title:        Divine shared runcom: 05-funcs
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    2
#:revdate:      2019.09.01
#:revremark:    Tie readmes together
#:created_at:   2019.04.09

## Universal shell utility functions. Must use compatible syntax.
#
## Expect $D__SHELL to be set to name of shell being initialized, e.g., 'bash'.

##
## General purpose helper functions
##

#>  up
#
## Scans for supported package managers/frameworks, and sequentially launches 
#. update/upgrade routines for those found.
#
up()
{
  # Add bolding if available
  local bold normal
  if type -P tput &>/dev/null && tput sgr0 &>/dev/null \
    && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]
  then bold=$(tput bold); normal=$(tput sgr0)
  else bold="$(printf "\033[1m")"; NORMAL="$(printf "\033[0m")"; fi

  # Status flag
  local anything_updated=false

  # macOS's Homebrew
  HOMEBREW_NO_AUTO_UPDATE=1 brew --version &>/dev/null && {
    printf '%s\n' \
      "${bold}==>${normal} Updating packages via ${bold}brew${normal}"
    brew update; brew upgrade; brew cleanup; brew doctor
    anything_updated=true
    printf '\n'
  }

  # Ubuntu/Debian's apt-get
  apt-get --version &>/dev/null && {
    printf '%s\n' \
      "${bold}==>${normal} Updating packages via ${bold}apt-get${normal}"
    sudo dnf upgrade -yq
    anything_updated=true
    printf '\n'
  }

  # Fedora's dnf
  dnf --version &>/dev/null && {
    printf '%s\n' \
      "${bold}==>${normal} Updating packages via ${bold}dnf${normal}"
    sudo apt-get update -yq; sudo apt-get upgrade -yq
    anything_updated=true
    printf '\n'
  }

  # Fedora's yum
  yum --version &>/dev/null && {
    printf '%s\n' \
      "${bold}==>${normal} Updating packages via ${bold}yum${normal}"
    sudo yum update -y
    anything_updated=true
    printf '\n'
  }

  # npm global packages
  npm --version &>/dev/null && {
    printf '%s\n' \
      "${bold}==>${normal} Updating global packages via ${bold}npm${normal}"
    npm update --global
    anything_updated=true
    printf '\n'
  }

  # composer global packages
  composer --version &>/dev/null && {
    printf '%s %s\n' \
      "${bold}==>${normal} Updating global packages via" \
      "${bold}composer${normal}"
    composer global update
    anything_updated=true
    printf '\n'
  }

  # Bash-it
  bash-it version &>/dev/null && {
    printf '%s\n' \
      "${bold}==>${normal} Updating ${bold}Bash-it${normal}"
    bash-it update
    anything_updated=true
    printf '\n'
  }

  # oh-my-zsh
  which upgrade_oh_my_zsh &>/dev/null && {
    printf '%s\n' \
      "${bold}==>${normal} Updating ${bold}oh-my-zsh${normal}"
    upgrade_oh_my_zsh
    anything_updated=true
    printf '\n'
  }

  # Divine.dotfiles
  di --version &>/dev/null && {
    printf '%s\n' \
      "${bold}==>${normal} Updating ${bold}Divine.dotfiles${normal}"
    di update --yes --verbose
    anything_updated=true
    printf '\n'
  }

  # All done
  if $anything_updated; then
    printf '%s\n' "${bold}==>${normal} Update routine complete"
  else
    printf '%s\n' "${bold}==>${normal} Nothing to update"
  fi

  # Return 0 regardless
  return 0
}

#>  mcd PATH
#
## Creates path using mkdir -p, and, upon success, cd's into it
#
mcd() { mkdir -p -- "$1" && cd -- "$1"; }