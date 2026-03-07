#!/bin/bash
set -e

echo "=== PKM Workspace — Verifying base environment ==="
echo "Node:   $(node --version)"
echo "npm:    $(npm --version)"
echo "jq:     $(jq --version)"
echo "Claude: $(claude --version)"
echo "gh:     $(gh --version 2>&1 | head -1)"
echo "delta:  $(delta --version 2>&1 | head -1)"
echo "fzf:    $(fzf --version 2>&1 | head -1)"
echo "uv:     $(uv --version)"
echo "Python: $(uv run python --version 2>&1)"

# Verify vault is mounted
if [ -d "/workspace/vault" ] && [ "$(ls -A /workspace/vault 2>/dev/null)" ]; then
  VAULT_DIRS=$(find /workspace/vault -maxdepth 1 -type d | wc -l)
  echo "Vault:  mounted at /workspace/vault ($((VAULT_DIRS - 1)) top-level directories)"
else
  echo ""
  echo "WARNING: No vault mounted at /workspace/vault"
  echo "  1. Copy .devcontainer/.env.example to .devcontainer/.env"
  echo "  2. Set PKM_VAULT_PATH to your Obsidian vault path"
  echo "  3. Rebuild the container"
fi

# Command history persistence
if [ -f "/commandhistory/.zsh_history" ]; then
  echo "History: persistent volume mounted"
else
  echo "WARNING: Command history volume not mounted"
fi

echo ""
echo "To enable network sandboxing: sudo /usr/local/bin/init-firewall.sh"
echo "=== Done ==="
