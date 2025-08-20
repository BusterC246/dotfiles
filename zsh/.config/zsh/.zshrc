source ~/.profile

autoload -U colors && colors
PS1="%F{green}%B%n@%m%f%B%F{blue} %~ %# %f"

HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt extendedglob
unsetopt autocd beep

bindkey -v
export KEYTIMEOUT=1

# Auto complete
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# Aliases
alias ls="ls -F --group-directories-first --color=always"
alias mpa="mpv --no-audio-display"
alias mvn="mvn -gs '$XDG_CONFIG_HOME'/maven/settings.xml"
alias yarn="yarn --use-yarnrc '$XDG_CONFIG_HOME'/yarn/config"
alias wget="wget --hsts-file='$XDG_CACHE_HOME'/wget-hsts"
alias xrdb="xrdb -load '$XDG_CONFIG_HOME'/X11/xresources"

source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
