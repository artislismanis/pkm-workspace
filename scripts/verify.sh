#!/bin/bash
set -euo pipefail

echo "=== PKM Sandbox — Environment Verification ==="

# Tool versions
echo "Node:    $(node --version 2>&1)"
echo "npm:     $(npm --version 2>&1)"
echo "git:     $(git --version 2>&1)"
echo "tmux:    $(tmux -V 2>&1)"
echo "ttyd:    $(ttyd --version 2>&1 | head -1)"
echo "jq:      $(jq --version 2>&1)"
echo "Claude:  $(claude --version 2>&1)"
echo "gh:      $(gh --version 2>&1 | head -1)"
echo "delta:   $(delta --version 2>&1 | head -1)"
echo "fzf:     $(fzf --version 2>&1 | head -1)"
echo "uv:      $(uv --version 2>&1)"
echo "Python:  $($(uv python find 2>/dev/null) --version 2>&1 || echo 'not found')"

# Vault mount check
echo ""
if [ -d "/workspace/vault" ] && [ "$(ls -A /workspace/vault 2>/dev/null)" ]; then
  VAULT_ITEMS=$(ls -1 /workspace/vault | wc -l)
  echo "Vault:   mounted at /workspace/vault (${VAULT_ITEMS} items)"
else
  echo "WARNING: No vault found at /workspace/vault"
  echo "  Set PKM_VAULT_PATH in .env and restart the container"
fi

# API key check (existence only, never print the value)
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  echo "API Key: set (${#ANTHROPIC_API_KEY} chars)"
else
  echo "WARNING: ANTHROPIC_API_KEY is not set"
  echo "  Add it to .env and restart the container"
fi

# ttyd reachability (only meaningful when ttyd is running)
if curl -sf http://localhost:7681/ > /dev/null 2>&1; then
  echo "ttyd:    listening on port 7681"
else
  echo "ttyd:    not yet listening (normal during build or exec)"
fi

echo ""
echo "To enable network sandboxing: sudo /usr/local/bin/init-firewall.sh"
echo "=== Done ==="
