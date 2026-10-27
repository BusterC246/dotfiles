#!/bin/sh

# wallpaper.sh — Set a random wallpaper via hyprpaper (cover/zoom-to-fill mode).

WALLPAPER_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/wallpapers"
WALLPAPER_FILE="$WALLPAPER_DIR/wallpaper.png"

mkdir -p "$WALLPAPER_DIR"

FILE=$(find "$WALLPAPER_DIR" -type f ! -name "wallpaper.png" | shuf -n 1 2>/dev/null) || exit 0

cp "$FILE" "$WALLPAPER_FILE"

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl hyprpaper wallpaper ",$WALLPAPER_FILE,cover" 2>/dev/null || true
fi
