local return_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"

PROMPT=$'\n''$return_status%{$fg_bold[cyan]%}$( basename -- \
  "$( pwd )" )%{$reset_color%} '