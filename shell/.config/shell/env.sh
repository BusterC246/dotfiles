if [ "${__SHELL_ENV_SH_LOADED:-}" = "1" ]; then
  return 0
fi
__SHELL_ENV_SH_LOADED=1
export __SHELL_ENV_SH_LOADED

: "${XDG_CACHE_HOME:="$HOME/.cache"}"
: "${XDG_CONFIG_HOME:="$HOME/.config"}"
: "${XDG_DATA_HOME:="$HOME/.local/share"}"
: "${XDG_STATE_HOME:="$HOME/.local/state"}"
export XDG_CACHE_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  _xdg_rt="/run/user/$(id -u)"
  if [ -d "$_xdg_rt" ] && [ -w "$_xdg_rt" ]; then
    XDG_RUNTIME_DIR="$_xdg_rt"
    export XDG_RUNTIME_DIR
  fi
  unset _xdg_rt
fi

XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-"$HOME/Pictures"}"
if [ -r "$XDG_CONFIG_HOME/user-dirs.dirs" ]; then
  . "$XDG_CONFIG_HOME/user-dirs.dirs"
fi
export XDG_PICTURES_DIR

mkdir -p \
  "$XDG_CACHE_HOME" \
  "$XDG_CACHE_HOME/bundle" \
  "$XDG_CACHE_HOME/npm" \
  "$XDG_CACHE_HOME/nuget" \
  "$XDG_CACHE_HOME/zsh" \
  "$XDG_CONFIG_HOME" \
  "$XDG_CONFIG_HOME/aws" \
  "$XDG_CONFIG_HOME/bundle" \
  "$XDG_CONFIG_HOME/docker" \
  "$XDG_CONFIG_HOME/git" \
  "$XDG_CONFIG_HOME/kube" \
  "$XDG_CONFIG_HOME/readline" \
  "$XDG_CONFIG_HOME/ripgrep" \
  "$XDG_CONFIG_HOME/wget" \
  "$XDG_DATA_HOME" \
  "$XDG_DATA_HOME/bundle" \
  "$XDG_DATA_HOME/cargo" \
  "$XDG_DATA_HOME/gradle" \
  "$XDG_DATA_HOME/maven" \
  "$XDG_DATA_HOME/nuget" \
  "$XDG_DATA_HOME/opam" \
  "$XDG_DATA_HOME/opam" \
  "$XDG_DATA_HOME/password-store" \
  "$XDG_DATA_HOME/rustup" \
  "$XDG_DATA_HOME/terminfo" \
  "$XDG_DATA_HOME/vscode" \
  "$XDG_DATA_HOME/wineprefixes/default" \
  "$XDG_STATE_HOME" \
  "$XDG_STATE_HOME/bash" \
  "$XDG_STATE_HOME/less" \
  "$XDG_STATE_HOME/openssl" \
  "$XDG_STATE_HOME/python" \
  "$XDG_STATE_HOME/redis" \
  "$XDG_STATE_HOME/sqlite" \
  "$XDG_STATE_HOME/zsh"

path_append() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

export LIBVA_DRIVER_NAME=radeonsi
export RUSTICL_ENABLE=radeonsi
export VDPAU_DRIVER=radeonsi

export CLICOLOR=1
export GTK_THEME="Gruvbox-Orange-Dark"
export HYPRCURSOR_SIZE=24
export MOZ_DBUS_REMOTE=1
export PROTON_NO_WM_DECORATION=1
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_STYLE_OVERRIDE="kvantum"
export WINE_NO_WM_DECORATION=1
export XCURSOR_SIZE=24
export XCURSOR_THEME="Bibata-Modern-Classic"
export XKBLAYOUT="us"
export XKBVARIANT="dvorak"
export XKB_DEFAULT_LAYOUT="us"
export XKB_DEFAULT_VARIANT="dvorak"

export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

path_append /opt/idea-community/bin
path_append "$XDG_DATA_HOME/nvim/mason/bin"
path_append "$XDG_DATA_HOME/cargo/bin"
export PATH

export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export BASH_COMPLETION_USER_FILE="$XDG_CONFIG_HOME/bash-completion/bash_completion"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle/config"
export BUNDLE_USER_HOME="$XDG_DATA_HOME/bundle"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle/plugin"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export DISCORD_USER_DATA_DIR="$XDG_DATA_HOME"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export FFMPEG_DATADIR="$XDG_CONFIG_HOME/ffmpeg"
export GEM_HOME="$XDG_DATA_HOME/ruby/gems"
export GEM_PATH="$XDG_DATA_HOME/ruby/gems"
export GEM_SPEC_CACHE="$XDG_DATA_HOME/ruby/specs"
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export GRIM_DEFAULT_DIR="$XDG_PICTURES_DIR/screenshots"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export GTK_RC_FILES="$XDG_CONFIG_HOME/gtk-1.0/gtkrc"
export HYPRCURSOR_THEME="HyprBibataModernClassicSVG"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export MAVEN_OPTS="${MAVEN_OPTS:+$MAVEN_OPTS }-Dmaven.repo.local=$XDG_DATA_HOME/maven/repository"
export MIX_XDG=true
export MYSQL_HISTFILE="$XDG_DATA_HOME/mysql_history"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME/npm/config/npm-init.js"
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NUGET_HTTP_CACHE_PATH="$XDG_CACHE_HOME/nuget/http-cache"
export NUGET_PACKAGES="$XDG_DATA_HOME/nuget/packages"
export OPAMROOT="$XDG_DATA_HOME/opam"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export RANDFILE="$XDG_STATE_HOME/openssl/rnd"
export REDISCLI_HISTFILE="$XDG_STATE_HOME/redis/rediscli_history"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite/sqlite_history"
export TERMINFO="$XDG_DATA_HOME/terminfo"
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
export VSCODE_PORTABLE="$XDG_DATA_HOME/vscode"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export _JAVA_OPTIONS="${_JAVA_OPTIONS:+$_JAVA_OPTIONS }-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"

unset -f path_append
