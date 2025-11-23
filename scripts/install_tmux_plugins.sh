#!/usr/bin/env bash

set -euo pipefail

TMUX_PLUGIN_MANAGER_PATH="${TMUX_PLUGIN_MANAGER_PATH:-$HOME/.tmux/plugins}"
TPM_DIR="${TPM_DIR:-$TMUX_PLUGIN_MANAGER_PATH/tpm}"

echo "tmux plugin directory: ${TMUX_PLUGIN_MANAGER_PATH}"

if [ ! -d "$TMUX_PLUGIN_MANAGER_PATH" ]; then
  mkdir -p "$TMUX_PLUGIN_MANAGER_PATH"
fi

if [ ! -d "$TPM_DIR" ]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "git is required to install tmux plugins" >&2
    exit 1
  fi

  echo "Installing tmux plugin manager (tpm)..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "tpm already present at $TPM_DIR"
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux must be installed to install plugins" >&2
  exit 1
fi

if [ ! -x "$TPM_DIR/scripts/install_plugins.sh" ]; then
  echo "tpm install script not found at $TPM_DIR/scripts/install_plugins.sh" >&2
  exit 1
fi

echo "Installing tmux plugins via tpm..."
tmux start-server
tmux new-session -d -s __tpm-install 2>/dev/null || true
"$TPM_DIR/scripts/install_plugins.sh"
tmux kill-session -t __tpm-install 2>/dev/null || true

echo "Done. Restart tmux or reload the config to pick up any new plugins."
