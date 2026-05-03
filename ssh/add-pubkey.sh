#!/usr/bin/env bash
# add-pubkey.sh — run on a remote instance to add your public key to authorized_keys.
# Usage:
#   bash add-pubkey.sh "<your-public-key>"
# Or via curl (prompts for key if none passed):
#   curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/ssh/add-pubkey.sh | bash -s -- "<your-public-key>"

set -euo pipefail

AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"

# --- Accept key from arg or prompt ---
PUBKEY="${1:-}"
if [[ -z "$PUBKEY" ]]; then
  echo "Paste your public key (single line, e.g. ssh-ed25519 AAAA...):"
  read -r PUBKEY
fi

if [[ -z "$PUBKEY" ]]; then
  echo "Error: no public key provided." >&2
  exit 1
fi

# Basic sanity check — must start with a known key type
if ! echo "$PUBKEY" | grep -qE '^(ssh-ed25519|ssh-rsa|ssh-ecdsa|ecdsa-sha2-nistp256|sk-ssh-ed25519) '; then
  echo "Error: key does not look like a valid SSH public key." >&2
  exit 1
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"

# Extract the key body (second field) for dedup — ignores comment differences
KEY_BODY=$(echo "$PUBKEY" | awk '{print $2}')

if grep -qF "$KEY_BODY" "$AUTHORIZED_KEYS" 2>/dev/null; then
  echo "Key already present in $AUTHORIZED_KEYS — nothing to do."
else
  echo "$PUBKEY" >> "$AUTHORIZED_KEYS"
  echo "Key added to $AUTHORIZED_KEYS."
fi
