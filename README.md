# Dotfiles

This directory is a collection of my personal configuration files that I manage with GNU Stow.
Each subfolder (e.g. `zsh`, `nvim`, `tmux`) is a Stow package that I symlink into my home
directory by running `stow <package>` from this folder.

## Dependencies

Command-line tools used across these configs (install via Homebrew or your package manager):
- `tmux`
- `fzf` (fuzzy finder)
- `fd` (used for directory jumping)
- `bat` (fzf previews)
- `ripgrep` (Neovim search)

using Homebrew:

```
brew install git tmux fzf fd bat ripgrep
```

## tmux plugins

Run `./scripts/install_tmux_plugins.sh` to clone `tpm` and install the plugins declared in `tmux/.config/tmux/.tmux.conf`.
The script is idempotent and can be re-run after updating plugin definitions.

## zsh dependencies

Run `./scripts/install_zsh_dependencies.sh` to set up oh-my-zsh, clone `zsh-syntax-highlighting` and `zsh-autosuggestions`, and install Starship (uses Homebrew when available).
