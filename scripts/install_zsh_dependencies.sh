#!/usr/bin/env bash

set -euo pipefail

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

update_clone() {
  local repo_url=$1
  local dest=$2

  if [ -d "$dest/.git" ]; then
    echo "Updating $(basename "$dest")..."
    git -C "$dest" pull --ff-only
  elif [ -d "$dest" ]; then
    echo "Skipping $dest because it exists but is not a git repo" >&2
  else
    echo "Cloning $repo_url -> $dest"
    git clone "$repo_url" "$dest"
  fi
}

require_cmd git
require_cmd curl

echo "Using ZSH directory: $ZSH_DIR"

if [ ! -d "$ZSH_DIR" ]; then
  echo "Installing oh-my-zsh via the official installer..."
  # --keep-zshrc: never replace ~/.zshrc (it is a stow symlink into this repo).
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
else
  echo "oh-my-zsh already present."
fi

mkdir -p "$ZSH_CUSTOM_DIR/plugins"

update_clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

update_clone https://github.com/zsh-users/zsh-autosuggestions.git \
  "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"

if ! command -v starship >/dev/null 2>&1; then
  echo "Note: starship not found. Install it via 'brew bundle' from the repo Brewfile." >&2
fi

echo "zsh dependencies ready. Start a new shell or reload ~/.zshrc."
