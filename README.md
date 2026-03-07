# PKM Workspace

A devcontainer for working with Obsidian vaults using Claude Code. Tooling lives in this repo; your vault is bind-mounted into the container, keeping content separate from configuration.

## Prerequisites

- **Docker Desktop** (or equivalent container runtime)
- **VS Code** with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

## Setup

1. Clone this repo:
   ```bash
   git clone <repo-url> pkm-workspace
   ```

2. Edit the vault mount path in `.devcontainer/devcontainer.json` — update the `source` in the `mounts` array to point to your Obsidian vault:
   ```json
   "mounts": [
     "source=/path/to/your/vault,target=/workspace/vault,type=bind,consistency=cached"
   ]
   ```

   The `source` path format depends on your OS:
   - **macOS / Linux** — standard absolute path, e.g. `/Users/you/Documents/MyVault` or `/home/you/Documents/MyVault`
   - **Windows (WSL)** — use the `/mnt/` prefix, e.g. `/mnt/c/Users/you/Documents/MyVault`
   - **Windows (native)** — use a Windows-style path, e.g. `C:\Users\you\Documents\MyVault` (Docker Desktop translates it automatically)

3. Open the `pkm-workspace` folder in VS Code.

4. When prompted, click **Reopen in Container** — or run the command **Dev Containers: Reopen in Container** from the palette (`Ctrl+Shift+P`).

5. Your vault appears at `/workspace/vault/` inside the container.

## What's Inside

**Container runtimes:**
- Node 22 LTS + npm
- Python 3 + uv
- Claude Code CLI

**VS Code extensions (auto-installed):**
- Foam, Markdown All in One — wikilinks & backlinks
- Markdown preview enhancements (GitHub styles, YAML preamble, footnotes, checkboxes)
- Prettier, ESLint, Markdownlint — formatting & linting
- YAML validation, TODO Tree, Code Spell Checker
- Claude Code IDE integration

## How It Works

The devcontainer builds from a Dockerfile and bind-mounts your vault into the container. The repo itself is mounted at `/workspace`, and the vault appears at `/workspace/vault/`.

```
/workspace/                     # this repo (tooling)
  .devcontainer/
  vault/                        # your Obsidian vault (bind mount)
    ...
```

## Verification

After the container starts, check the terminal for post-create output confirming all runtimes are available and the vault is mounted. You can also verify manually:

```bash
node --version
python3 --version
claude --version
ls /workspace/vault/
```
