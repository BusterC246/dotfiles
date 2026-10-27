#!/bin/sh

# Sync dotfiles using GNU Stow.
#
# Usage:
#   ./sync.sh [--simulate] [--verbose] [check] [package...]
#   STOW_PACKAGES="zsh shell" ./sync.sh
#   STOW_SKIP="hyprland gtk" ./sync.sh
#
# Options:
#   --simulate   Dry-run: show what would happen without changing anything
#   --verbose    Show stow operations in detail
#   check        Validate stow is installed and report conflicts
#
# Environment:
#   STOW_PACKAGES  Space-separated list of packages to stow
#   STOW_SKIP      Space-separated list of packages to skip
#
# A package is a top-level directory whose contents mirror $HOME, so it may
# only contain dot-entries (.config, .local, .zshenv, ...). Repo-only
# directories such as .github or scripts are never stowed.

REPO_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd) || exit 1
cd "$REPO_DIR" || exit 1
. "$REPO_DIR/scripts/stow-lib.sh"

SIMULATE=0
VERBOSE=0
COMMAND="sync"
PKGS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --simulate) SIMULATE=1 ;;
    --verbose)  VERBOSE=1 ;;
    check)      COMMAND="check" ;;
    --)         shift; break ;;
    -*)         echo "sync: unknown option: $1" >&2; exit 1 ;;
    *)          PKGS="${PKGS:+$PKGS }$1" ;;
  esac
  shift
done

for arg in "$@"; do
  PKGS="${PKGS:+$PKGS }$arg"
done

if [ -z "$PKGS" ]; then
  if [ -n "${STOW_PACKAGES:-}" ]; then
    PKGS="$STOW_PACKAGES"
  else
    PKGS=$(list_stow_packages)
  fi
fi

DEFAULT_SKIP=".git .git_hooks .githooks"
SKIP="$DEFAULT_SKIP ${STOW_SKIP:-}"

STOW_IGNORE='\.git$|\.gitignore$|\.git_hooks$|\.githooks$|.*\.swp$|.*\.swo$|__pycache__|node_modules|\.bak$|\.tmp$|\.log$'

# Drop skipped packages before anything else looks at the list.
SELECTED=""
for DIR in $PKGS; do
  skip=0
  for S in $SKIP; do
    if [ "$DIR" = "$S" ]; then
      skip=1
      break
    fi
  done
  [ "$skip" -eq 1 ] && continue
  SELECTED="${SELECTED:+$SELECTED }$DIR"
done
PKGS="$SELECTED"

if ! command -v stow >/dev/null 2>&1; then
  echo "sync: stow not installed" >&2
  exit 1
fi

# Refuse to run if any package would link a non-dot path into $HOME.
FAILED=0
for DIR in $PKGS; do
  check_package_layout "$DIR" || FAILED=1
done

if [ "$FAILED" -ne 0 ]; then
  echo "sync: refusing to stow; fix the paths above." >&2
  exit 1
fi

if [ "$COMMAND" = "check" ]; then
  echo "Checking dotfiles sync readiness..."
  echo "stow: $(command -v stow)"
  echo "Packages: $PKGS"
  echo "Not packages: $(list_ignored_dirs)"
  echo "Skipping: $SKIP"
  echo ""

  for DIR in $PKGS; do
    echo "Would stow: $DIR"
    stow --simulate --target="$HOME" --ignore="$STOW_IGNORE" "$DIR" 2>&1 || true
  done
  exit 0
fi

git config core.hooksPath .githooks

for DIR in $PKGS; do
  echo "Stowing $DIR..."
  set -- --target="$HOME" --ignore="$STOW_IGNORE" --restow
  [ "$SIMULATE" -eq 1 ] && set -- "$@" --simulate
  [ "$VERBOSE" -eq 1 ] && set -- "$@" --verbose
  if ! stow "$@" "$DIR"; then
    echo "sync: failed to stow $DIR" >&2
    exit 1
  fi
done

echo "Done. Git hooks path set to .githooks"
