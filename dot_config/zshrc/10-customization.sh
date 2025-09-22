# -----------------------------------------------------
# CUSTOMIZATION
# -----------------------------------------------------

# Initialize starship
eval "$(starship init zsh)"

# -----------------------------------------------------
# ZSH AUTOCOMPLETION SETUP
# -----------------------------------------------------

# Enable zsh completion system
autoload -Uz compinit
compinit

# Enhanced completion options
setopt COMPLETE_IN_WORD    # Complete from both ends of a word
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word
setopt PATH_DIRS           # Perform path search even on command names with slashes
setopt AUTO_MENU           # Show completion menu on second tab
setopt AUTO_LIST           # List choices on ambiguous completion
setopt AUTO_PARAM_SLASH    # Add slash if completing a directory
setopt FLOW_CONTROL        # Enable flow control (Ctrl+S/Ctrl+Q)

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Install and load zsh-autosuggestions
ZSH_AUTOSUGGESTIONS_DIR="$HOME/.local/share/zsh-autosuggestions"
if [[ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi
source "$ZSH_AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh"

# Install and load zsh-syntax-highlighting
ZSH_SYNTAX_HIGHLIGHTING_DIR="$HOME/.local/share/zsh-syntax-highlighting"
if [[ ! -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
fi
source "$ZSH_SYNTAX_HIGHLIGHTING_DIR/zsh-syntax-highlighting.zsh"

# Install and load zsh-completions for additional completions
ZSH_COMPLETIONS_DIR="$HOME/.local/share/zsh-completions"
if [[ ! -d "$ZSH_COMPLETIONS_DIR" ]]; then
    echo "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_COMPLETIONS_DIR"
fi
fpath=("$ZSH_COMPLETIONS_DIR/src" $fpath)

# Modern completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# Enhanced zsh options and features
setopt AUTO_CD              # Auto cd when typing directory name
setopt AUTO_PUSHD           # Push directories to stack automatically  
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates to directory stack
setopt GLOB_DOTS            # Include dotfiles in globbing
setopt EXTENDED_GLOB        # Enable extended globbing
setopt HIST_VERIFY          # Show command with history expansion before executing
setopt SHARE_HISTORY        # Share history between sessions
setopt HIST_IGNORE_SPACE    # Ignore commands that start with space
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks from history

# zsh history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Load zsh plugins manually (replacing oh-my-zsh functionality)
# Git aliases and functions
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch -a'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gf='git fetch'
alias gl='git pull'
alias glo='git log --oneline'
alias gp='git push'
alias gr='git rebase'
alias gs='git status'
alias gst='git stash'
alias gsta='git stash apply'

# Sudo plugin functionality
alias sudo='sudo '  # Allow aliases to work with sudo

# Web search functionality  
google() { 
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "https://www.google.com/search?q=$*"
    elif command -v open >/dev/null 2>&1; then
        open "https://www.google.com/search?q=$*"
    else
        echo "No browser opener found"
    fi
}
ddg() { 
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "https://duckduckgo.com/?q=$*"
    elif command -v open >/dev/null 2>&1; then
        open "https://duckduckgo.com/?q=$*"
    else
        echo "No browser opener found"
    fi
}

# Directory navigation enhancements
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Copyfile and copybuffer functionality (replacing oh-my-zsh plugins)
if command -v xclip >/dev/null 2>&1; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
elif command -v wl-copy >/dev/null 2>&1; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
fi

# Copy file content to clipboard
copyfile() {
    if [[ -f $1 ]]; then
        if command -v pbcopy >/dev/null 2>&1; then
            cat $1 | pbcopy
            echo "File $1 copied to clipboard"
        else
            echo "No clipboard utility found"
        fi
    else
        echo "File $1 not found"
    fi
}

# Copy current command line to clipboard
copybuffer() {
    if [[ -n $BUFFER ]]; then
        if command -v pbcopy >/dev/null 2>&1; then
            echo $BUFFER | pbcopy
            echo "Command line copied to clipboard"
        else
            echo "No clipboard utility found"
        fi
    fi
}

# Bind Ctrl+O to copybuffer function
zle -N copybuffer
bindkey '^O' copybuffer
