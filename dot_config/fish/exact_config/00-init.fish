# Set PATH
set -x PATH /usr/lib/ccache/bin /snap/bin $HOME/bin $HOME/.local/bin/mini $HOME/.bun/bin $PATH

# # Set history file location
# set -x fish_history "$HOME/.local/share/fish/fish_history"

# Set history size
set -x fish_history_size 10000

# -----------------------------------------------------
# INIT
# -----------------------------------------------------

# Exporting EDITOR
# On Debian, add nvim to path
if test -f /etc/debian_version
    set -x PATH $PATH /opt/nvim-linux64/bin
end
set -x USERTERM $TERM
if test -n "$WSL_INTEROP"
    set -x USERTERM "$TERM-wsl"
end

# Install and activate mise
if test -f $HOME/.local/bin/mise
    # Activate mise
    $HOME/.local/bin/mise activate fish | source
    $HOME/.local/bin/mise completion fish | source
else
    # Install mise
    curl https://mise.run | sh
    # Activate mise
    $HOME/.local/bin/mise activate fish | source
    # Install asdf rebar plugin for mise
    "$HOME/.local/bin/mise" plugin install rebar https://github.com/Stratus3D/asdf-rebar.git
    # Run mise install
    "$HOME/.local/bin/mise" install
end

set -x EDITOR hx
set -x VISUAL hx
if status is-interactive; and not set -q TOOLBOX_NAME
    # Configure auto-attach/exit to your likings (default is off).
    # set ZELLIJ_AUTO_ATTACH true
    set ZELLIJ_AUTO_EXIT true
    eval (zellij setup --generate-auto-start fish | string collect)
end

# Initialize Starship prompt
starship init fish | source

# Aliases
alias c clear
alias cls clear
alias nf hyfetch
alias pf hyfetch
alias ff fastfetch
alias hf hyfetch
alias ls 'eza --icons'
alias la 'eza -a --icons'
alias ll 'eza -al --icons'
alias lt 'eza -a --tree --level=1 --icons'
alias shutdown 'systemctl poweroff'
alias v '$EDITOR'
alias cat bat
alias wifi nmtui
alias yay paru
