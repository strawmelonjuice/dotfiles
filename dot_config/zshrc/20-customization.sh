# -----------------------------------------------------
# CUSTOMIZATION
# -----------------------------------------------------

# -----------------------------------------------------
# Set-up FZF key bindings (CTRL R for fuzzy history finder)
# -----------------------------------------------------
source <(fzf --zsh)

# zsh history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# -----------------------------------------------------
# Starship promt
# -----------------------------------------------------
eval "$(starship init zsh)"
