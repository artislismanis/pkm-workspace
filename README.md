# PKM Workspace

A Docker container for working with Obsidian vaults using Claude Code. Provides a web terminal (ttyd) + tmux + Claude Code CLI, designed for the [obsidian-claude-sandbox](https://github.com/artislismanis/obsidian-claude-sandbox) plugin.

Tooling lives in this repo; your vault is bind-mounted into the container, keeping content separate from configuration.

## Prerequisites

- **WSL2** with a Linux distribution (e.g. Ubuntu)
- **Docker Engine** installed inside WSL2 (not Docker Desktop on Windows):
  ```bash
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo usermod -aG docker $USER
  ```
- **WSL2 mirrored networking** — create/edit `%USERPROFILE%\.wslconfig` on Windows:
  ```ini
  [wsl2]
  networkingMode=mirrored
  ```
  Then restart WSL: `wsl --shutdown` from PowerShell.
- **Anthropic API key**

## Quick Start

```bash
# Clone the repo (inside WSL)
git clone <repo-url> pkm-workspace
cd pkm-workspace

# Configure environment
cp .env.example .env
# Edit .env: set ANTHROPIC_API_KEY, PKM_VAULT_PATH, and git identity

# Build and start
docker compose up -d

# Verify
docker compose exec pkm bash /workspace/scripts/verify.sh
```

The web terminal is available at [http://localhost:7681](http://localhost:7681). The Obsidian plugin connects here automatically.

## Vault Mount

Set `PKM_VAULT_PATH` in your `.env` file to the host path of your Obsidian vault:

| OS | Example path |
|----|-------------|
| WSL (recommended) | `/mnt/c/Users/you/Documents/MyVault` |
| Linux native | `/home/you/Documents/MyVault` |
| macOS | `/Users/you/Documents/MyVault` |

Changes to vault files inside the container are immediately reflected on the host filesystem.

## What's Inside

**Runtimes:**
- Node 22 LTS (via nvm)
- Python 3.12 (via uv)
- Claude Code CLI

**Tools:**
- ttyd (web terminal) + tmux (terminal multiplexer)
- ripgrep (`rg`) + fd — fast search and file finding
- GitHub CLI (`gh`)
- git-delta (better diffs)
- atuin (shell history with fuzzy search)
- fzf (fuzzy finder)
- jq (JSON processor), tree, nano

**Security:**
- Optional network sandboxing via allowlist-based firewall:
  ```bash
  docker compose exec pkm sudo /usr/local/bin/init-firewall.sh
  ```

## Configuration

### Git Identity

Set `GIT_AUTHOR_NAME` and `GIT_AUTHOR_EMAIL` in `.env` — the entrypoint configures `git config --global` on container start. Required for committing.

### Authentication (optional)

To password-protect the terminal, uncomment and edit the `command` in `docker-compose.yml`:

```yaml
command: ["ttyd", "-W", "-p", "7681", "--credential", "user:changeme", "tmux", "new-session", "-A", "-s", "main"]
```

Configure matching credentials in the Obsidian plugin settings (`ttydUsername` / `ttydPassword`).

### Resource Limits (optional)

Uncomment the `deploy` section in `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      memory: 4G
      cpus: "2.0"
```

## File Structure

```
pkm-workspace/
├── Dockerfile              # Container image (Ubuntu 24.04 + all tools)
├── docker-compose.yml      # Service definition (ttyd + tmux)
├── .tmux.conf              # tmux defaults (copied into image)
├── .env.example            # Configuration template
├── .dockerignore           # Build context exclusions
├── scripts/
│   ├── entrypoint.sh       # Container entrypoint (git config, etc.)
│   ├── verify.sh           # Environment validation
│   └── init-firewall.sh    # Network sandboxing (optional)
├── CLAUDE.md               # Instructions for Claude Code inside container
└── README.md
```

## Commands

```bash
docker compose up -d        # Start container
docker compose down          # Stop container
docker compose ps            # Check status (should show "healthy")
docker compose restart       # Restart container
docker compose logs -f       # View logs
docker compose build         # Rebuild image after Dockerfile changes
```

## Verification

After starting the container:

1. `docker compose ps` — service shows as **healthy**
2. `docker compose exec pkm bash /workspace/scripts/verify.sh` — all tools present
3. Open [http://localhost:7681](http://localhost:7681) — ttyd web terminal loads
4. In the terminal: `claude --version` and `ls /workspace/vault/`
