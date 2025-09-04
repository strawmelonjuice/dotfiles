#!/bin/env bash
eval "$(~/.local/bin/mise activate bash --shims)"
if ! command -v hx &>/dev/null; then
  alias hx='helix'
  if [[ "$EDITOR"=="hx" ]]; then
    EDITOR='helix'
  fi
fi
$EDITOR . && zellij action close-tab
