#!/bin/sh

# wallpaper.sh — Set a random wallpaper via hyprpaper (cover/zoom-to-fill mode).

WALLPAPER_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/wallpapers"
WALLPAPER_FILE="$WALLPAPER_DIR/wallpaper.png"

mkdir -p "$WALLPAPER_DIR"

FILE=$(find "$WALLPAPER_DIR" -type f ! -name "wallpaper.png" | shuf -n 1 2>/dev/null) || exit 0

cp "$FILE" "$WALLPAPER_FILE"

if command -v hyprctl >/dev/null 2>&1; then
  # hyprpaper may still be starting when this runs at login, so retry until
  # its IPC socket accepts the request (~5s max).
  i=0
  while [ "$i" -lt 50 ]; do
    if hyprctl hyprpaper wallpaper ",$WALLPAPER_FILE,cover" >/dev/null 2>&1; then
      exit 0
    fi
    i=$((i + 1))
    sleep 0.1
  done
fi
