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
    BW_PASSWORD_FILE="$HOME/.bitwarden_password"
    BW_SESSION_FILE="$HOME/.cache/bw-session"
    
    # Function to unlock Bitwarden with password file
    bw_unlock_with_password_file() {
        if [[ -f "$BW_PASSWORD_FILE" ]]; then
            # Use existing password file
            export BW_SESSION=$(bw unlock --passwordfile "$BW_PASSWORD_FILE" --raw 2>/dev/null)
            if [[ -n "$BW_SESSION" ]]; then
                # Save session for reuse
                mkdir -p "$(dirname "$BW_SESSION_FILE")"
                echo "$BW_SESSION" > "$BW_SESSION_FILE"
                chmod 600 "$BW_SESSION_FILE"
                return 0
            else
                # Password file might be invalid, remove it
                rm -f "$BW_PASSWORD_FILE"
                return 1
            fi
        else
            # Ask user if they want to set up password file
            echo -n "Bitwarden password file not found. Set up automatic unlock? (y/N): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                echo -n "Enter your Bitwarden master password: "
                read -s password
                echo
                
                # Test the password before saving
                if BW_SESSION=$(echo "$password" | bw unlock --raw 2>/dev/null); then
                    # Password works, save it securely
                    echo "$password" > "$BW_PASSWORD_FILE"
                    chmod 600 "$BW_PASSWORD_FILE"
                    
                    # Save session
                    mkdir -p "$(dirname "$BW_SESSION_FILE")"
                    echo "$BW_SESSION" > "$BW_SESSION_FILE"
                    chmod 600 "$BW_SESSION_FILE"
                    
                    # Sync Bitwarden to ensure items are available
                    bw sync --session "$BW_SESSION" >/dev/null 2>&1

                    # Export session variable
                    export BW_SESSION
                    echo "Password saved securely. Future shell sessions will unlock automatically."
                    return 0
                else
                    echo "Invalid password. Bitwarden will remain locked."
                    return 1
                fi
            else
                echo "Skipping Bitwarden setup. You can set it up later with:"
                echo "  ~/shellscripts/bitwarden_helper.sh setup-password"
                return 1
            fi
        fi
    }
    
    # Check Bitwarden status and handle accordingly
    if [[ -f "$BW_SESSION_FILE" ]]; then
        # Try to use existing session
        export BW_SESSION=$(cat "$BW_SESSION_FILE")
        if ! bw status --session "$BW_SESSION" | grep -q '"status":"unlocked"' 2>/dev/null; then
            # Session expired, remove it and try to unlock
            rm -f "$BW_SESSION_FILE"
            unset BW_SESSION
        fi
    fi
    
    # If no valid session, try to unlock
    if [[ -z "${BW_SESSION:-}" ]]; then
        bw_status=$(bw status 2>/dev/null || echo '{"status":"unauthenticated"}')
        if echo "$bw_status" | grep -q '"status":"locked"' 2>/dev/null; then
            bw_unlock_with_password_file
        elif echo "$bw_status" | grep -q '"status":"unauthenticated"' 2>/dev/null; then
            echo "Bitwarden not logged in. Run 'bw login' first."
        fi
    fi
fi