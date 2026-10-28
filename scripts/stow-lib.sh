#!/bin/sh

# Shared stow package discovery for sync.sh and uninstall.sh.
#
# A stow package is a top-level directory whose *contents* are mirrored into
# $HOME. That means every entry at the root of a package must be a dot-entry
# (`.config`, `.local`, `.zshenv`, ...). Anything else would be linked to
# $HOME/name and litter the home directory, so it is treated as a repo-only
# directory rather than a package: `.github`, `scripts`, `docs`, `assets`.
#
# Keeping this rule here means the two scripts can never disagree about what
# a package is.

# Deliberate exceptions: root-level non-dot entries that are meant to be
# linked into $HOME. Keep this list tiny; anything else at a package root is
# a bug. `hypr.sh` is the launcher that has always lived at ~/hypr.sh.
STOW_ALLOWED_ROOT_ENTRIES=${STOW_ALLOWED_ROOT_ENTRIES:-"hypr.sh"}

# stow_root_entry_allowed NAME — true if NAME is an intentional home-dir link.
stow_root_entry_allowed() {
  for _allowed in $STOW_ALLOWED_ROOT_ENTRIES; do
    [ "$1" = "$_allowed" ] && return 0
  done
  return 1
}

# has_dot_entries DIR — true if DIR contains at least one hidden entry.
has_dot_entries() {
  for _entry in "$1"/.[!.]* "$1"/..?*; do
    if [ -e "$_entry" ] || [ -L "$_entry" ]; then
      return 0
    fi
  done
  return 1
}

# is_stow_package DIR — true if DIR is a top-level stow package.
is_stow_package() {
  [ -d "$1" ] || return 1
  case "$1" in
    .* | */*) return 1 ;;
  esac
  has_dot_entries "$1"
}

# list_stow_packages — print every stow package name, sorted.
list_stow_packages() {
  for _dir in */; do
    _dir=${_dir%/}
    if is_stow_package "$_dir"; then
      printf '%s\n' "$_dir"
    fi
  done | sort
}

# list_ignored_dirs — print top-level directories that are not packages.
list_ignored_dirs() {
  _out=""
  for _dir in */ .*/; do
    _dir=${_dir%/}
    case "$_dir" in
      . | .. | .git | .git_hooks | .githooks) continue ;;
    esac
    is_stow_package "$_dir" && continue
    _out="${_out:+$_out }$_dir"
  done
  if [ -n "$_out" ]; then
    printf '%s\n' "$_out"
  fi
}

# check_package_layout DIR — report entries that would be linked outside the
# dotfile namespace. Returns non-zero if the package must not be stowed.
check_package_layout() {
  if [ ! -d "$1" ]; then
    echo "sync: no such package: $1" >&2
    return 1
  fi
  if ! is_stow_package "$1"; then
    echo "sync: not a stow package: $1 (nothing to link into \$HOME)" >&2
    echo "      packages contain dot-entries such as .config or .zshenv" >&2
    return 1
  fi
  _bad=0
  for _entry in "$1"/*; do
    if [ -e "$_entry" ] || [ -L "$_entry" ]; then
      _name=${_entry##*/}
      stow_root_entry_allowed "$_name" && continue
      echo "sync: $1/$_name would be linked to \$HOME/$_name" >&2
      echo "      move it under a dot-directory (for example .local/bin/)" >&2
      echo "      or add it to STOW_ALLOWED_ROOT_ENTRIES in scripts/stow-lib.sh" >&2
      _bad=1
    fi
  done
  [ "$_bad" -eq 0 ]
}
