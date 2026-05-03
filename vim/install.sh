#!/usr/bin/env bash
set -euo pipefail

COMPONENT="vim"
REPO="davzoku/dotfiles"
BRANCH="master"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
_TMPDIR=$(mktemp -d)
trap 'rm -rf "$_TMPDIR"' EXIT

info()   { echo "[$COMPONENT] $*"; }
manual() { echo "[$COMPONENT] MANUAL: $*"; }

get_src() {
  local rel="$1" local_path="$DOTFILES_DIR/$rel"
  if [[ -f "$local_path" ]]; then
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
manual "For the unokai colorscheme: mkdir -p ~/.vim/colors && curl -fsSL https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -o ~/.vim/colors/unokai.vim"
manual "Or run ':silent! colorscheme' in vim — it falls back to default automatically."
