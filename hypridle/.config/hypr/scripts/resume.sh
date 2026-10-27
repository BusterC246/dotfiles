#!/bin/sh
WALLPAPER_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/wallpapers"
WALLPAPER_FILE="$WALLPAPER_DIR/wallpaper.png"
if command -v hyprctl >/dev/null 2>&1; then
  hyprctl dispatch dpms on
  hyprctl hyprpaper wallpaper ",$WALLPAPER_FILE,cover" 2>/dev/null || true
fi
