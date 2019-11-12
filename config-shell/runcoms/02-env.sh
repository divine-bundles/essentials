#:title:        Divine shared runcom: 02-env
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.11.12
#:revremark:    Rewrite for D.d v2, pt. 2
#:created_at:   2019.04.09

## Universal shell environment variables. Must use compatible syntax.
#
## Expect $D__SHELL to be set to name of shell being initialized, e.g., 'bash'.
#

##
## Personal binaries directory
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
  [ -z ${PYENV_SHELL+isset} ] && eval "$( pyenv init - )"
fi


##
## macOS Homebrew: Lesspipe
##

if [ -x /usr/local/bin/lesspipe.sh ]; then
  export LESSOPEN="| /usr/local/bin/lesspipe.sh %s"
  export LESS_ADVANCED_PREPROCESSOR=1
  export LESS=' -R '
fi