#!/usr/bin/env bash
set -euo pipefail

COMPONENT="alias"
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

add_source_line() {
  local file="$1"
  local line='[[ -f ~/.alias ]] && source ~/.alias'
  if [[ -f "$file" ]] && ! grep -qF '~/.alias' "$file"; then
    echo "$line" >> "$file"
    info "Added source line to $file"
  fi
}

copy_config "alias/.alias" "$HOME/.alias"

# Wire sourcing into existing shell configs if present
add_source_line "$HOME/.zshrc"
add_source_line "$HOME/.bashrc"
