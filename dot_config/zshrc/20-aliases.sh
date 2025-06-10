# -----------------------------------------------------
# ALIASES
# -----------------------------------------------------

# -----------------------------------------------------
# General
# -----------------------------------------------------
alias c='clear'
alias cls='clear'
alias nf='hyfetch'
alias pf='hyfetch'
alias ff='fastfetch'
alias hf='hyfetch'
alias ls='eza --icons'
alias la='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'
alias shutdown='systemctl poweroff'
alias v='$EDITOR'
alias cat='bat'
alias wifi='nmtui'
alias yay='paru'


alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# I get Vim muscle memory in the terminal...
alias qa='echo "Yes, you can use :qa to exit the entire session."'
alias q='echo "Yes, you can use :q to exit the current tab."'
alias :qa='zellij kill-session $ZELLIJ_SESSION_NAME'
alias :q='zellij action close-tab'
# I'm lazy and don't want to type the full command
alias ide='zellij --layout ide'
alias strider='zellij plugin --in-place -- zellij:strider'
# Cleans up the cargo caches interactively. -- This name? Haha.
alias cargock='cargo-clean-all --keep-days 21 ~ -i'
