if [[ $- != *i* ]]; then
  # Shell is non-interactive. Be done now!
  return
fi

PS1="\[\e[92;1m\]\u@\h \[\e[94m\]\w \$\[\e[0m\] "

set -o vi

[ -r "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"
[ -r "$HOME/.config/shell/interactive.sh" ] && . "$HOME/.config/shell/interactive.sh"
