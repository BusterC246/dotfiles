#!/bin/sh
hyprctl dispatch dpms on
pkill wbg || true
wbg "${XDG_PICTURES_DIR}"/wallpapers/wallpaper.png &
