#:title:        Divine shared runcom: 02-env
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    8
#:revdate:      2019.08.07
#:revremark:    Grand removal of non-ASCII chars
#:created_at:   2019.04.09

## Universal shell environment variables. Must use compatible syntax.
#
## Expect $D__SHELL to be set to name of shell being initialized, e.g., 'bash'.

##
## Personal binaries directory
##

[ -d "$HOME/.bin" ] && export PATH="$PATH:$HOME/.bin"
[ -d "$HOME/bin" ] && export PATH="$PATH:$HOME/bin"
[ -d "$HOME/.pbin" ] && export PATH="$PATH:$HOME/.pbin"


##
## macOS Homebrew: No analytics
##

[ "$D__OS_PKGMGR" = brew ] && export HOMEBREW_NO_ANALYTICS=1


##
## Ruby gems
##

if gem env gemdir &>/dev/null; then
  GEMS_DIR="$( gem env gemdir )/bin"
  [ -d "$GEMS_DIR" ] && export PATH="$GEMS_DIR:$PATH"
  unset GEMS_DIR
fi


##
## Composer globals
##

[ -d "$HOME/.composer/vendor/bin" ] \
  && export PATH="$HOME/.composer/vendor/bin:$PATH"


##
## macOS Homebrew: pyenv
##

if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$( pyenv init - )"
fi


##
## macOS Homebrew: Lesspipe
##

if [ -x /usr/local/bin/lesspipe.sh ]; then
  export LESSOPEN="| /usr/local/bin/lesspipe.sh %s"
  export LESS_ADVANCED_PREPROCESSOR=1
  export LESS=' -R '
fi