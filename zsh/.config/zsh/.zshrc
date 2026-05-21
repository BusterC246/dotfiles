autoload -Uz colors && colors
PS1="%F{green}%B%n@%m%f%B%F{blue} %~ %# %f"

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=1000
SAVEHIST=1000
mkdir -p -- "${HISTFILE:h}"

setopt extendedglob
unsetopt autocd beep

bindkey -v
KEYTIMEOUT=1

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zmodload zsh/complist
_compdump="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
mkdir -p -- "${_compdump:h}"
compinit -d "$_compdump"
_comp_options+=(globdots)

[[ -r "$HOME/.config/shell/interactive.sh" ]] && source "$HOME/.config/shell/interactive.sh"

source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
