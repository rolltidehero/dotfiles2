#!/usr/bin/env bash
set -euo pipefail

# Usage: install.sh [personal|work]
# Default: personal
PROFILE="${1:-personal}"

COMPONENT="macos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPOONS_DIR="$HOME/.hammerspoon/Spoons"

info()   { echo "[$COMPONENT] $*"; }
warn()   { echo "[$COMPONENT] WARN: $*"; }
manual() { echo "[$COMPONENT] MANUAL: $*"; }

if [[ "$(uname)" != "Darwin" ]]; then
  warn "Not macOS — skipping install."
  exit 0
fi

copy_config() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  [[ -f "$dst" ]] && cp "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  cp "$src" "$dst"
  info "Installed $dst"
}

copy_dir() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  cp -r "$src/." "$dst/"
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
  tmp_zip=$(mktemp /tmp/spoon-XXXXXX.zip)
  curl -fsSL "$zip_url" -o "$tmp_zip"
  mkdir -p "$SPOONS_DIR"
  unzip -q "$tmp_zip" -d "$SPOONS_DIR"
  rm -f "$tmp_zip"
  info "Spoon installed: $spoon_path"
}

# --- Step 1: Homebrew essentials (must be installed before configs) ---
if command -v brew &>/dev/null; then
  info "Running brew bundle (Brewfile)..."
  brew bundle --file="$SCRIPT_DIR/Brewfile"
  case "$PROFILE" in
    personal)
      manual "Run when ready: brew bundle --file=$SCRIPT_DIR/Brewfile.personal  (ML/data science + personal apps)"
      ;;
    work)
      manual "Run when ready: brew bundle --file=$SCRIPT_DIR/Brewfile.work  (dev tools + work apps)"
      ;;
  esac
else
  manual "Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  manual "Then re-run this script to install packages and apply configs."
  exit 1
fi

# --- Step 2: macOS defaults ---
bash "$SCRIPT_DIR/mac-defaults.sh"
info "Applied macOS defaults."

# --- Step 3: Karabiner Elements ---
copy_dir "$SCRIPT_DIR/karabiner-elements-app" "$HOME/.config/karabiner"

# --- Step 4: Rectangle ---
copy_dir "$SCRIPT_DIR/rectangle-app" "$HOME/Library/Application Support/Rectangle"

# --- Step 5: Hammerspoon spoons ---
install_spoon "ReloadConfiguration" "https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ReloadConfiguration.spoon.zip"

# --- Step 6: Hammerspoon config (always init.lua) ---
copy_config "$SCRIPT_DIR/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"

# --- Post-install manual checklist ---
echo ""
echo "[$COMPONENT] ===== POST-INSTALL CHECKLIST ====="
manual "[ ] Bitwarden: install from the Mac App Store (required for Touch ID support in browser extension)"
manual "[ ] Raycast: sign in and restore config from Cloud (Raycast → Settings → Advanced → Import)"
manual "[ ] Hammerspoon: open Hammerspoon.app and grant Accessibility permission"
manual "[ ] Karabiner-Elements: open and grant Input Monitoring permission"
if [[ "$PROFILE" == "personal" ]]; then
  manual "[ ] Enable GPG signing: git config --global commit.gpgsign true && git config --global gpg.program /opt/homebrew/bin/gpg"
fi