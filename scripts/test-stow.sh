#!/bin/sh

# test-stow.sh — prove that stowing this repo cannot litter $HOME.
#
# Stows every package into a throwaway home directory and fails if anything
# outside the dotfile namespace appears. This is the regression test for the
# bug where `.github` and `scripts` were treated as packages and dropped
# ISSUE_TEMPLATE, workflows, dependabot.yml, validate-jsonc.mjs and friends
# straight into the user's home directory.

set -eu

REPO_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TMP_HOME=$(mktemp -d)
FIXTURE=$(mktemp -d)
trap 'rm -rf "$TMP_HOME" "$FIXTURE"' EXIT INT TERM

HOME="$TMP_HOME"
export HOME

cd "$REPO_DIR"

echo "Stowing every package into $TMP_HOME..."
./sync.sh >/dev/null

leaks=$(find "$TMP_HOME" -mindepth 1 -maxdepth 1 ! -name '.*' ! -name 'hypr.sh' -print)
if [ -n "$leaks" ]; then
  printf 'FAIL: non-dot entries were linked into the home directory:\n%s\n' "$leaks"
  exit 1
fi

for leaked in ISSUE_TEMPLATE workflows dependabot.yml PULL_REQUEST_TEMPLATE.md validate-jsonc.mjs; do
  if [ -e "$TMP_HOME/$leaked" ] || [ -L "$TMP_HOME/$leaked" ]; then
    printf 'FAIL: %s was stowed into the home directory\n' "$leaked"
    exit 1
  fi
done

# hypr.sh is the one deliberate non-dot link: it has always been ~/hypr.sh.
if [ ! -e "$TMP_HOME/hypr.sh" ]; then
  echo "FAIL: expected hypr.sh to be linked into the home directory"
  exit 1
fi

# A package that silently stopped being detected would hide its files, so make
# sure the packages we expect are actually linked.
for expected in .config/hypr .config/opencode .zshenv; do
  if [ ! -e "$TMP_HOME/$expected" ]; then
    printf 'FAIL: expected %s to be linked into the home directory\n' "$expected"
    exit 1
  fi
done

count=$(find "$TMP_HOME" -mindepth 1 -maxdepth 1 | wc -l)
printf 'OK: %s dot-paths linked into the home directory, nothing leaked\n' "$count"

# The guard must also reject a package that would leak, and must reject a
# directory that has nothing to link into $HOME.
mkdir -p "$FIXTURE/bad/.config" "$FIXTURE/tooling"
: > "$FIXTURE/bad/README.md"
: > "$FIXTURE/tooling/run.sh"
(
  cd "$FIXTURE" || exit 1
  . "$REPO_DIR/scripts/stow-lib.sh"

  is_stow_package bad || {
    echo "FAIL: package with a dot-entry was not detected"
    exit 1
  }
  if is_stow_package tooling; then
    echo "FAIL: directory without dot-entries was treated as a package"
    exit 1
  fi
  if check_package_layout bad 2>/dev/null; then
    echo "FAIL: package with a non-dot entry was accepted"
    exit 1
  fi
)

printf 'OK: guard rejects leaking packages and non-packages\n'
