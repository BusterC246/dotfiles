#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls='ls --color=auto'
alias la='ls -a --color=auto'
alias sudo='doas'
alias pacman='pacman --color auto'
alias mc="micro"
alias neofetch="neofetch --disable uptime --disable title"

# Shell Prompt
#PS1='\[\033[1;34m\]\u\[\033[1;32m\] \W \$\[\033[0m\] '
PS1='\[\033[1;32m\] \W \[\033[1;34m\]>\[\033[0m\] '

# Rust
. "$HOME/.cargo/env"

# Other
export EDITOR=micro
