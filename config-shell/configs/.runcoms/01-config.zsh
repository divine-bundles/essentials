#:title:        Divine zsh runcom: 01-config
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.10.24
#:revremark:    Rewrite for D.d v2
#:created_at:   2019.04.09

## zsh shell configuration

##
## General configuration
##

# Enable extended glob
setopt extended_glob


##
## macOS-specific configuration
##

if [ "$D__OS_PKGMGR" = brew ]; then
  # Homebrew zsh-completions
  fpath=(/usr/local/share/zsh-completions $fpath)

  # Homebrew zsh-syntax-highlighting
  [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] \
    && source \
    /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # Homebrew zsh-autosuggestions
  [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] \
    && source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi