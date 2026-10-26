# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that gets linked into `$HOME`.

[![CI](https://github.com/busterc246/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/busterc246/dotfiles/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

## What's in here

- **Shell** — `env.sh` and `interactive.sh` sourced by `.zshrc` and `.bashrc`
- **Zsh** — `.zshrc`, `.zprofile`, `.zshenv` under `$XDG_CONFIG_HOME/zsh`
- **Hyprland** — Lua config plus `autostart.lua`, `input.lua`, `monitors.lua`, `window_rules.lua`
- **Hypridle / Hyprlock** — idle and lockscreen config
- **Kitty, Ghostty, Wezterm, Foot, Alacritty** — terminal configs
- **Neovim** — `init.lua` with Mason, LSP, and Treesitter
- **GTK, Qt5ct, Kvantum, Mako, Tofi** — theming and notifications
- **Opencode** — agent config (runtime state like `service.json` is gitignored)

## Installation

Clone the repo and run `sync.sh`:

```sh
git clone https://github.com/busterc246/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./sync.sh
```

This stows every package except `.git`, `.git_hooks`, `.githooks`, `x11`, and `opencode`. To stow only specific packages:

```sh
STOW_PACKAGES="zsh shell" ./sync.sh
```

To skip packages:

```sh
STOW_SKIP="hyprland gtk" ./sync.sh
```

To see what would happen without changing anything:

```sh
./sync.sh --simulate
```

To remove everything:

```sh
./uninstall.sh
```

## What you need

The `README` previously listed fonts and icon themes as hard requirements. Most of those are cosmetic — the dotfiles will work without them, they just won't look the same. Install them if you want the Gruvbox/Dvorak look:

- JetBrains Mono font
- Papirus Dark icon theme
- Bibata cursor theme
- Gruvbox GTK theme

## Making it your own

This repo is personal config. Before using it on your machine, change:

- `monitors.lua` — your monitor names and positions
- `autostart.lua` — Gentoo-specific `gentoo-pipewire-launcher`
- `env.sh` — AMD GPU drivers and `/opt/idea-community/bin` path

Most values can be overridden with environment variables instead of editing files:

```sh
export TERMINAL=kitty
export BROWSER=librewolf
export GTK_THEME=Gruvbox-Orange-Dark
export XKBVARIANT=dvorak
```

## License

[GPL-3.0](LICENSE)
