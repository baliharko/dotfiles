# Dotfiles

I keep my config files here and manage them with GNU Stow. Each subfolder (e.g. `zsh`, `nvim`,
`tmux`) is a Stow package you can symlink into your home directory by running
`stow <package>` from the repo root.

## Dependencies

Command-line tools used across these configs (install via Homebrew or your package manager):
- `tmux`
- `fzf` (fuzzy finder)
- `fd` (used for directory jumping)
- `bat` (fzf previews)
- `ripgrep` (Neovim search)

Using Homebrew:

```
brew install git tmux fzf fd bat ripgrep
```

## tmux plugins

Run `./scripts/install_tmux_plugins.sh` to clone `tpm` and install the plugins declared in `tmux/.config/tmux/.tmux.conf`.
The script is idempotent and can be re-run after updating plugin definitions.

## zsh dependencies

Run `./scripts/install_zsh_dependencies.sh` to set up oh-my-zsh, clone `zsh-syntax-highlighting` and `zsh-autosuggestions`, and install Starship (uses Homebrew when available).
