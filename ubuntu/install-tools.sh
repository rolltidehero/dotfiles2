#!/usr/bin/env bash
# install-tools.sh — install tmux, bat, fzf, and nvim without sudo.
# All binaries go to ~/.local/bin.
# curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/ubuntu/install-tools.sh | bash

set -eo pipefail

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

info() { echo "[tools] $*"; }

# Resolve the latest GitHub release download URL for a given repo + asset pattern.
# Usage: gh_latest_url <owner/repo> <grep-pattern>
gh_latest_url() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | grep '"browser_download_url"' \
    | grep "$2" \
    | head -1 \
    | cut -d '"' -f 4
}

# --- tmux ---
if command -v tmux &>/dev/null; then
  info "tmux already installed: $(tmux -V)"
else
  info "Installing tmux..."
  # Try system package manager first (works if sudo is available or running as root)
  if sudo apt-get install -y --no-install-recommends tmux 2>/dev/null; then
    info "tmux installed via apt: $(tmux -V)"
  else
    # No sudo — download static AppImage build
    TMUX_URL=$(gh_latest_url "nicowillis/tmux-static" "tmux-static-linux-amd64" 2>/dev/null || true)
    if [[ -z "$TMUX_URL" ]]; then
      # Fallback to a known working static build URL pattern
      TMUX_URL="https://github.com/nicowillis/tmux-static/releases/latest/download/tmux-static-linux-amd64"
    fi
    curl -fsSL "$TMUX_URL" -o "$LOCAL_BIN/tmux"
    chmod +x "$LOCAL_BIN/tmux"
    info "tmux installed to $LOCAL_BIN/tmux: $("$LOCAL_BIN/tmux" -V)"
  fi
fi

# --- bat (binary release, no sudo) ---
if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
  info "bat already installed."
else
  info "Installing bat..."
  BAT_URL=$(gh_latest_url "sharkdp/bat" "x86_64-unknown-linux-musl.tar.gz")
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  curl -fsSL "$BAT_URL" -o "$TMP/bat.tar.gz"
  tar -xzf "$TMP/bat.tar.gz" -C "$TMP" --strip-components=1
  mv "$TMP/bat" "$LOCAL_BIN/bat"
  chmod +x "$LOCAL_BIN/bat"
  info "bat installed to $LOCAL_BIN/bat: $("$LOCAL_BIN/bat" --version)"
fi

# --- fzf (git clone, no sudo) ---
if command -v fzf &>/dev/null || [[ -f "$HOME/.fzf/bin/fzf" ]]; then
  info "fzf already installed."
else
  info "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --bin --no-update-rc --no-completion --no-key-bindings
  ln -sf "$HOME/.fzf/bin/fzf" "$LOCAL_BIN/fzf"
  info "fzf installed to $LOCAL_BIN/fzf"
fi

# --- neovim (AppImage, no sudo) ---
if command -v nvim &>/dev/null; then
  info "nvim already installed: $(nvim --version | head -1)"
else
  info "Installing nvim AppImage..."
  curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage \
    -o "$LOCAL_BIN/nvim"
  chmod +x "$LOCAL_BIN/nvim"
  info "nvim installed to $LOCAL_BIN/nvim"
fi

echo ""
info "All tools installed to $LOCAL_BIN"
info "Make sure it is on your PATH — add to ~/.shell_local if needed:"
info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
info ""
info "Next — apply dotfiles:"
info "  curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/shell/install.sh | bash"
info "  curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/alias/install.sh | bash"
info "  curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/tmux/install.sh  | bash"
info "  curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/vim/install.sh   | bash"
