export LESSCHARSET=utf-8
export NVM_DIR="$HOME/.nvm"
export FZF_COMPLETION_TRIGGER='**'

export ZSH="$HOME/.oh-my-zsh"
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source "$ZSH/oh-my-zsh.sh"

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

alias sd="cd ~ && cd \$(fd -t d | fzf)"
alias pf="fzf --preview='bat --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
alias ta="tmux attach"
alias k='kubectl'

# Local tools that may not exist on every machine
[ -x "$HOME/dev/go-to-repo/target/release/go-to-repo" ] && alias gtr="~/dev/go-to-repo/target/release/go-to-repo"
[ -f "$HOME/dev/scripts/colima_testcontainers.sh" ] && alias colimatest="~/dev/scripts/colima_testcontainers.sh"
[ -f "$HOME/dev/scripts/work-diary.sh" ] && alias wd="sh $HOME/dev/scripts/work-diary.sh"

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

# Function to initialize nvm and bash completions
load_nvm() {
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Lazy-load SDKMAN — its init script costs ~300-500ms. Same pattern as nvm above.
export SDKMAN_DIR="$HOME/.sdkman"
load_sdkman() {
  unset -f sdk java javac jar mvn gradle kotlin kotlinc scala springboot 2>/dev/null
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
}
for cmd in sdk java javac jar mvn gradle kotlin kotlinc scala springboot; do
  lazyload $cmd load_sdkman
done

