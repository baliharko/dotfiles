# Dotfiles

Config files for macOS (Apple Silicon), managed with GNU Stow. Each subfolder
(e.g. `zsh`, `nvim`, `tmux`) is a Stow package that mirrors the home directory
layout and gets symlinked into `$HOME`.

## Quick start

```
git clone https://github.com/baliharko/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent — re-run it any time. What it does, in order:

1. Installs Homebrew if missing.
2. Installs everything in the `Brewfile` (CLI tools, colima/kubectl, Ghostty,
   Karabiner-Elements, AeroSpace, JetBrains Mono Nerd Font). Apps that were
   installed manually are adopted by brew instead of failing.
3. Stows all packages. Any pre-existing file in the way is moved to
   `~/.dotfiles-backup/<timestamp>/` — nothing is merged or overwritten in place.
4. Sets up oh-my-zsh (official installer, unattended, never touches the stowed
   `.zshrc`) and its plugins (`scripts/install_zsh_dependencies.sh`).
5. Installs tpm and the tmux plugins (`scripts/install_tmux_plugins.sh`).
6. Optionally builds and installs [aerospace-yoink](https://github.com/baliharko/aerospace-yoink)
   (see below). Skip with `--no-yoink`, force with `--yoink`.

Afterwards: grant Karabiner-Elements and AeroSpace their permissions in System
Settings, and open a new shell.

## Manual use

Individual packages can still be stowed on their own from the repo root:

```
stow zsh
```

Both helper scripts in `scripts/` are idempotent and re-runnable standalone,
e.g. after adding a tmux plugin to `tmux/.config/tmux/tmux.conf`:

```
./scripts/install_tmux_plugins.sh
```

## aerospace-yoink

The AeroSpace config uses [aerospace-yoink](https://github.com/baliharko/aerospace-yoink)
to pull windows from other workspaces. It runs as a daemon on startup and is
bound to `hyper+y`. The AeroSpace config expects the binary at
`/usr/local/bin/yoink`.

`install.sh` handles this (clone, `swift build -c release`, sudo-install to
`/usr/local/bin`). To do it manually:

```
cd ~/dev
git clone https://github.com/baliharko/aerospace-yoink.git
cd aerospace-yoink
swift build -c release
sudo install -m 755 .build/release/yoink /usr/local/bin/yoink
```
