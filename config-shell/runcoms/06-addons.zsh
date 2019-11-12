#:title:        Divine shared runcom: 06-addons
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.11.12
#:revremark:    Rewrite for D.d v2, pt. 2
#:created_at:   2019.11.12

# Zsh addons, retrieved by the 'zsh-addons' deployment

# The following should be initialized toward the end of .zshrc
if [ -d "$HOME/.zsh/zsh-users/zsh-completions/src" ]
then fpath=($HOME/.zsh/zsh-users/zsh-completions/src $fpath); fi
for ii in zsh-syntax-highlighting zsh-autosuggestions; do
  ii="$HOME/.zsh/zsh-users/$ii/$ii.zsh"; [ -f "$ii" ] && source "$ii"
done; unset ii