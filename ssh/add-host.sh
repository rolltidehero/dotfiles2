#!/usr/bin/env bash
# add-host.sh — run locally to add a new host entry to ~/.ssh/config.
# Usage:
#   bash add-host.sh <Host> <HostName> <User> [IdentityFile]
#
# Example:
#   bash ssh/add-host.sh host 1.1.1.1 ubuntu ~/.ssh/private-key

set -euo pipefail

SSH_CONFIG="$HOME/.ssh/config"

HOST="${1:-}"
HOSTNAME="${2:-}"
USER="${3:-}"
IDENTITY="${4:-}"

# --- Prompt for any missing args ---
if [[ -z "$HOST" ]]; then
  read -r -p "Host alias (e.g. gcp640426_2): " HOST
fi
if [[ -z "$HOSTNAME" ]]; then
  read -r -p "HostName / IP address:          " HOSTNAME
fi
if [[ -z "$USER" ]]; then
  read -r -p "User:                           " USER
fi
if [[ -z "$IDENTITY" ]]; then
  read -r -p "IdentityFile (leave blank to skip): " IDENTITY
fi

if [[ -z "$HOST" || -z "$HOSTNAME" || -z "$USER" ]]; then
  echo "Error: Host, HostName, and User are required." >&2
  exit 1
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

# Check if the Host block already exists
if grep -qE "^Host[[:space:]]+${HOST}([[:space:]]|$)" "$SSH_CONFIG" 2>/dev/null; then
  echo "Entry 'Host $HOST' already exists in $SSH_CONFIG — nothing to do."
  exit 0
fi

# Build the entry
{
  echo ""
  echo "Host $HOST"
  echo "    HostName $HOSTNAME"
  echo "    User $USER"
  echo "    ServerAliveInterval 120"
  [[ -n "$IDENTITY" ]] && echo "    IdentityFile $IDENTITY"
} >> "$SSH_CONFIG"

echo "Added to $SSH_CONFIG:"
echo ""
echo "  Host $HOST"
echo "      HostName $HOSTNAME"
echo "      User $USER"
echo "      ServerAliveInterval 120"
[[ -n "$IDENTITY" ]] && echo "      IdentityFile $IDENTITY"
