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
alias ls='eza --icons'
alias la='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'
alias shutdown='systemctl poweroff'
alias v='$EDITOR'
alias cat='bat'
alias ts='~/.config/hypr/scripts/snapshot.sh'
alias wifi='nmtui'
alias cleanup='~/.config/hypr/scripts/cleanup.sh'
# // if helix is not found as hx, create hx alias
if ! command -v hx &>/dev/null; then
  alias hx='helix'
fi

alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# I get Vim muscle memory in the terminal...
alias qa='echo "Yes, you can use :q or :qa to exit."'
alias q='echo "Yes, you can use :q or :qa to exit."'
alias :qa='exit'
alias :q='exit'
# I'm lazy and don't want to type the full command
alias ide='zellij --layout ide'
# Cleans up the cargo caches interactively. -- This name? Haha.
alias cargock='cargo clean-all --keep-days 21 ~ -i'
