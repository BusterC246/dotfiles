#!/bin/sh

# Unstow dotfiles using GNU Stow.
#
# Usage:
#   ./uninstall.sh               # unstow all packages
#   STOW_PACKAGES="zsh shell" ./uninstall.sh   # unstow only specific packages
#
# Uses the same package detection as sync.sh, so repo-only directories such as
# .github and scripts are never touched.

REPO_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd) || exit 1
cd "$REPO_DIR" || exit 1
. "$REPO_DIR/scripts/stow-lib.sh"

if ! command -v stow >/dev/null 2>&1; then
  echo "uninstall: stow not installed" >&2
  exit 1
fi

if [ -n "${STOW_PACKAGES:-}" ]; then
  PKGS="$STOW_PACKAGES"
else
  PKGS=$(list_stow_packages)
fi

for DIR in $PKGS; do
  if ! is_stow_package "$DIR"; then
    echo "uninstall: skipping non-package: $DIR" >&2
    continue
  fi

  echo "Unstowing $DIR..."
  if ! stow --target="$HOME" --delete "$DIR"; then
    echo "uninstall: failed to unstow $DIR" >&2
    exit 1
  fi
done

echo "Done."
