# -----------------------------------------------------
# CUSTOMIZATION
# -----------------------------------------------------

# -----------------------------------------------------
# oh-myzsh themes: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# -----------------------------------------------------
ZSH_THEME=fino-time

# -----------------------------------------------------
# oh-myzsh plugins
# -----------------------------------------------------
plugins=(
  git
  sudo
  web-search
  archlinux
  zsh-autosuggestions
  copyfile
  copybuffer
  dirhistory
)

# # If zsh-syntax-highlighting is not installed, install it with `yay -S zsh-syntax-highlighting`

# Set-up oh-my-zsh
source $ZSH/oh-my-zsh.sh

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
