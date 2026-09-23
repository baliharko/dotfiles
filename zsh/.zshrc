# Keep PATH/fpath free of duplicates. Without this, every nested shell
# re-prepends the entries below and both lists grow without bound.
typeset -U path fpath

# Homebrew is not on the default macOS PATH; nothing else guarantees this on
# a fresh machine (no .zprofile is stowed).
#
# brew, starship, zoxide and fzf each want an `eval "$(<tool> init)"`. That is
# four forks (~31ms) on every shell, and their output only changes when the
# binaries do — so generate it once and source the result.
_zsh_init_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init.zsh"
() {
  local f stale=
  [[ -f $_zsh_init_cache ]] || stale=1   # -f, not -s: a brew-less box caches nothing
  for f in /opt/homebrew/bin/{brew,starship,zoxide,fzf}; do
    [[ $f -nt $_zsh_init_cache ]] && stale=1
  done
  [[ -n $stale ]] || return

  mkdir -p "${_zsh_init_cache:h}"
  (
    if [[ -x /opt/homebrew/bin/brew ]]; then
      /opt/homebrew/bin/brew shellenv
      eval "$(/opt/homebrew/bin/brew shellenv)"   # so the tools below resolve
    fi
    (( $+commands[starship] )) && starship init zsh
    (( $+commands[zoxide]   )) && zoxide init zsh
    (( $+commands[fzf]      )) && fzf --zsh   # ^R history, ^T files, M-c cd
  ) >| "$_zsh_init_cache.new" && command mv -f "$_zsh_init_cache.new" "$_zsh_init_cache"
  command rm -f "$_zsh_init_cache.new"
}
source "$_zsh_init_cache"
unset _zsh_init_cache

# brew's shellenv exports FPATH. If it reaches a child shell, oh-my-zsh there
# sees a different fpath, concludes ~/.zcompdump is stale and rebuilds it
# (~300ms) — and then the next top-level shell does the same, forever. Keeping
# FPATH process-local breaks that loop.
typeset +x FPATH

export LESSCHARSET=utf-8
export NVM_DIR="$HOME/.nvm"
export FZF_COMPLETION_TRIGGER='**'

export ZSH="$HOME/.oh-my-zsh"

# Startup-cost knobs, measured on this machine:
#   ~33ms  url-quote-magic / bracketed-paste-magic. Ghostty does bracketed
#          paste itself, so this only gives up auto-quoting of pasted URLs.
#   ~15ms  compaudit's world-writable scan over every fpath directory.
DISABLE_MAGIC_FUNCTIONS=true
ZSH_DISABLE_COMPFIX=true
# Otherwise curls api.github.com every 13 days, then blocks the shell on an
# interactive y/N. `omz update` still works on demand.
zstyle ':omz:update' mode disabled
# starship draws the prompt, so oh-my-zsh's async git machinery has no consumer.
zstyle ':omz:alpha:lib:git' async-prompt no

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source "$ZSH/oh-my-zsh.sh"

alias sd="cd ~ && cd \$(fd -t d | fzf)"
alias pf="fzf --preview='bat --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
alias ta="tmux attach"
alias k='kubectl'

bindkey -v
bindkey "^r^r" history-incremental-search-backward
bindkey "^s^s" history-incremental-search-forward

lazyload() {
    local cmd=$1
    local loader_func=$2
    eval "$cmd() {
        unset -f $cmd
        $loader_func
        $cmd \"\$@\"
    }"
}

idea() {
    open -a "IntelliJ IDEA" "$1"
}

alias assume=". assume"

dr() {
    docker rm -f $(docker ps -aq);
    docker volume rm $(docker volume ls -q);
    docker system prune -a --volumes --force;
}

# Function to initialize nvm and bash completions
load_nvm() {
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

# Lazy load nvm when any of these commands are called
for cmd in nvm node npm npx; do
  lazyload $cmd load_nvm
done

if command -v colima >/dev/null 2>&1; then
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
  export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"

  # TESTCONTAINERS_HOST_OVERRIDE is colima's VM address. Computing it
  # (`colima ls -j | jq`) costs ~480ms, so cache it and only recompute when
  # colima's state actually changes.
  _colima_addr_cache="${XDG_CACHE_HOME:-$HOME/.cache}/colima-address"
  _refresh_colima_addr() {
    mkdir -p "${_colima_addr_cache:h}"
    colima ls -j 2>/dev/null | jq -r '.address' > "$_colima_addr_cache"
    export TESTCONTAINERS_HOST_OVERRIDE="$(<"$_colima_addr_cache")"
  }
  alias tcrefresh=_refresh_colima_addr

  if [[ -r "$_colima_addr_cache" ]]; then
    export TESTCONTAINERS_HOST_OVERRIDE="$(<"$_colima_addr_cache")"
  else
    # First run after adopting this: populate in the background so startup
    # never blocks on colima. The var becomes available from the next shell.
    _refresh_colima_addr &>/dev/null &!
  fi

  # Keep the cache correct: refresh whenever colima's state changes.
  colima() {
    command colima "$@"
    local rc=$?
    case "$1" in
      start|stop|restart|delete) _refresh_colima_addr ;;
    esac
    return $rc
  }
fi

# opencode
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

# User-installed scripts and binaries
export PATH="$HOME/.local/bin:$PATH"

# Lazy-load SDKMAN — its init script costs ~300-500ms. Same pattern as nvm above.
export SDKMAN_DIR="$HOME/.sdkman"
load_sdkman() {
  unset -f sdk java javac jar 2>/dev/null
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
}
for cmd in sdk java javac jar; do
  lazyload $cmd load_sdkman
done

# Work-specific config (profiles, cluster names) lives outside this public repo.
[[ -r ~/.zshrc.work ]] && source ~/.zshrc.work
