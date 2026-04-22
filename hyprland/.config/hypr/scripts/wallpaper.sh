#!/bin/sh
pkill wbg || true
FILE=$(find "${XDG_PICTURES_DIR}"/wallpapers -type f ! -name 'wallpaper.png' | shuf -n 1) &&
  cp "${FILE}" "${XDG_PICTURES_DIR}"/wallpapers/wallpaper.png
wbg "${XDG_PICTURES_DIR}"/wallpapers/wallpaper.png
