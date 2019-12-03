#:title:        Divine runcom sample: 06-addons.sh
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.12.03
#:revremark:    A round of asset polishing for the house
#:created_at:   2019.11.12

# Zsh addons, retrieved by the 'zsh-addons' deployment

# The following should be initialized toward the end of .zshrc
if [ -d "$HOME/.zsh/zsh-users/zsh-completions/src" ]; then
  fpath=($HOME/.zsh/zsh-users/zsh-completions/src $fpath)
fi
for ii in zsh-syntax-highlighting zsh-autosuggestions; do
  ii="$HOME/.zsh/zsh-users/$ii/$ii.zsh"
  [ -f "$ii" ] && source "$ii"
done
unset ii