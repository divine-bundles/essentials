#:title:        Divine runcom sample: 02-env.sh
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.12.03
#:revremark:    Silence bash deprecation on Catalina
#:created_at:   2019.04.09

## Universal shell environment variables. Must use compatible syntax.
#
## Expect $D__SHELL to be set to name of shell being initialized, e.g., 'bash'.
#

##
## Personal /**/bin directories
##

for DIR in .bin bin .pbin; do if [ -d "$HOME/$DIR" ]; then
  [[ :$PATH: = *":$HOME/$DIR:"* ]] || export PATH="$PATH:$HOME/$DIR"
fi; done; unset DIR


##
## macOS Homebrew: No analytics
##

[ "$D__OS_PKGMGR" = brew ] && export HOMEBREW_NO_ANALYTICS=1


##
## Ruby gems
##

if gem env gemdir &>/dev/null; then
  GEMS_DIR="$( gem env gemdir )/bin"
  if [ -d "$GEMS_DIR" ]; then
    [[ :$PATH: = *":$GEMS_DIR:"* ]] || export PATH="$GEMS_DIR:$PATH"
  fi; unset GEMS_DIR
fi


##
## Composer globals
##

if [ -d "$HOME/.composer/vendor/bin" ]; then
  [[ :$PATH: = *":$HOME/.composer/vendor/bin:"* ]] \
    || export PATH="$HOME/.composer/vendor/bin:$PATH"
fi


##
## macOS Homebrew: pyenv
##

if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  if [ -d "$PYENV_ROOT/bin" ]; then
    [[ :$PATH: = *":$PYENV_ROOT/bin:"* ]] \
      || export PATH="$PYENV_ROOT/bin:$PATH"
  fi
  [ "$PYENV_SHELL" = "$D__SHELL" ] || eval "$( pyenv init - )"
fi


##
## macOS Homebrew: Lesspipe
##

if [ -x /usr/local/bin/lesspipe.sh ]; then
  export LESSOPEN='| /usr/local/bin/lesspipe.sh %s'
  export LESS_ADVANCED_PREPROCESSOR=1
  export LESS=' -R '
fi


##
## macOS Catalina & onward: silence warning about default shell change
##

[ "$D__OS_FAMILY" = macos ] && export BASH_SILENCE_DEPRECATION_WARNING=1