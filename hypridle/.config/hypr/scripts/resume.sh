#!/bin/sh

# resume.sh — restore the display and wallpaper after sleep.
#
# Hyprland 0.55+ runs a Lua config; legacy dispatchers such as
# `hyprctl dispatch dpms on` no longer parse, so dispatch through the Lua API.

WALLPAPER_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/wallpapers"
WALLPAPER_FILE="$WALLPAPER_DIR/wallpaper.png"

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' >/dev/null 2>&1 || true
  hyprctl hyprpaper wallpaper ",$WALLPAPER_FILE,cover" >/dev/null 2>&1 || true
fi
