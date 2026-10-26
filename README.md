# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that gets linked into `$HOME`.

[![CI](https://github.com/busterc246/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/busterc246/dotfiles/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

## What's in here

- Shell — `env.sh` and `interactive.sh` sourced by `.zshrc` and `.bashrc`
- Zsh — `.zshrc`, `.zprofile`, `.zshenv` under `$XDG_CONFIG_HOME/zsh`
- Hyprland — Lua config plus `autostart.lua`, `input.lua`, `monitors.lua`, `window_rules.lua`
- Hypridle / Hyprlock — idle and lockscreen config
- Kitty, Ghostty, Wezterm, Foot, Alacritty — terminal configs
- Neovim — `init.lua` with Mason, LSP, and Treesitter
- GTK, Qt5ct, Kvantum, Mako, Tofi — theming and notifications
- Opencode — agent config (runtime state like `service.json` is gitignored)

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

## Dependencies

Most of these are cosmetic — the dotfiles work without them, they just won't look the same. Install them if you want the Gruvbox/Dvorak look:

- [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) font — official GitHub repo by JetBrains (already installed on this system)
- [Bibata](https://github.com/ful1e5/Bibata_Cursor) cursor theme — official GitHub repo by ful1e5 (already installed on this system)
- [Ayu-Dark](https://github.com/dempfi/ayu) theme — official GitHub repo by dempfi (already installed on this system; this is the original Ayu color scheme, ported to GTK)

Here's what each theme-related package controls:

| Package | Controls | Theme used |
|---------|----------|------------|
| `gtk/` | GTK 4 settings | Gruvbox-Orange-Dark (not installed) |
| `ghostty/` | Ghostty terminal | Ayu-Dark |
| `kvantum/` | Qt5 apps (Kvantum theme engine) | AyuDark |
| `kitty/` | Kitty terminal font | JetBrains Mono |
| `wezterm/` | Wezterm terminal color scheme | Gruvbox Dark |
| `shell/.config/shell/env.sh` | GTK theme, cursor theme, XKB layout | overridable via env vars |

Most values can be overridden with environment variables instead of editing files:

```sh
export TERMINAL=kitty
export BROWSER=librewolf
export GTK_THEME=Gruvbox-Orange-Dark
export XKBVARIANT=dvorak
export WEZTERM_COLOR_SCHEME=Gruvbox Dark
export SPELLLANG=en
```

## Making it your own

This repo is personal config. Before using it on your machine, change:

- `monitors.lua`
- `autostart.lua`
- `env.sh`

## License

[GPL-3.0](LICENSE)
