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
export PATH="/usr/lib/ccache/bin/:/snap/bin/:$PATH"
export ZSH="$HOME/.oh-my-zsh"

# Initialize nvm
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
fi

# Initialize asdf
if [ -f $HOME/.asdf/asdf.sh ]; then
  . "$HOME/.asdf/asdf.sh"
else
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
  . "$HOME/.asdf/asdf.sh"
fi

# Initialize rebar3
export PATH=/home/mar/.cache/rebar3/bin:$PATH

# Initialize zoxide
eval "$(zoxide init zsh --cmd cd)"
