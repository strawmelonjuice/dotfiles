# -----------------------------------------------------
# ALIASES
# -----------------------------------------------------

# -----------------------------------------------------
# General
# -----------------------------------------------------
alias c='clear'
alias cls='clear'
alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'
alias ls='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'
alias shutdown='systemctl poweroff'
alias v='$EDITOR'
alias cat='bat'
# alias vim='$EDITOR'
alias ts='~/.config/hypr/scripts/snapshot.sh'
alias wifi='nmtui'
alias cleanup='~/.config/hypr/scripts/cleanup.sh'
alias ide='zellij --layout ide'

# -----------------------------------------------------
# Window Managers
# -----------------------------------------------------

alias Qtile='startx'
# Hyprland with Hyprland

# -----------------------------------------------------
# Git
# -----------------------------------------------------
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gst="git stash"
alias gsp="git stash; git pull"
alias gcheck="git checkout"
alias gcredential="git config credential.helper store"

# -----------------------------------------------------
# Scripts
# -----------------------------------------------------
alias ascii='~/.config/hypr/scripts/figlet.sh'

# -----------------------------------------------------
# System
# -----------------------------------------------------
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# -----------------------------------------------------
# Qtile
# -----------------------------------------------------
alias res1='xrandr --output DisplayPort-0 --mode 2560x1440 --rate 120'
alias res2='xrandr --output DisplayPort-0 --mode 1920x1080 --rate 120'
alias setkb='setxkbmap de;echo "Keyboard set back to de."'

# -----------------------------------------------------
# Custom
# -----------------------------------------------------
# I get Vim muscle memory in the terminal...
alias qa='exit'
alias q='exit'
alias :qa='exit'
alias :q='exit'
