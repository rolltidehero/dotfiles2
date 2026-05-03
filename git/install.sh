#!/usr/bin/env bash
set -eo pipefail

COMPONENT="git"
REPO="davzoku/dotfiles"
BRANCH="master"
# curl-safe: BASH_SOURCE[0] is unbound when piped; fall back to "" so
# get_src() downloads from GitHub instead of looking for a local file.
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  DOTFILES_DIR=""
fi
_TMPDIR=$(mktemp -d)
trap 'rm -rf "$_TMPDIR"' EXIT

info()   { echo "[$COMPONENT] $*"; }
manual() { echo "[$COMPONENT] MANUAL: $*"; }

get_src() {
  local rel="$1"
  local local_path=""
  [[ -n "$DOTFILES_DIR" ]] && local_path="$DOTFILES_DIR/$rel"
  if [[ -n "$local_path" && -f "$local_path" ]]; then
    echo "$local_path"
  else
    local tmp="$_TMPDIR/$(basename "$rel")"
    curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/$rel" -o "$tmp"
    echo "$tmp"
  fi
}

copy_config() {
  local rel="$1" dst="$2" src
  src=$(get_src "$rel")
  mkdir -p "$(dirname "$dst")"
  [[ -f "$dst" ]] && cp "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  cp "$src" "$dst"
  info "Installed $dst"
}

copy_config "git/.gitconfig" "$HOME/.gitconfig"

manual "To enable GPG signing (personal Mac only):"
manual "  git config --global commit.gpgsign true"
manual "  git config --global gpg.program /opt/homebrew/bin/gpg"
manual "  git config --global user.signingkey <YOUR_KEY_ID>"
