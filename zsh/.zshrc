export LESSCHARSET=utf-8
export NVM_DIR="$HOME/.nvm"
export SDKMAN_DIR="$HOME/.sdkman"
export FZF_COMPLETION_TRIGGER=**

export ZSH="$HOME/.oh-my-zsh"
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

alias df-git='/usr/bin/git --git-dir=$HOME/.cache/df-git --work-tree=/Users/balazs.harko/'
alias tmux='tmux -u'
alias lg='sh $HOME/dev/scripts/live-glow.sh'
alias sd="cd ~ && cd \$(fd -t d | fzf)"
alias gtr="~/dev/go-to-repo/target/release/go-to-repo"
alias pf="fzf --preview='bat --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
alias ta="tmux attach"
alias colimatest="~/dev/scripts/colima_testcontainers.sh"
alias l="ls -laGh"
alias wd="sh $HOME/dev/scripts/work-diary.sh"
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

# create symlink for docker to $HOME in order for testcontainers find the docker environment
# ln -s $HOME/.docker/run/docker.sock /var/run/docker.sock &> /dev/null

# opencode
export PATH=/Users/balazs.harko/.opencode/bin:$PATH

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

