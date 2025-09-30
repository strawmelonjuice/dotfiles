# -----------------------------------------------------
# INIT
# -----------------------------------------------------

# Initialise compdef
autoload -Uz compinit && compinit

# ---------------------
# Exporting EDITOR
# ---------------------
# On debian, add nvim to path
if [ -f /etc/debian_version ]; then
  export PATH="$PATH:/opt/nvim-linux64/bin"
fi
export USERTERM="$TERM"
if [ "$WSL_INTEROP" != "" ]; then
  export USERTERM="$TERM-wsl"
fi

# Install and activate mise
if [ -f $HOME/.local/bin/mise ]; then
  # Activate mise
  eval "$(~/.local/bin/mise activate zsh)"
  eval "$(mise completion zsh)"
else
  # Install mise
  curl https://mise.run | sh
  # Activate mise
  eval "$(~/.local/bin/mise activate zsh)"
  # Install asdf rebar plugin for mise
  ~/.local/bin/mise plugin install rebar https://github.com/Stratus3D/asdf-rebar.git
  # Run mise install
  ~/.local/bin/mise install
fi

export EDITOR=nvim
export VISUAL=nvim

# Zellij if on any of my main terminals
# Zellij needs to start first, because otherwise we'll be going through the entire zshrc twice.
# if [ "${USERTERM}" = "alacritty" ] || [ "${USERTERM}"  = "xterm-ghostty" ] || [ "${USERTERM}"  = "contour" ] || [ "${USERTERM}"  = "foot" ] || [ "${USERTERM}"  = "xterm-ghostty-wsl" ] || [ "${USERTERM}"  = "xterm-256color-wsl" ] || [ "${$(ps -p "$PPID" -o comm=)}" =  "cosmic-term" ] || [ "${TERM}"  = "xterm-kitty" ]; then
#   # export ZELLIJ_AUTO_ATTACH=true
#   export ZELLIJ_AUTO_EXIT=true
#   eval "$(zellij setup --generate-auto-start zsh)"
# fi

# -----------------------------------------------------
# Exports
# -----------------------------------------------------

# // Snaps in path for on Debian-based systems with older packages outside of snap
# And bun bin too.
export PATH="/usr/lib/ccache/bin/:/snap/bin/:$HOME/bin/:$HOME/.local/bin/mini/:$HOME/.bun/bin/:$PATH"

eval "$(ssh-agent -s)"

# Initialize zoxide and after every CD, also run kc if its a git repo.
eval "$(zoxide init zsh --cmd bang)"

zap() {

  if [ -d .git ] && [ -d .jj ]; then
    clear
    echo "Opened Git-colocated Jujutsu repository: $(pwd)"
    git fetch
    kc
    jj status
    eza --icons -L 2 -R --tree --git-ignore
  elif [ -d .jj ]; then
    clear
    echo "Opened Jujutsu repository: $(pwd)"
    jj status
    eza --icons -L 2 -R --tree
  elif [ -d .git ]; then
    clear
    echo "Opened git repository: $(pwd)"
    git fetch
    kc
    eza --icons -L 2 -R --tree --git-ignore
    git status
  else
    eza -a --icons
  fi
  if [ -f mise.toml ]; then
    eval "$(mise completion zsh)"
  fi
}

banger() {
  bang $* && zap
}
bangeri() {
  bangi $* && zap
}
alias cd=banger
alias cdi=bangeri

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)
