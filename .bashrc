# Return early for non-interactive shells (scp, rsync, etc.)
[[ $- != *i* ]] && return

# ==========================================================
# Homebrew
# ==========================================================
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ==========================================================
# Editor
# ==========================================================
export EDITOR=vim
export VISUAL="$EDITOR"

# ==========================================================
# PATH
# ==========================================================
export PATH="$HOME/.local/bin:$HOME/.grok/bin:$HOME/go/bin:$PATH"

# Antigravity IDE
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

# Rust
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# ==========================================================
# History
# ==========================================================
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:pwd:exit"

shopt -s histappend

# Save after every command (append to preserve Starship etc.)
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ==========================================================
# Colors
# ==========================================================
if command -v ggrep >/dev/null 2>&1; then
    alias grep='ggrep --color=auto'
fi

# ==========================================================
# Zoxide
# ==========================================================
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    alias cd='z'
fi

# ==========================================================
# Aliases
# ==========================================================
alias bup='brew update && brew upgrade'

if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=auto'
    alias ll='eza --long --all --git --icons=auto'
    alias la='eza --all --icons=auto'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

alias md='mkdir -p'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'

# Misc
alias serve='python3 -m http.server 8000'
alias ports='lsof -iTCP -sTCP:LISTEN -nP'
alias myip='curl https://checkip.amazonaws.com/'

# AWS
alias aws-login='aws-vault exec hasan -- bash'

# OpenCode
alias oc='opencode'

# ==========================================================
# Fast
# ==========================================================
unalias fast 2>/dev/null

if command -v fast >/dev/null 2>&1; then
    fast() {
        command fast --verbose "$@"
    }
fi

export PUPPETEER_EXECUTABLE_PATH="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

# ==========================================================
# Go
# ==========================================================
export GOPATH="$HOME/go"

# ==========================================================
# NVM
# ==========================================================
export NVM_DIR="$HOME/.nvm"

if [ -s /opt/homebrew/opt/nvm/nvm.sh ]; then
    . /opt/homebrew/opt/nvm/nvm.sh
fi

if [ -s /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm ]; then
    . /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm
fi

# ==========================================================
# fzf
# ==========================================================
if [ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]; then
    . /opt/homebrew/opt/fzf/shell/key-bindings.bash
fi

if [ -f /opt/homebrew/opt/fzf/shell/completion.bash ]; then
    . /opt/homebrew/opt/fzf/shell/completion.bash
fi

# ==========================================================
# Git Delta
# ==========================================================
if command -v delta >/dev/null 2>&1; then
    export GIT_PAGER=delta
fi

# ==========================================================
# Namaz
# ==========================================================
if [ -x "$HOME/.local/bin/namaz" ]; then
    alias namaz="$HOME/.local/bin/namaz"
fi

# ==========================================================
# Bun
# ==========================================================
[ -s "$HOME/.bun/_bun.bash" ] && source "$HOME/.bun/_bun.bash"
# ==========================================================
# Bash completion (bash-completion@2)
# Must load before tool-specific completions below
# ==========================================================
if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
fi

# Grok
if [ -f "$HOME/.grok/completions/bash/grok.bash" ]; then
    . "$HOME/.grok/completions/bash/grok.bash"
fi

# opencode
if command -v opencode >/dev/null 2>&1; then
    eval "$(opencode --completions bash 2>/dev/null)"
fi

#
## ==========================================================
## Starship (disabled)
## ==========================================================
#if command -v starship >/dev/null 2>&1; then
#    eval "$(starship init bash)"
#fi
