#:title:        Divine shared runcom: 04-aliases
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    1.0.0-RELEASE
#:revdate:      2019.06.30
#:revremark:    Release version
#:created_at:   2019.04.09

## Universal shell utility aliases. Must use compatible syntax.
#
## Expect $D_SHELL to be set to name of shell being initialized, e.g., ‘bash’.

##
## Specific directory access
##

# Developer directory
if [ -d "$HOME/Developer" ]; then
  alias dev="\cd $HOME/Developer"
  alias   D="\cd $HOME/Developer"
fi

# Sites directory
if [ -d "$HOME/Sites" ]; then
  alias si="\cd $HOME/Sites"
  alias  S="\cd $HOME/Sites"
fi


##
## Specific executable access
##

# Veracrypt executable
if [ -x /Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt ]; then
  alias veracrypt='/Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt -t'
fi


##
## Shorthand for listing directory contents
##

if [ "$OS_FAMILY" = macos -o "$OS_FAMILY" = bsd ]; then

  # BSD ls

  ## Basic ls:
  #.  -F  - Add symbolic indication of file types
  #.  -G  - Colorize output
  alias ls='ls -FG'

elif [ "$OS_FAMILY" = linux ]; then

  # GNU ls

  ## Basic ls:
  #.  -F              - Add symbolic indication of file types
  #.  --color=always  - Colorize output
  alias ls='ls -F --color=always'

else

  # Other OS

  ## Basic ls:
  #.  -F  - Add symbolic indication of file types
  alias ls='ls -F'

fi

## Basic ls with dotfiles
#.  -a  - Include names starting with dots
alias lsa='ls -a'

## Long format:
#.  -h  - Base-2 sizes with unit suffixes
#.  -l  - Long format, one line per file
alias ll='ls -hl'

## Long format with dotfiles
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

if [ "$D_SHELL" = bash ]; then
  # Switch to zsh
  alias zsh='/usr/bin/env zsh'
elif [ "$D_SHELL" = zsh ]; then
  # Switch to bash
  alias bash='/usr/bin/env bash'
fi


##
## Git aliases
##

alias gaa='\git add --all'
alias grc='\git rm --cached -rf .'
alias  gs='\git status'
alias  gu='\git rm --cached -rf . &>/dev/null; \git add --all; \git status'
alias  gc='\git commit -S'
alias  gp='\git push'
alias  gl='\git --no-pager log --oneline --all --graph --decorate=full -20'
alias gll='\git log --all --decorate=full --show-signature'


##
## $PATH aliases
##

alias path='\printf "${PATH//:/\\n}\n"'
alias manpath='\printf "${MANPATH//:/\\n}\n"'
alias libpath='\printf "${LD_LIBRARY_PATH//:/\\n}\n"'


##
## Colorful tree:
#.  -C  - Colorize output
#.  -u  - (files) Include user’s name/id
#.  -s  - (files) Include size
#.  -h  - (files) Human-readable sizes
#.  -N  - Print non-printables as is
##
alias tree='\tree -CsuhN'


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
alias du='du -kh -d 1'


##
## Free space:
#.  -k  - Block counts in Kbytes (1024 bytes)
#.  -h  - Human-readable sizes
##
alias df='df -kh'