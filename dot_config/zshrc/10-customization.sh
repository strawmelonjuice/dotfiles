# -----------------------------------------------------
# CUSTOMIZATION
# -----------------------------------------------------

# oh-myzsh
ZSH_THEME=fino-time
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
source $ZSH/oh-my-zsh.sh

# zsh history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
