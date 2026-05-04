#!/usr/bin/env bash
set -euo pipefail

# Usage: install.sh [personal|work]
# Default: personal
PROFILE="${1:-personal}"

COMPONENT="macos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

# --- Step 5: Hammerspoon (config + Spoons; same for personal and work Macs) ---
bash "$SCRIPT_DIR/hammerspoon/install.sh"

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