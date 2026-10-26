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
    *)          PKGS="$1" ;;
  esac
  shift
done

for arg in "$@"; do
  if [ -z "$PKGS" ]; then
    PKGS="$arg"
  else
    PKGS="$PKGS $arg"
  fi
done

if [ -z "$PKGS" ]; then
  if [ -n "${STOW_PACKAGES:-}" ]; then
    PKGS="$STOW_PACKAGES"
  else
    PKGS=$(find . -maxdepth 1 -type d -name '*' ! -name '.' ! -name '.git' ! -name '.git_hooks' ! -name '.githooks' -printf '%f\n' 2>/dev/null | sort)
  fi
fi

DEFAULT_SKIP=".git .git_hooks .githooks"
SKIP="$DEFAULT_SKIP ${STOW_SKIP:-}"

STOW_IGNORE='\.git$|\.gitignore$|\.git_hooks$|\.githooks$|.*\.swp$|.*\.swo$|__pycache__|node_modules|\.bak$|\.tmp$|\.log$'

if ! command -v stow >/dev/null 2>&1; then
  echo "sync: stow not installed" >&2
  exit 1
fi

if [ "$COMMAND" = "check" ]; then
  echo "Checking dotfiles sync readiness..."
  echo "stow: $(command -v stow)"
  echo "Packages: $PKGS"
  echo "Skipping: $SKIP"
  echo ""

  for DIR in $PKGS; do
    skip=0
    for S in $SKIP; do
      [ "$DIR" = "$S" ] && skip=1 && break
    done
    [ "$skip" -eq 1 ] && continue

    if [ -d "$DIR" ]; then
      echo "Would stow: $DIR"
      stow --simulate --target="$HOME" --ignore="$STOW_IGNORE" "$DIR" 2>&1 || true
    fi
  done
  exit 0
fi

git config core.hooksPath .githooks

for DIR in $PKGS; do
  skip=0
  for S in $SKIP; do
    [ "$DIR" = "$S" ] && skip=1 && break
  done
  [ "$skip" -eq 1 ] && continue

  if [ -d "$DIR" ]; then
    echo "Stowing $DIR..."
    SIM_FLAG=""
    VERB_FLAG=""
    [ "$SIMULATE" -eq 1 ] && SIM_FLAG="--simulate"
    [ "$VERBOSE" -eq 1 ] && VERB_FLAG="--verbose"
    if ! stow --target="$HOME" $SIM_FLAG $VERB_FLAG --ignore="$STOW_IGNORE" --restow "$DIR"; then
      echo "sync: failed to stow $DIR" >&2
      exit 1
    fi
  fi
done

echo "Done. Git hooks path set to .githooks"
