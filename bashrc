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
alias ls="ls -A -F --group-directories-first"
alias mpa="mpv --no-audio-display"
alias wget=wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"

PS1="\[\033[1;32m\]\W \[\033[1;34m\]\$ \[\033[0m\]"

export EDITOR="micro"
export HISTCONTROL="ignoredups"
export PATH="$PATH:~/.cargo/bin:/opt/idea-community/bin"

# Directories
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java -Dawt.toolkit.name=WLToolkit"
export BASH_COMPLETION_USER_FILE="$XDG_CONFIG_HOME"/bash-completion/bash_completion
export DISCORD_USER_DATA_DIR="${XDG_DATA_HOME}"
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export GEM_HOME="$XDG_DATA_HOME/ruby/gems"
export GEM_PATH="$XDG_DATA_HOME/ruby/gems"
export GEM_SPEC_CACHE="$XDG_DATA_HOME/ruby/specs"
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export HISTFILE="$XDG_STATE_HOME"/bash/history
export MIX_XDG="true"
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export PYTHON_HISTORY=$XDG_STATE_HOME/python/history
export PYTHONPYCACHEPREFIX=$XDG_CACHE_HOME/python
export PYTHONUSERBASE=$XDG_DATA_HOME/python
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo 
export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export WINEPREFIX="/mnt/media/wine_prefixes/.wine"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
