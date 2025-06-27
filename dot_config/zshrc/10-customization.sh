# -----------------------------------------------------
# CUSTOMIZATION
# -----------------------------------------------------

# Install and initialize Oh My Posh
if command -v oh-my-posh >/dev/null 2>&1; then
    # Oh My Posh is installed, use starship instead of a posh theme
    eval "$(starship init zsh)"
else
    # Install Oh My Posh if not present
    echo "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
    # Add to PATH if not already there
    export PATH=$PATH:$HOME/.local/bin
    # Initialize starship
    eval "$(starship init zsh)"
fi

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

# Enhanced autocompletion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colored completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

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
google() { open "https://www.google.com/search?q=$*" }
ddg() { open "https://duckduckgo.com/?q=$*" }

# Directory navigation enhancements
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Load zsh plugins (replacing oh-my-zsh plugins)
# zsh-autosuggestions
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# zsh-syntax-highlighting (should be loaded last)
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

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
