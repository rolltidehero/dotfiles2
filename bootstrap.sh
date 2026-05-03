#!/usr/bin/env bash
set -euo pipefail

# Usage: ./bootstrap.sh <machine-type>
# Machine types: personal-mac | work-mac | personal-linux | cloud | hpc
#
# Each component's install.sh is also curl-installable independently:
#   curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/<component>/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/bash/install.sh | bash -s -- cloud

MACHINE="${1:-}"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "Usage: $0 <machine-type>"
  echo "  machine-type: personal-mac | work-mac | personal-linux | cloud | hpc"
  exit 1
}

[[ -z "$MACHINE" ]] && usage

case "$MACHINE" in
  personal-mac|work-mac|personal-linux|cloud|hpc) ;;
  *) echo "Unknown machine type: $MACHINE"; usage ;;
esac

INSTALLED=()
SKIPPED=()
FAILED=()

run_installer() {
  local component="$1"; shift
  local script="$DOTFILES_DIR/$component/install.sh"
  if [[ ! -f "$script" ]]; then
    echo "[bootstrap] SKIP $component — install.sh not found"
    SKIPPED+=("$component")
    return
  fi
  echo ""
  echo "==> Installing: $component"
  if bash "$script" "$@"; then
    INSTALLED+=("$component")
  else
    echo "[bootstrap] ERROR in $component"
    FAILED+=("$component")
  fi
}

echo "=== dotfiles bootstrap: $MACHINE ==="

# --- Universal: shell environment + aliases ---
run_installer shell
run_installer alias

# --- Shell-specific ---
case "$MACHINE" in
  personal-mac|work-mac)
    run_installer zsh
    ;;
  personal-linux|cloud|hpc)
    case "$MACHINE" in
      personal-linux) run_installer bash linux ;;
      cloud)     run_installer bash cloud ;;
      hpc)     run_installer bash hpc ;;
    esac
    ;;
esac

# --- Universal tools ---
run_installer git
run_installer tmux

# --- vim on all machines; nvim on Macs and personal-linux ---
case "$MACHINE" in
  personal-mac|work-mac|personal-linux)
    run_installer vim
    run_installer nvim
    ;;
  cloud|hpc)
    run_installer vim
    ;;
esac

# --- Modern CLI tools: Brewfile handles macOS; tools/install.sh for Linux ---
case "$MACHINE" in
  personal-linux)
    run_installer tools
    ;;
esac

# --- macOS only ---
case "$MACHINE" in
  personal-mac)
    run_installer ghostty
    run_installer macos personal
    ;;
  work-mac)
    run_installer macos work
    ;;
esac

# --- Summary ---
echo ""
echo "=== Bootstrap complete: $MACHINE ==="
echo ""
[[ ${#INSTALLED[@]} -gt 0 ]] && echo "Installed : ${INSTALLED[*]}"
[[ ${#SKIPPED[@]}   -gt 0 ]] && echo "Skipped   : ${SKIPPED[*]}"
[[ ${#FAILED[@]}    -gt 0 ]] && echo "Failed    : ${FAILED[*]}"
echo ""
echo "Next: add machine-specific config to ~/.shell_local (not tracked in repo)."
