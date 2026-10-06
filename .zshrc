
# ══════════════════════════════════════════════════════════
#  ~/.zshrc
#  Optional deps:
#    brew install zsh-autosuggestions zsh-syntax-highlighting \
#      zsh-history-substring-search fzf fd ripgrep bat eza zoxide \
#      starship git-delta vivid
# ══════════════════════════════════════════════════════════

# Uncomment to profile startup, then run `exec zsh`
# zmodload zsh/zprof

# ─── Homebrew ─────────────────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ─── Environment ──────────────────────────────────────────
export LANG=en_US.UTF-8
export EDITOR=vim
export VISUAL="$EDITOR"
export PAGER=less
export LESS='-R -F -X -i -M --mouse'
export CLICOLOR=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"

# ─── PATH ─────────────────────────────────────────────────
typeset -U path PATH fpath   # keep entries unique

path=(
  "$HOME/.local/bin"
  "$HOME/.grok/bin"
  "$GOPATH/bin"
  "$BUN_INSTALL/bin"
  "/opt/homebrew/opt/rustup/bin"
  "$HOME/.cargo/bin"
  "$HOME/.antigravity-ide/antigravity-ide/bin"
  $path
)
# Drop entries that don't exist
path=($^path(N-/))

# ─── Shell options ────────────────────────────────────────
setopt AUTO_CD              # type a dir name to cd into it
setopt AUTO_PUSHD           # cd pushes onto dir stack (use `dirs -v`, `cd -3`)
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS # allow # comments in the prompt
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt NO_FLOW_CONTROL      # free up Ctrl-S / Ctrl-Q
setopt LONG_LIST_JOBS

# ─── History ──────────────────────────────────────────────
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"

setopt EXTENDED_HISTORY       # store timestamps + duration
setopt SHARE_HISTORY          # share across sessions (implies incremental append)
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE      # prefix a command with a space to keep it out of history
setopt HIST_VERIFY            # show !! expansions before running
setopt HIST_SAVE_NO_DUPS

# ─── Colors for completion ────────────────────────────────
if [[ -z "$LS_COLORS" ]] && command -v vivid >/dev/null 2>&1; then
  export LS_COLORS="$(vivid generate catppuccin-mocha 2>/dev/null)"
fi

# ─── Completion ───────────────────────────────────────────
[[ -d "$HOME/.grok/completions/zsh" ]] && fpath=("$HOME/.grok/completions/zsh" $fpath)

zmodload zsh/complist
autoload -Uz compinit

# Rebuild the completion dump at most once a day; otherwise trust the cache
_zcache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $_zcache ]] || mkdir -p "$_zcache"
if [[ -n $_zcache/zcompdump(#qN.mh+24) ]]; then
  compinit -d "$_zcache/zcompdump"
else
  compinit -C -d "$_zcache/zcompdump"
fi
unset _zcache

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{red}no matches%f'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ─── Key bindings ─────────────────────────────────────────
bindkey -e
bindkey '^[[1;5C' forward-word       # Ctrl+→
bindkey '^[[1;5D' backward-word      # Ctrl+←
bindkey '^[[1;3C' forward-word       # Alt+→
bindkey '^[[1;3D' backward-word      # Alt+←
bindkey '^[[H'    beginning-of-line  # Home
bindkey '^[[F'    end-of-line        # End
bindkey '^[[3~'   delete-char        # Delete
bindkey '^[[Z'    reverse-menu-complete  # Shift+Tab

# Edit the current command in $EDITOR with Ctrl-X Ctrl-E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ─── fzf ──────────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1; then
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --info=inline'
  command -v bat >/dev/null 2>&1 && \
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  command -v eza >/dev/null 2>&1 && \
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"

  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)                       # fzf >= 0.48
  else
    [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]   && source /opt/homebrew/opt/fzf/shell/completion.zsh
  fi
fi

# ─── zoxide (replaces cd with smart jumping) ──────────────
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# ─── Node (nvm, lazy-loaded) ──────────────────────────────
# Sourcing nvm.sh costs ~300ms per shell, so load it on first use instead.
export NVM_DIR="$HOME/.nvm"
_nvm_load() {
  unset -f nvm node npm npx pnpm yarn corepack 2>/dev/null
  [[ -s /opt/homebrew/opt/nvm/nvm.sh ]] && source /opt/homebrew/opt/nvm/nvm.sh
  [[ -s /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm ]] && source /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm
}
for _cmd in nvm node npm npx pnpm yarn corepack; do
  eval "$_cmd() { _nvm_load; $_cmd \"\$@\" }"
done
unset _cmd
# Make globally installed CLIs available immediately (newest installed Node)
_node_bin=($NVM_DIR/versions/node/*/bin(N-/om[1]))
[[ -d ${_node_bin[1]} ]] && path=("${_node_bin[1]}" $path)
unset _node_bin

# ─── Git delta ────────────────────────────────────────────
command -v delta >/dev/null 2>&1 && export GIT_PAGER=delta

# ─── Fast (speed test) ────────────────────────────────────
if (( $+commands[fast] )); then
  fast() { command fast --verbose "$@" }
fi
# Use Brave for tools that rely on Puppeteer
_brave="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
[[ -x $_brave ]] && export PUPPETEER_EXECUTABLE_PATH="$_brave"
unset _brave

# ─── Aliases: navigation & listing ────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias md='mkdir -p'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias la='eza --all --icons=auto --group-directories-first'
  alias ll='eza --long --all --git --icons=auto --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto'
  alias lta='eza --tree --level=2 --all --icons=auto --ignore-glob=".git"'
fi

# `cat` stays real cat for scripts; use `bat` / `cat` interactively
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# macOS BSD grep has no --color=auto issues, but GNU grep is nicer
if command -v ggrep >/dev/null 2>&1; then
  alias grep='ggrep --color=auto'
else
  alias grep='grep --color=auto'
fi

alias rg='rg --smart-case'
alias df='df -h'
alias du='du -h'
alias path='print -l $path'

# ─── Aliases: git ─────────────────────────────────────────
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autostash'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gsw='git switch'
alias gswc='git switch -c'
alias gb='git branch'
alias gst='git stash'
alias gstp='git stash pop'

# ─── Aliases: Go ──────────────────────────────────────────
alias gor='go run .'
alias gob='go build ./...'
alias got='go test ./...'
alias gotv='go test -v -race ./...'
alias gom='go mod tidy'

# ─── Aliases: Docker ──────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail=100'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# ─── Aliases: misc ────────────────────────────────────────
alias bup='brew update && brew upgrade && brew cleanup'
alias reload='exec zsh'
alias ports='lsof -iTCP -sTCP:LISTEN -nP'
alias myip='curl -s https://checkip.amazonaws.com'
alias copy='pbcopy'
alias paste='pbpaste'
alias oc='opencode'
alias aws-login='aws-vault exec hasan -- zsh'

# ─── Functions ────────────────────────────────────────────
# mkdir + cd
mkcd() { mkdir -p -- "$1" && cd -- "$1" }

# Serve current dir: `serve` or `serve 3000`
serve() { python3 -m http.server "${1:-8000}" }

# Kill whatever is listening on a port: `killport 8080`
killport() {
  local pids
  pids=$(lsof -tiTCP:"$1" -sTCP:LISTEN) || true
  if [[ -z $pids ]]; then
    echo "nothing listening on :$1"
  else
    echo "$pids" | xargs kill -9 && echo "killed $pids on :$1"
  fi
}

# Extract almost any archive
extract() {
  [[ -f $1 ]] || { echo "extract: '$1' is not a file"; return 1 }
  case $1 in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf  "$1" ;;
    *.zip)            unzip "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.7z)             7z x "$1" ;;
    *)                echo "extract: unknown format '$1'"; return 1 ;;
  esac
}

# Delete local branches already merged into main/master
gbclean() {
  local base
  base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')
  base=${base:-main}
  git branch --merged "$base" | grep -vE "^\*|^\s*($base|master|develop)$" | xargs -r git branch -d
}

# Fuzzy-checkout a branch
gbf() {
  local b
  b=$(git branch --all --sort=-committerdate | sed 's|remotes/origin/||; s|^[ *]*||' | awk '!seen[$0]++' | fzf --height=40%) \
    && git switch "$b"
}

# Fuzzy-find a file and open it in $EDITOR
ff() {
  local f
  f=$(fzf --preview 'bat --color=always --line-range=:200 {}') && ${EDITOR} "$f"
}

# Measure interactive shell startup time
ztime() { for _ in 1 2 3; do /usr/bin/time zsh -i -c exit; done }

# ─── Prompt ───────────────────────────────────────────────
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ─── bun completions ──────────────────────────────────────
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# ─── Plugins (must be last; syntax-highlighting very last) ─
_zp="${HOMEBREW_PREFIX:-/opt/homebrew}/share"

if [[ -f $_zp/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source $_zp/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
  bindkey '^ ' autosuggest-accept   # Ctrl+Space accepts the suggestion
fi

if [[ -f $_zp/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  source $_zp/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
fi

[[ -f $_zp/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source $_zp/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unset _zp

# zprof   # uncomment together with zmodload line at the top
