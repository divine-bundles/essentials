#:title:        Divine shared runcom: 03-fixes
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.11.12
#:revremark:    Rewrite for D.d v2, pt. 2
#:created_at:   2019.04.09

## Universal shell bug fixes. Must use compatible syntax.
#
## Expect $D__SHELL to be set to name of shell being initialized, e.g., 'bash'.
#

##
## Locale fix
##

## Known problems cured by this fix include:
#.  * macOS: pipenv bug 'unknown locale'
#.    https://github.com/pypa/pipenv/issues/187
#

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


##
## GPG-Agent fix
## https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
##

if which gpg &>/dev/null || which gnupg &>/dev/null
then export GPG_TTY=$(tty); fi


##
## Hyper.js bug
## https://github.com/zeit/hyper/issues/2144#issuecomment-326741620
##

[ "$D__SHELL" = zsh ] && unsetopt PROMPT_SP


##
## FreeBSD screen clearing behavior with fullscreen utils
## https://unix.stackexchange.com/questions/328290/how-to-hide-fullscreen-cli-program-output-in-xterm-on-freebsd
##

[ "$D__OS_DISTRO" = freebsd ] && export TERM=xterm-clear