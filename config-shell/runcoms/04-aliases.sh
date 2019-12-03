#:title:        Divine runcom sample: 04-aliases.sh
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.12.03
#:revremark:    A round of asset polishing for the house
#:created_at:   2019.04.09

## Universal shell utility aliases. Must use compatible syntax.
#
## Expect $D__SHELL to be set to name of shell being initialized, e.g., 'bash'.
#

##
## Shorthand for 'ls' command
##

## ls
case $D__OS_FAMILY in
  macos|bsd)
      ## BSD ls:
      #.  -F  - Add symbolic indication of file types
      #.  -G  - Colorize output
      alias ls='\ls -FG';;
  linux|wsl)
      ## GNU ls:
      #.  -F              - Add symbolic indication of file types
      #.  --color=always  - Colorize output
      alias ls='\ls -F --color=always';;
  *)  ## Other OS:
      #.  -F  - Add symbolic indication of file types
      alias ls='\ls -F';;
esac

## lsa:
#.  -a  - Include names starting with dots
alias lsa='ls -a'

## ll (long-ish format):
#.  -h  - Base-2 sizes with unit suffixes
#.  -l  - Long format, one line per file
alias ll='ls -hl'

## la (ll + lsa):
#.  -a  - Include names starting with dots
alias la='ll -a'


##
## Shorthand for basic filesystem manipulations
##

alias rmr='\rm -rf'
alias md='\mkdir -p'


##
## Directory navigation aliases
##

alias -- -='\cd -'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'


##
## Shell switching aliases
##

case $D__SHELL in
  bash) alias zsh='/usr/bin/env zsh';;
  zsh)  alias bash='/usr/bin/env bash';;
esac


##
## Git aliases
##

alias gaa='\git add --all'
alias grc='\git rm --cached -rf .'
alias gs='\git status'
alias gu='\git rm --cached -rf . &>/dev/null; \git add --all; \git status'
alias gc='\git commit'
alias gp='\git push'
alias gl='\git --no-pager log --oneline --all --graph --decorate=full -20'
alias gll='\git log --all --decorate=full --show-signature'


##
## $PATH aliases
##

alias path='\printf "%b\n" "${PATH//:/\\n}\n"'
alias manpath='\printf "%b\n" "${MANPATH//:/\\n}\n"'
alias libpath='\printf "%b\n" "${LD_LIBRARY_PATH//:/\\n}\n"'


##
## Colorful tree:
#.  -C  - Colorize output
#.  -u  - (files) Include user's name/id
#.  -s  - (files) Include size
#.  -h  - (files) Human-readable sizes
#.  -N  - Print non-printables as is
##
if tree --version &>/dev/null; then
  alias tree='\tree -CsuhN'
fi


## 
## More informative which
##
alias which='\type -a'


##
## Disk usage for file:
#.  -k    - Block counts in Kbytes (1024 bytes)
#.  -h    - Human-readable sizes
#.  -d 1  - Go one level deep (list current dir)
##
alias du='\du -kh -d 1'


##
## Free space:
#.  -k  - Block counts in Kbytes (1024 bytes)
#.  -h  - Human-readable sizes
##
alias df='\df -kh'