#!/usr/bin/env bash
set -euo pipefail

# Installs Hammerspoon config and Spoons. Curl-safe when piped (sources from GitHub).
# Usage: bash macos/hammerspoon/install.sh
#   or: curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/macos/hammerspoon/install.sh | bash

COMPONENT="hammerspoon"
REPO="davzoku/dotfiles"
BRANCH="master"

if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
  SCRIPT_DIR=""
  DOTFILES_DIR=""
fi

_TMPDIR=$(mktemp -d)
trap 'rm -rf "$_TMPDIR"' EXIT

SPOONS_DIR="$HOME/.hammerspoon/Spoons"

info() { echo "[$COMPONENT] $*"; }
warn() { echo "[$COMPONENT] WARN: $*"; }

if [[ "$(uname)" != "Darwin" ]]; then
  warn "Not macOS — skipping Hammerspoon install."
  exit 0
fi

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

install_spoon() {
  local name="$1" zip_url="$2"
  local spoon_path="$SPOONS_DIR/${name}.spoon"
  if [[ -d "$spoon_path" ]]; then
    info "Spoon already installed: $name"
    return
  fi
  info "Installing Spoon: $name"
  local tmp_zip
  tmp_zip=$(mktemp "$_TMPDIR/spoon-XXXXXX.zip")
  curl -fsSL "$zip_url" -o "$tmp_zip"
  mkdir -p "$SPOONS_DIR"
  unzip -q "$tmp_zip" -d "$SPOONS_DIR"
  rm -f "$tmp_zip"
  info "Spoon installed: $spoon_path"
}

install_spoon "ReloadConfiguration" "https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ReloadConfiguration.spoon.zip"
copy_config "macos/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"

if [[ ! -d "/Applications/Hammerspoon.app" && ! -d "$HOME/Applications/Hammerspoon.app" ]]; then
  warn "Hammerspoon.app not found — install with: brew install --cask hammerspoon (or from https://www.hammerspoon.org/)"
fi
