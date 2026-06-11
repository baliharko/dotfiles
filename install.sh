#!/usr/bin/env bash
#
# Bootstrap this dotfiles repo on a fresh (or existing) Apple Silicon Mac.
# Idempotent: safe to re-run at any time.
#
# Usage: ./install.sh [--yoink | --no-yoink]
#   --yoink     build and install aerospace-yoink without asking
#   --no-yoink  skip aerospace-yoink

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(aerospace ghostty htop karabiner nvim tmux zsh)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BACKUP_USED=0
YOINK_MODE="ask" # ask | yes | no

log() {
  echo "==> $*"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

usage() {
  sed -n '3,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --yoink) YOINK_MODE="yes" ;;
      --no-yoink) YOINK_MODE="no" ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
  done
}

require_macos() {
  if [ "$(uname -s)" != "Darwin" ]; then
    echo "This script only supports macOS." >&2
    exit 1
  fi
  if [ "$(uname -m)" != "arm64" ]; then
    echo "This script assumes Apple Silicon (Homebrew at /opt/homebrew)." >&2
    exit 1
  fi
  if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root." >&2
    exit 1
  fi
}

ensure_homebrew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    log "Homebrew already installed."
  else
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_packages() {
  log "Installing packages from Brewfile..."
  # --adopt: take over apps/fonts that were installed manually instead of failing.
  # NO_UPGRADE: only install what's missing, never bump existing versions.
  if ! HOMEBREW_CASK_OPTS="--adopt" HOMEBREW_BUNDLE_NO_UPGRADE=1 \
    brew bundle --file="$REPO_DIR/Brewfile"; then
    echo "Warning: some Brewfile entries failed; continuing with setup." >&2
    echo "Fix the errors above and re-run ./install.sh (or brew bundle)." >&2
  fi
  # The rest of the setup cannot work without these.
  require_cmd stow
  require_cmd git
  require_cmd tmux
}

# Move any real file (or foreign symlink) out of the way so stow can link.
# Symlinks that already resolve into this repo are left alone.
backup_conflicts() {
  local pkg=$1 src rel target resolved
  while IFS= read -r src; do
    rel="${src#"$REPO_DIR/$pkg/"}"
    target="$HOME/$rel"
    if [ -e "$target" ] || [ -L "$target" ]; then
      resolved="$(readlink -f "$target" 2>/dev/null || true)"
      case "$resolved" in
        "$REPO_DIR"/*) continue ;;
      esac
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
      BACKUP_USED=1
      echo "    backed up: ~/$rel"
    fi
  done < <(find "$REPO_DIR/$pkg" -type f -not -name .DS_Store)
}

stow_packages() {
  log "Stowing packages: ${PACKAGES[*]}"
  # Pre-create ~/.config so stow links package subdirs instead of folding
  # ~/.config itself into a symlink pointing at the repo.
  mkdir -p "$HOME/.config"
  local pkg
  for pkg in "${PACKAGES[@]}"; do
    backup_conflicts "$pkg"
    # --no-folding: link files individually instead of symlinking whole
    # directories, so runtime files (tmux plugins, karabiner backups)
    # land outside the repo.
    stow -d "$REPO_DIR" -t "$HOME" --restow --no-folding --ignore='\.DS_Store' "$pkg"
  done
}

maybe_install_yoink() {
  if [ "$YOINK_MODE" = "no" ]; then
    log "Skipping aerospace-yoink (--no-yoink)."
    return 0
  fi
  if [ "$YOINK_MODE" = "ask" ]; then
    if [ -t 0 ]; then
      read -r -p "Install aerospace-yoink (builds with Swift, needs sudo)? [Y/n] " answer
      case "$answer" in
        [nN]*) log "Skipping aerospace-yoink."; return 0 ;;
      esac
    else
      log "Skipping aerospace-yoink (non-interactive; use --yoink to force)."
      return 0
    fi
  fi
  if ! command -v swift >/dev/null 2>&1; then
    log "Skipping aerospace-yoink: swift not found (install Xcode command line tools)."
    return 0
  fi

  local src_dir="$HOME/dev/aerospace-yoink"
  local binary="$src_dir/.build/release/yoink"
  if [ -d "$src_dir/.git" ]; then
    log "Updating aerospace-yoink..."
    git -C "$src_dir" pull --ff-only
  elif [ -d "$src_dir" ]; then
    echo "Skipping clone: $src_dir exists but is not a git repo" >&2
  else
    log "Cloning aerospace-yoink..."
    mkdir -p "$HOME/dev"
    git clone https://github.com/baliharko/aerospace-yoink.git "$src_dir"
  fi

  log "Building aerospace-yoink..."
  (cd "$src_dir" && swift build -c release)

  if cmp -s "$binary" /usr/local/bin/yoink 2>/dev/null; then
    log "aerospace-yoink already up to date at /usr/local/bin/yoink."
  else
    log "Installing yoink to /usr/local/bin (sudo)..."
    sudo mkdir -p /usr/local/bin
    sudo install -m 755 "$binary" /usr/local/bin/yoink
  fi
}

print_summary() {
  log "Done."
  if [ "$BACKUP_USED" -eq 1 ]; then
    echo "    Pre-existing files were backed up to: $BACKUP_DIR"
  fi
  cat <<'EOF'
    Manual follow-ups:
      - Grant Karabiner-Elements and AeroSpace their permissions in System Settings.
      - Open a new shell (or restart your terminal) to load the zsh config.
      - Restart tmux (when convenient) to pick up the tmux config.
EOF
}

main() {
  parse_args "$@"
  require_macos
  ensure_homebrew
  install_packages
  stow_packages
  bash "$REPO_DIR/scripts/install_zsh_dependencies.sh"
  bash "$REPO_DIR/scripts/install_tmux_plugins.sh"
  maybe_install_yoink
  print_summary
}

main "$@"
