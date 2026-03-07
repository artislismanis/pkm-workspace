FROM mcr.microsoft.com/devcontainers/typescript-node:22-trixie

# ── Version ARGs ───────────────────────────────────────────
ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.18.2
ARG ZSH_IN_DOCKER_VERSION=1.2.0
ARG PYTHON_VERSION=3.12

# ══════════════════════════════════════════════════════════
# Phase 1: ROOT operations (system packages, binaries, perms)
# ══════════════════════════════════════════════════════════

# System packages (base image provides system python3)
RUN apt-get update && apt-get install -y \
    jq \
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    aggregate \
    fzf \
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

# uv (Python version & package manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Firewall script + sudoers for node user
COPY .devcontainer/init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh \
    && echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" \
       > /etc/sudoers.d/node-firewall \
    && chmod 0440 /etc/sudoers.d/node-firewall

# Prepare directories with node ownership
RUN mkdir -p /usr/local/share/npm-global /commandhistory /home/node/.claude /workspace \
    && touch /commandhistory/.zsh_history \
    && chown -R node:node /usr/local/share/npm-global /workspace \
       /commandhistory /home/node/.claude

# ══════════════════════════════════════════════════════════
# Phase 2: NODE user operations (shell, npm globals, theme)
# ══════════════════════════════════════════════════════════
USER node

ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin
ENV SHELL=/bin/zsh
ENV EDITOR=nano
ENV VISUAL=nano

# Powerlevel10k + zsh plugins
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history" \
  -x

# Python via uv (userspace-managed)
RUN uv python install ${PYTHON_VERSION}

# Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

WORKDIR /workspace
