#!/bin/sh

# Unstow dotfiles using GNU Stow.
#
# Usage:
#   ./uninstall.sh               # unstow all packages
#   STOW_PACKAGES="zsh shell" ./uninstall.sh   # unstow only specific packages

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not installed"
  exit 1
fi

if [ -n "${STOW_PACKAGES:-}" ]; then
  PKGS="$STOW_PACKAGES"
else
  PKGS=$(find . -maxdepth 1 -type d -name '*' ! -name '.' ! -name '.git' ! -name '.git_hooks' ! -name '.githooks' -printf '%f\n' 2>/dev/null | sort)
fi

for DIR in $PKGS; do
  if [ -d "$DIR" ]; then
    echo "Unstowing $DIR..."
    if ! stow --target="$HOME" --delete "$DIR"; then
      echo "Failed to unstow $DIR" >&2
      exit 1
    fi
  fi
done

echo "Done."