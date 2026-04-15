#!/bin/sh
FILE=$(find "${XDG_PICTURES_DIR}"/wallpapers -type f | shuf -n 1) && cp "${FILE}" "${XDG_PICTURES_DIR}"/wallpapers/wallpaper.png
wbg "${XDG_PICTURES_DIR}"/wallpapers/wallpaper.png
