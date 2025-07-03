# -----------------------------------------------------
# Aliases
# -----------------------------------------------------

# General aliases
alias c 'clear'
alias cls 'clear'
alias nf 'hyfetch'
alias pf 'hyfetch'
alias ff 'fastfetch'
alias hf 'hyfetch'
alias ls 'eza --icons'
alias la 'eza -a --icons'
alias ll 'eza -al --icons'
alias lt 'eza -a --tree --level=1 --icons'
alias shutdown 'systemctl poweroff'
alias v '$EDITOR'
alias cat 'bat'
alias wifi 'nmtui'
alias yay 'paru'

# Update grub alias
alias update-grub 'sudo grub-mkconfig -o /boot/grub/grub.cfg'

# Zellij and cargo aliases
alias ide 'zellij --layout ide'
alias strider 'zellij plugin --in-place -- zellij:strider'
alias cargock 'cargo-clean-all --keep-days 21 ~ -i'

# -----------------------------------------------------
# Directory navigation and aliases
# -----------------------------------------------------

# Corrected zoxide initialization
zoxide init fish --cmd bang | source

function zap
    if test -d .git -a -d .jj
        clear
        echo "Opened Git-colocated Jujutsu repository: $(pwd)"
        git fetch
        kc
        jj status
        eza --icons -L 2 -R --tree --git-ignore
    else if test -d .jj
        clear
        echo "Opened Jujutsu repository: $(pwd)"
        jj status
        eza --icons -L 2 -R --tree
    else if test -d .git
        clear
        echo "Opened git repository: $(pwd)"
        git fetch
        kc
        eza --icons -L 2 -R --tree --git-ignore
        git status
    end
    if test -f mise.toml
        mise completion fish | source
    end
end

function banger
    bang $argv; and zap
end

function bangeri
    bangi $argv; and zap
end

alias cd 'banger'
alias cdi 'bangeri'
