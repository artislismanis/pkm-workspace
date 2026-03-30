#!/bin/bash
# Container entrypoint — lightweight first-run setup, then exec CMD.

# Git identity (from env vars, if provided)
if [ -n "${GIT_AUTHOR_NAME:-}" ] && ! git config --global user.name &>/dev/null; then
  git config --global user.name "$GIT_AUTHOR_NAME"
fi
if [ -n "${GIT_AUTHOR_EMAIL:-}" ] && ! git config --global user.email &>/dev/null; then
  git config --global user.email "$GIT_AUTHOR_EMAIL"
fi

exec "$@"
