FROM ubuntu:24.04

# ── Version ARGs ─────────────────────────────────────────────
ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.18.2
ARG PYTHON_VERSION=3.12
ARG NODE_MAJOR=22
ARG TTYD_VERSION=1.7.7
ARG NVM_VERSION=0.40.3

# ══════════════════════════════════════════════════════════════
# Phase 1: ROOT — system packages, binaries, permissions
# ══════════════════════════════════════════════════════════════

ENV DEBIAN_FRONTEND=noninteractive

# System packages
RUN apt-get update && apt-get install -y \
    curl git tmux jq fzf ca-certificates gnupg \
    iptables ipset iproute2 dnsutils aggregate sudo \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# git-delta (better diffs)
RUN ARCH="$(dpkg --print-architecture)" \
    && curl -fsSL "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" \
       -o /tmp/git-delta.deb \
    && dpkg -i /tmp/git-delta.deb \
    && rm /tmp/git-delta.deb

# ttyd (web terminal — architecture-aware)
RUN ARCH="$(dpkg --print-architecture)" \
    && if [ "$ARCH" = "arm64" ]; then TTYD_ARCH="aarch64"; else TTYD_ARCH="x86_64"; fi \
    && curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" \
       -o /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# uv (Python version & package manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Create non-root user
RUN useradd -m -s /bin/bash claude \
    && mkdir -p /workspace /home/claude/.claude \
    && chown -R claude:claude /workspace /home/claude/.claude

# Firewall script + sudoers
COPY scripts/init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh \
    && echo "claude ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" \
       > /etc/sudoers.d/claude-firewall \
    && chmod 0440 /etc/sudoers.d/claude-firewall

# tmux config
COPY .tmux.conf /home/claude/.tmux.conf
RUN chown claude:claude /home/claude/.tmux.conf

# ══════════════════════════════════════════════════════════════
# Phase 2: claude user — nvm, Node, Python, Claude Code
# ══════════════════════════════════════════════════════════════
USER claude
ENV NVM_DIR=/home/claude/.nvm

# nvm + Node
RUN curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install "${NODE_MAJOR}" \
    && nvm alias default "${NODE_MAJOR}"

# Make node/npm available to non-interactive shells (Docker RUN, healthcheck, etc.)
# nvm installs to a versioned path; create a stable symlink
RUN NODE_PATH=$(find "$NVM_DIR/versions/node" -maxdepth 1 -name "v${NODE_MAJOR}.*" | head -1) \
    && ln -s "$NODE_PATH" "$NVM_DIR/default"
ENV PATH=/home/claude/.nvm/default/bin:$PATH

# Python via uv (userspace-managed)
RUN uv python install "${PYTHON_VERSION}"

# Claude Code CLI
RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"

WORKDIR /workspace
EXPOSE 7681
