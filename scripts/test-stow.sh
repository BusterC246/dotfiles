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
trap 'rm -rf "$TMP_HOME"' EXIT INT TERM

HOME="$TMP_HOME"
export HOME

cd "$REPO_DIR"

echo "Stowing every package into $TMP_HOME..."
./sync.sh >/dev/null

leaks=$(find "$TMP_HOME" -mindepth 1 -maxdepth 1 ! -name '.*' -print)
if [ -n "$leaks" ]; then
  printf 'FAIL: non-dot entries were linked into the home directory:\n%s\n' "$leaks"
  exit 1
fi

for leaked in ISSUE_TEMPLATE workflows dependabot.yml PULL_REQUEST_TEMPLATE.md validate-jsonc.mjs hypr.sh; do
  if [ -e "$TMP_HOME/$leaked" ] || [ -L "$TMP_HOME/$leaked" ]; then
    printf 'FAIL: %s was stowed into the home directory\n' "$leaked"
    exit 1
  fi
done

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
