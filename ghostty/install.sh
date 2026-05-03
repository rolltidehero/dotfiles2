#!/usr/bin/env bash
set -euo pipefail

COMPONENT="ghostty"
REPO="davzoku/dotfiles"
BRANCH="master"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
_TMPDIR=$(mktemp -d)
trap 'rm -rf "$_TMPDIR"' EXIT

info()   { echo "[$COMPONENT] $*"; }
warn()   { echo "[$COMPONENT] WARN: $*"; }

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

if ! command -v ghostty &>/dev/null && [[ ! -d "/Applications/Ghostty.app" ]]; then
  warn "Ghostty not found — skipping install."
  exit 0
fi

copy_config "ghostty/config" "$HOME/.config/ghostty/config"
