# -----------------------------------------------------
# INIT
# -----------------------------------------------------

# Zellij if on Alacritty
if [ "${TERM}" != "alacritty" ] && [ "${TERM}" != "xterm-ghostty" ] && [ "${TERM}" != "foot" ] && [ "${TERM}" != "contour" ]; then
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

# bun completions
[ -s "/root/.bun/_bun" ] && source "/root/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export EDITOR=nvim
# // Snaps in path for on Debian-based systems with older packages outside of snap
export PATH="/usr/lib/ccache/bin/:/snap/bin/:$HOME/bin/:$PATH"
export ZSH="$HOME/.oh-my-zsh"

# Install and activate mise
if [ -f $HOME/.local/bin/mise ]; then
  # Activate mise
  eval "$(~/.local/bin/mise activate zsh)"
else
  # Install mise
  curl https://mise.run | sh
  # Activate mise
  eval "$(~/.local/bin/mise activate zsh)"
  # JS runtimes
  ~/.local/bin/mise use -g node@23
  ~/.local/bin/mise use -g bun@latest
  # BEAM tools/languages
  ~/.local/bin/mise use -g erlang@latest
  ~/.local/bin/mise use -g gleam@latest
  ~/.local/bin/mise use -g elixir@latest
  ~/.local/bin/mise plugin install rebar https://github.com/Stratus3D/asdf-rebar.git
  ~/.local/bin/mise use -g rebar@latest
fi

# Initialize zoxide
eval "$(zoxide init zsh --cmd cd)"
