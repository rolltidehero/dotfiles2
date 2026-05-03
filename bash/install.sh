#!/usr/bin/env bash
set -euo pipefail

# Usage: install.sh [linux|cloud|hpc]
VARIANT="${1:-}"

COMPONENT="bash"
REPO="davzoku/dotfiles"
BRANCH="master"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
_TMPDIR=$(mktemp -d)
trap 'rm -rf "$_TMPDIR"' EXIT

info()   { echo "[$COMPONENT] $*"; }
warn()   { echo "[$COMPONENT] WARN: $*"; }
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

# Warn on shared ubuntu user
if [[ "${USER:-}" == "ubuntu" ]]; then
  warn "Shared user 'ubuntu' detected — changes to ~/.bashrc affect all users of this account."
  printf "[$COMPONENT] Proceed? [y/N] "
  read -r reply
  [[ "$reply" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }
fi

copy_config "bash/.bashrc" "$HOME/.bashrc"

if [[ -n "$VARIANT" ]]; then
  case "$VARIANT" in
    linux|cloud|hpc)
      copy_config "bash/.bashrc.$VARIANT" "$HOME/.bashrc.variant"
      info "Variant '$VARIANT' installed to ~/.bashrc.variant"
      ;;
    *)
      warn "Unknown variant '$VARIANT'. Valid: linux, cloud, hpc. Skipping variant."
      ;;
  esac
fi

manual "Add machine-specific env and module loads to ~/.shell_local (not tracked in repo)."
