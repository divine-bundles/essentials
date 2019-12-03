#:title:        Divine asset sample: laidbare.zsh-theme
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.12.03
#:revremark:    A round of asset polishing for the house
#:created_at:   2019.12.03

# A minimalistic Zsh theme that can be loaded via oh-my-zsh framework.

local return_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"

PROMPT=$'\n''$return_status%{$fg_bold[cyan]%}$( basename -- "$( pwd )" )%{$reset_color%} '