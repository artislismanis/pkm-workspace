# Manual Testing Checklist

Testing the PKM Docker container alongside the obsidian-claude-sandbox plugin.

## Prerequisites

- [ ] WSL2 with Docker Engine installed
- [ ] WSL2 mirrored networking enabled (`networkingMode=mirrored` in `.wslconfig`)
- [ ] An Obsidian vault with some test files
- [ ] Claude Code subscription authenticated

---

## 1. Container Build and Start

```bash
cp .env.example .env
# Edit .env — set PKM_VAULT_PATH to your vault
docker compose build
docker compose up -d
```

- [ ] `docker compose build` completes without errors
- [ ] `docker compose up -d` starts successfully
- [ ] `docker compose ps` shows `pkm-sandbox` as **healthy**

## 2. Verify Script

```bash
docker compose exec pkm bash /workspace/scripts/verify.sh
```

- [ ] All tool versions print (Node, npm, git, tmux, ttyd, jq, Claude, gh, delta, fzf, rg, fd, atuin, uv, Python)
- [ ] No warnings for vault mount (shows item count)
- [ ] ttyd shows as listening on port 7681

## 3. Web Terminal (ttyd)

- [ ] Open http://localhost:7681 in browser — terminal loads
- [ ] tmux session is active (status bar visible at bottom)
- [ ] Can type commands and see output
- [ ] Terminal resizes when browser window resizes (`-W` flag working)

> **Note:** Copy/paste in the browser — hold **Shift** while selecting text to
> ensure the browser handles selection (bypassing any terminal capture), then
> copy with Ctrl+C as usual. This is only relevant when accessing ttyd directly
> in a browser, not via the Obsidian plugin's WebSocket connection.

## 4. Vault Mount

```bash
# Inside the container
ls /workspace/vault/
```

- [ ] Vault files are visible inside container
- [ ] Create a test file inside container: `echo "test" > /workspace/vault/_test-from-container.md`
- [ ] File appears on host filesystem immediately
- [ ] Edit a file on host — change is visible inside container immediately
- [ ] Clean up: `rm /workspace/vault/_test-from-container.md`

## 5. Claude Code CLI

```bash
# Inside the container
claude --version
claude
```

- [ ] `claude --version` prints version
- [ ] `claude` launches and authenticates via subscription (no API key prompt)
- [ ] Claude can read vault files (ask it to list files in `/workspace/vault/`)
- [ ] Claude can create a file in the vault (ask it to create a test note)
- [ ] Clean up any test files

## 6. Obsidian Plugin Connection

In Obsidian with the obsidian-claude-sandbox plugin:

- [ ] Plugin settings show `localhost:7681` as the terminal URL
- [ ] Plugin connects to the container via WebSocket
- [ ] Can send commands through the plugin
- [ ] Command output is received back in Obsidian
- [ ] Connection survives idle periods (no unexpected disconnects)

## 7. Plugin + Claude Code Integration

- [ ] Plugin can launch Claude Code in the container
- [ ] Claude can read vault content when invoked through the plugin
- [ ] Claude can create/edit vault files through the plugin
- [ ] Changes made by Claude appear in Obsidian immediately (file explorer updates)

## 8. Container Lifecycle

```bash
docker compose restart
```

- [ ] After restart, ttyd is accessible again
- [ ] tmux session is fresh (expected — sessions don't persist across restarts)
- [ ] Vault mount still works after restart

```bash
docker compose down
docker compose up -d
```

- [ ] Container comes back up healthy after down/up cycle
- [ ] Named volumes preserve Claude Code config (`pkm-claude-config`)
- [ ] Named volumes preserve atuin history (`pkm-atuin-history`)

## 9. Port Remapping (optional)

```bash
# In .env, set:
# TTYD_PORT=8080
docker compose up -d
```

- [ ] ttyd is accessible on http://localhost:8080
- [ ] Plugin can connect when configured with the custom port

## 10. Network Firewall (optional)

```bash
docker compose exec pkm sudo /usr/local/bin/init-firewall.sh
```

- [ ] Script runs without errors, prints IP count
- [ ] `curl https://api.anthropic.com` works (allowlisted)
- [ ] `curl https://example.com` fails (not allowlisted)
- [ ] Claude Code still functions with firewall active
- [ ] Disable with: `docker compose exec pkm sudo iptables -F OUTPUT`

## 11. Resource Limits (optional)

Uncomment `deploy` section in `docker-compose.yml`, then:

```bash
docker compose up -d
```

- [ ] Container starts with memory/CPU limits applied
- [ ] `docker stats pkm-sandbox` shows the limits

---

## Teardown

```bash
docker compose down
# To also remove named volumes (Claude config, atuin history):
# docker compose down -v
```
