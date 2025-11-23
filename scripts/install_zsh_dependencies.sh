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

echo "Using ZSH directory: $ZSH_DIR"

if [ ! -d "$ZSH_DIR" ]; then
  echo "Installing oh-my-zsh..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
else
  echo "oh-my-zsh already present."
fi

mkdir -p "$ZSH_CUSTOM_DIR/plugins"

update_clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

update_clone https://github.com/zsh-users/zsh-autosuggestions.git \
  "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"

if command -v starship >/dev/null 2>&1; then
  echo "starship already installed."
else
  if command -v brew >/dev/null 2>&1; then
    echo "Installing starship via Homebrew..."
    brew install starship
  else
    cat <<'EOF'
starship not found and Homebrew is unavailable.
Install manually from https://starship.rs/ or run:
  curl -sS https://starship.rs/install.sh | sh -s -- -y
EOF
  fi
fi

echo "zsh dependencies ready. Start a new shell or reload ~/.zshrc."
