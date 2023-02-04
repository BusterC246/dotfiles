#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls="ls --color=auto"
alias la="ls -a --color=auto"
alias mpa="mpv --no-audio-display"

# PS1='[\u@\h \W]\$ '
PS1="\[\033[1;32m\]\W \[\033[1;34m\]>\[\033[0m\] "

export EDITOR="nvim"
export PATH="$PATH:~/.cargo/bin"
