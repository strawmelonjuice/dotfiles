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

# // if helix is not found as hx, create a symlink to it
if [ ! -f "$HOME/.local/bin/hx" ]; then
  if [ -f "$HOME/.local/bin/helix" ]; then
    ln -s "$HOME/.local/bin/helix" "$HOME/.local/bin/hx"
  elif [ -f "/usr/local/bin/helix" ]; then
    ln -s "/usr/local/bin/helix" "$HOME/.local/bin/hx"
  elif [ -f "/usr/bin/helix" ]; then
    ln -s "/usr/bin/helix" "$HOME/.local/bin/hx"
  fi
fi

# Use Helix as the default editor
# This is an experiment for me, so I can use Helix as my main editor.
export EDITOR=hx
export VISUAL=hx

# Zellij if on any of my main terminals
# Zellij needs to start first, because otherwise we'll be going through the entire zshrc twice.
if [ "${USERTERM}" = "alacritty" ] || [ "${USERTERM}"  = "xterm-ghostty" ] || [ "${USERTERM}"  = "contour" ] || [ "${USERTERM}"  = "foot" ] || [ "${USERTERM}"  = "xterm-256color-wsl" ] || [ "${$(ps -p "$PPID" -o comm=)}" =  "cosmic-term" ] || [ "${TERM}"  = "xterm-kitty" ]; then
  # export ZELLIJ_AUTO_ATTACH=true
  export ZELLIJ_AUTO_EXIT=true
  eval "$(zellij setup --generate-auto-start zsh)"
fi

# -----------------------------------------------------
# Exports
# -----------------------------------------------------

# // Snaps in path for on Debian-based systems with older packages outside of snap
# And bun bin too.
export PATH="/usr/lib/ccache/bin/:/snap/bin/:$HOME/bin/:$HOME/.local/bin/mini/:$HOME/.bun/bin/:$PATH"
export ZSH="$HOME/.oh-my-zsh"

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
  # Install mise usage
  ~/.local/bin/mise use -g usage
  # JS runtimes
  ~/.local/bin/mise use -g node@23
  ~/.local/bin/mise use -g bun@latest
  # BEAM tools/languages
  ~/.local/bin/mise use -g erlang@latest
  ~/.local/bin/mise use -g gleam@latest
  ~/.local/bin/mise use -g elixir@latest
  ~/.local/bin/mise plugin install rebar https://github.com/Stratus3D/asdf-rebar.git
  ~/.local/bin/mise use -g rebar@latest
  # Activate mise completion
  eval "$(mise completion zsh)"
fi

# Initialize zoxide and after every CD, also run kc
eval "$(zoxide init zsh --cmd bang)"
banger() {
  bang $* && if [  -d .git ]; then
    clear
    git fetch
    kc
    eza --icons -L 2 -R
    git status
  fi
}
bangeri() {
  bangi $* && if [  -d .git  ]; then
    clear
    git fetch
    kc
    eza --icons -L 2 -R
    git status
  fi
}
alias cd=banger
alias cdi=bangeri 

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)


