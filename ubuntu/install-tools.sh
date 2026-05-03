#!/usr/bin/env bash
# install-tools.sh — install nvim, tmux, and fzf on Ubuntu.
# Run on a fresh instance:
#   curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/ubuntu/install-tools.sh | bash

set -euo pipefail

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

info() { echo "[tools] $*"; }

# --- tmux ---
if command -v tmux &>/dev/null; then
  info "tmux already installed: $(tmux -V)"
else
  info "Installing tmux..."
  sudo apt-get update -qq && sudo apt-get install -y --no-install-recommends tmux
  info "tmux installed: $(tmux -V)"
fi

# --- fzf ---
if command -v fzf &>/dev/null; then
  info "fzf already installed: $(fzf --version)"
elif [[ -f "$HOME/.fzf/bin/fzf" ]]; then
  info "fzf already installed at ~/.fzf/bin/fzf"
else
  info "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --bin --no-update-rc --no-completion --no-key-bindings
  ln -sf "$HOME/.fzf/bin/fzf" "$LOCAL_BIN/fzf"
  info "fzf installed: $(fzf --version)"
fi

# --- neovim (AppImage — no sudo, always latest stable) ---
if command -v nvim &>/dev/null; then
  info "nvim already installed: $(nvim --version | head -1)"
else
  info "Installing nvim AppImage..."
  curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage \
    -o "$LOCAL_BIN/nvim"
  chmod +x "$LOCAL_BIN/nvim"
  info "nvim installed: $($LOCAL_BIN/nvim --version | head -1)"
fi

echo ""
info "Done. Ensure $LOCAL_BIN is on your PATH:"
info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
info "Then apply your dotfiles:"
info "  curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/shell/install.sh | bash"
info "  curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/tmux/install.sh | bash"
info "  curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/nvim/install.sh | bash"
