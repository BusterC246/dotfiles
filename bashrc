# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.
alias mpa="mpv --no-audio-display"
alias wget=wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"

PS1="\[\033[1;32m\]\W \[\033[1;34m\]\$ \[\033[0m\]"

export EDITOR="micro"
export HISTCONTROL="ignoredups"
export PATH="$PATH:~/.cargo/bin"

# Directories
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export GEM_HOME="$XDG_DATA_HOME/ruby/gems"
export GEM_PATH="$XDG_DATA_HOME/ruby/gems"
export GEM_SPEC_CACHE="$XDG_DATA_HOME/ruby/specs"
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export WINEPREFIX="/mnt/media/.wine"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}
export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
