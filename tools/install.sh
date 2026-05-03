#!/usr/bin/env bash
set -euo pipefail

# Installs neovim, tmux, and modern CLI tools on Linux.
# On macOS these come from Brewfile — this script is for homelab only.
# Tools are installed to ~/.local/bin when possible (no sudo required).

COMPONENT="tools"
LOCAL_BIN="$HOME/.local/bin"

info()   { echo "[$COMPONENT] $*"; }
warn()   { echo "[$COMPONENT] WARN: $*"; }
manual() { echo "[$COMPONENT] MANUAL: $*"; }

has() { command -v "$1" &>/dev/null; }

mkdir -p "$LOCAL_BIN"

# --- Homebrew (preferred on Linux if available) ---
if has brew; then
  info "Homebrew found — installing via brew."
  brew install neovim tmux dust bat eza fd ripgrep git-delta zoxide bottom hyperfine
  info "All tools installed via brew."
  exit 0
fi

# --- apt (Debian/Ubuntu) ---
if has apt-get; then
  info "apt found — installing base tools."
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    neovim tmux bat fd-find ripgrep
  # fd-find installs as 'fdfind'; symlink to 'fd' in ~/.local/bin
  if has fdfind && ! has fd; then
    ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
    info "Symlinked fdfind → $LOCAL_BIN/fd"
  fi
fi

# --- cargo-installed tools (no sudo, installs to ~/.cargo/bin) ---
if has cargo; then
  info "cargo found — installing remaining modern CLI tools."
  for tool in du-dust bat eza git-delta zoxide bottom hyperfine; do
    cargo install "$tool" --quiet
  done
  info "Cargo tools installed to ~/.cargo/bin"
  manual "Ensure ~/.cargo/bin is on your PATH (add to ~/.shell_local if needed)."
else
  manual "cargo not found — skipping dust, eza, git-delta, zoxide, bottom, hyperfine."
  manual "Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  manual "Then re-run: bash tools/install.sh"
fi

# --- neovim: AppImage fallback if apt didn't install a recent enough version ---
if ! has nvim; then
  info "nvim not found via apt — installing AppImage to $LOCAL_BIN/nvim"
  nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
  curl -fsSL "$nvim_url" -o "$LOCAL_BIN/nvim"
  chmod +x "$LOCAL_BIN/nvim"
  info "nvim installed to $LOCAL_BIN/nvim"
fi

info "Done. Tools available: neovim, tmux, bat, fd, ripgrep, and cargo tools in ~/.cargo/bin"
manual "Run nvim/install.sh to apply your neovim config."
