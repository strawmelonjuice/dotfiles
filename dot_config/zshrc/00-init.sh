# -----------------------------------------------------
# INIT
# -----------------------------------------------------

# Initialise compdef
autoload -Uz compinit && compinit

# Zellij if on any of my main terminals
# Zellij needs to start first, because otherwise we'll be going through the entire zshrc twice.
if [ "${TERM}" != "alacritty" ] && [ "${TERM}" != "xterm-ghostty" ] && [ "${TERM}" != "contour" ] && [ "${TERM}" != "foot" ] && [ "$(ps -p "$PPID" -o command=)" != "cosmic-term" ]; then
  # no need to state this for kitty, as it is the default terminal but does not need to autostart Zellij.
  if [ "${TERM}" != "xterm-kitty" ]; then
    echo "Not autostarting Zellij as terminal is different from usual."
  fi
else
  # export ZELLIJ_AUTO_ATTACH=true
  export ZELLIJ_AUTO_EXIT=true
  eval "$(zellij setup --generate-auto-start zsh)"
fi

# -----------------------------------------------------
# Exports
# -----------------------------------------------------
# On debian, add nvim to path
if [ -f /etc/debian_version ]; then
  export PATH="$PATH:/opt/nvim-linux64/bin"
fi

export EDITOR=nvim
# // Snaps in path for on Debian-based systems with older packages outside of snap
export PATH="/usr/lib/ccache/bin/:/snap/bin/:$HOME/bin/:$PATH"
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

# Initialize zoxide
eval "$(zoxide init zsh --cmd cd)"
