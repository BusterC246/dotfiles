if command -v keychain >/dev/null 2>&1; then
  if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    eval "$(keychain --absolute --dir "$XDG_RUNTIME_DIR/keychain" --eval --quiet id_ed25519)"
  else
    eval "$(keychain --eval --quiet id_ed25519)"
  fi
fi

alias keychain='keychain --absolute --dir "$XDG_RUNTIME_DIR/keychain"'
alias ls='ls -F --group-directories-first --color=always'
alias mpa='mpv --no-audio-display'
alias mvn='mvn --settings "$XDG_CONFIG_HOME/maven/settings.xml"'
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
alias xrdb='xrdb -load "$XDG_CONFIG_HOME/X11/xresources"'
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"'

# Reload environment without rebooting. Useful after changing env vars in
# env.sh; source this file again or run `shell-reload` in any running shell.
shell-reload() {
  . "$XDG_CONFIG_HOME/shell/env.sh"
  . "$XDG_CONFIG_HOME/shell/interactive.sh"
}
alias env-reload='. "$XDG_CONFIG_HOME/shell/env.sh"'
