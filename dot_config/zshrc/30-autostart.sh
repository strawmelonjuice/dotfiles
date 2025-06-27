# -----------------------------------------------------
# AUTOSTART
# -----------------------------------------------------

# -----------------------------------------------------
# Starship promt
# -----------------------------------------------------
eval "$(starship init zsh)"

# -----------------------------------------------------
# Hyfetch
# -----------------------------------------------------
if [[ $(tty) == *"pts"* ]]; then
  up=$(awk '{print $1}' /proc/uptime)
  up=${up%.*}
  if [ $up -lt 300 ]; then
    hyfetch
  fi
  if [[ $(ps -o 'cmd=' -p $(ps -o 'ppid=' -p $$)) == "konsole" ]]; then
    echo "You seem to be using Konsole. Tip: use 'control+shift+m' to toggle the menu."
  fi
else
  echo
  if [ -f /bin/qtile ]; then
    echo "Start Qtile X11 with command Qtile"
  fi
  if [ -f /bin/hyprctl ]; then
    echo "Start Hyprland with command Hyprland"
  fi
fi

# -----------------------------------------------------
# Bitwarden session
# -----------------------------------------------------
# Only set up Bitwarden if the CLI is available and we're in an interactive shell
if command -v bw >/dev/null 2>&1 && [[ $- == *i* ]]; then
    # Use the helper script if available, otherwise fall back to direct bw command
    if [[ -f "$HOME//shellscripts/bitwarden_helper.sh" ]]; then
        # Load session using the helper script (handles session caching)
        if "$HOME/shellscripts/bitwarden_helper.sh" session >/dev/null 2>&1; then
            # Get the cached session if available
            if [[ -f "$HOME/.cache/bw-session" ]]; then
                export BW_SESSION=$(cat "$HOME/.cache/bw-session")
            fi
        fi
    else
        # Fallback: direct unlock (less robust)
        if bw status | grep -q '"status":"locked"' 2>/dev/null; then
            echo "Bitwarden vault is locked. Run 'bw unlock' to access secrets."
        elif bw status | grep -q '"status":"unlocked"' 2>/dev/null; then
            # Try to get existing session
            export BW_SESSION=$(bw unlock --raw 2>/dev/null || echo "")
        fi
    fi
fi