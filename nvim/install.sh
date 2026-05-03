#!/usr/bin/env bash
set -euo pipefail

COMPONENT="nvim"
REPO="davzoku/dotfiles"
BRANCH="master"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

info()   { echo "[$COMPONENT] $*"; }
warn()   { echo "[$COMPONENT] WARN: $*"; }
manual() { echo "[$COMPONENT] MANUAL: $*"; }

if ! command -v nvim &>/dev/null; then
  warn "nvim not found — skipping install."
  exit 0
fi

NVIM_DIR="$HOME/.config/nvim"
mkdir -p "$NVIM_DIR"

# In curl mode there's no local nvim dir to copy from; user must clone the repo
if [[ ! -d "$DOTFILES_DIR/nvim/lua" ]]; then
  warn "nvim config directory not found locally. Clone the full repo to install nvim config."
  manual "git clone https://github.com/$REPO ~/dotfiles && bash ~/dotfiles/nvim/install.sh"
  exit 1
fi

[[ -d "$NVIM_DIR" ]] && cp -r "$NVIM_DIR" "$NVIM_DIR.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
cp -r "$DOTFILES_DIR/nvim/." "$NVIM_DIR/"
rm -f "$NVIM_DIR/install.sh"
info "Installed nvim config to $NVIM_DIR"
manual "Run 'nvim' once — lazy.nvim will bootstrap and install all plugins automatically."
