#!/usr/bin/env bash
set -eo pipefail

COMPONENT="vim"
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

copy_config "vim/.vimrc" "$HOME/.vimrc"

# --- unokai colorscheme ---
COLORS_DIR="$HOME/.vim/colors"
if [[ -f "$COLORS_DIR/unokai.vim" ]]; then
  info "unokai colorscheme already installed."
else
  info "Installing unokai colorscheme..."
  mkdir -p "$COLORS_DIR"
  curl -fsSL https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim \
    -o "$COLORS_DIR/unokai.vim"
  info "unokai installed to $COLORS_DIR/unokai.vim"
fi
