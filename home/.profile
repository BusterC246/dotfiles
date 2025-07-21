export HISTCONTROL=ignoredups
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
export PATH="$PATH":"$XDG_DATA_HOME"/cargo/bin:/opt/idea-community/bin:"$HOME"/.config/emacs/bin

export LIBVA_DRIVER_NAME=radeonsi
export RADV_PERFTEST=video_decode
export RUSTICL_ENABLE=radeonsi
export VDPAU_DRIVER=radeonsi

# Directories
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export BASH_COMPLETION_USER_FILE="$XDG_CONFIG_HOME"/bash-completion/bash_completion
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export DISCORD_USER_DATA_DIR="$XDG_DATA_HOME"
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export GEM_HOME="$XDG_DATA_HOME"/ruby/gems
export GEM_PATH="$XDG_DATA_HOME"/ruby/gems
export GEM_SPEC_CACHE="$XDG_DATA_HOME"/ruby/specs
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export HISTFILE="$XDG_STATE_HOME"/bash/history
export MIX_XDG=true
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export PYTHON_HISTORY="$XDG_STATE_HOME"/python/history
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME"/python
export PYTHONUSERBASE="$XDG_DATA_HOME"/python
export REDISCLI_HISTFILE="$XDG_STATE_HOME"/redis/rediscli_history
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo 
export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export WGETRC="$XDG_CONFIG_HOME"/wgetrc
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
