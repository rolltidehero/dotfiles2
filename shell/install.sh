#!/usr/bin/env bash
set -euo pipefail

COMPONENT="shell"
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

copy_config "shell/common.sh" "$HOME/.shell_common.sh"

# --- fzf: Mac gets it from Brewfile; install via git on Linux (no sudo, works on cloud/hpc) ---
if [[ "$(uname)" != "Darwin" ]]; then
  if command -v fzf &>/dev/null; then
    info "fzf already installed: $(command -v fzf)"
  elif [[ -d "$HOME/.fzf" ]]; then
    info "fzf repo found at ~/.fzf — running install."
    "$HOME/.fzf/install" --bin --no-update-rc --no-completion --no-key-bindings
  else
    info "Installing fzf via git to ~/.fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --bin --no-update-rc --no-completion --no-key-bindings
    info "fzf installed to ~/.fzf/bin/fzf"
    manual "~/.fzf/bin is not on PATH automatically. Add to ~/.shell_local: export PATH=\"\$HOME/.fzf/bin:\$PATH\""
  fi
fi
