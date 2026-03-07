# CLAUDE.md — PKM Workspace

## Environment

- **Devcontainer** providing a self-contained tooling environment: Node 22 LTS, Python 3 + uv, jq, Claude Code CLI
- Vault bind-mounted from host at `/workspace/vault/` (configured via `mounts` in `.devcontainer/devcontainer.json`)
- Changes to vault files are **immediately reflected on the host filesystem**

## Key Paths

| Path | Purpose |
|------|---------|
| `/workspace/` | Repository root (tooling and configuration) |
| `/workspace/vault/` | The Obsidian vault (bind-mounted from host) |
| `/workspace/.devcontainer/` | Container configuration (Dockerfile, devcontainer.json) |
| `/workspace/.claude/` | Claude Code project settings |

## Safety Constraints

- **Never delete** vault files without explicit user confirmation
- **Never modify** plugin binaries or vault config directories unless specifically asked
- **Prefer non-destructive operations**: create new files or append to existing rather than overwriting
- **Bulk operations**: always describe the scope and show a sample (3–5 files) before executing

## Vault-Specific Instructions

Each vault carries its own `CLAUDE.md` with methodology, folder structure, tag taxonomy, link conventions, templates, and content workflows. See `vault/CLAUDE.md` for this vault's inner workings.
