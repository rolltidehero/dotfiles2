#!/usr/bin/env bash
set -eo pipefail

COMPONENT="zsh"
REPO="davzoku/dotfiles"
BRANCH="master"
# curl-safe: BASH_SOURCE[0] is unbound when piped; fall back to "" so
# get_src() downloads from GitHub instead of looking for a local file.
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  DOTFILES_DIR=""
fi
_TMPDIR=$(mktemp -d)
trap 'rm -rf "$_TMPDIR"' EXIT

info()   { echo "[$COMPONENT] $*"; }
warn()   { echo "[$COMPONENT] WARN: $*"; }
manual() { echo "[$COMPONENT] MANUAL: $*"; }

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

if ! command -v zsh &>/dev/null; then
  warn "zsh not found — skipping install."
  exit 0
fi

copy_config "zsh/.zshrc" "$HOME/.zshrc"

manual "Install oh-my-zsh:  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
manual "Install plugins:"
manual "  git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
manual "  git clone https://github.com/zsh-users/zsh-syntax-highlighting \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
manual "Install Powerlevel10k:  git clone --depth=1 https://github.com/romkatv/powerlevel10k \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k"
manual "Configure prompt:  p10k configure"
