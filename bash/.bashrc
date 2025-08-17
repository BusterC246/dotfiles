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

PS1="\[\e[92;1m\]\u@\h \[\e[94m\]\w \$\[\e[0m\] "

source ~/.profile

# Aliases
alias ls="ls -F --group-directories-first --color=always"
alias mpa="mpv --no-audio-display"
alias mvn="mvn -gs '$XDG_CONFIG_HOME'/maven/settings.xml"
alias yarn="yarn --use-yarnrc '$XDG_CONFIG_HOME'/yarn/config"
alias wget="wget --hsts-file='$XDG_CACHE_HOME'/wget-hsts"
alias xrdb="xrdb -load '$XDG_CONFIG_HOME'/X11/xresources"
