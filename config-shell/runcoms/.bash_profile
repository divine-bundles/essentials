#:title:        Divine runcom: .bash_profile
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revnumber:    3
#:revdate:      2019.08.07
#:revremark:    Grand removal of non-ASCII chars
#:created_at:   2019.04.05

## Startup file for login Bash shells
#
## Content:
#.  * Commands exclusive to login shells, if any
#.  * Source ~/.bashrc (Bash doesn't do this for login shells)
#

##
## Commands exclusive to login shells, if any
##

# ... login shell commands go here ...


##
## Source ~/.bashrc (Bash doesn't do this for login shells)
##

# Source .bashrc in home directory
[ -r ~/.bashrc -a -f ~/.bashrc ] && source ~/.bashrc