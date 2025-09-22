# -----------------------------------------------------
# Bitwarden Shell Functions
# -----------------------------------------------------

# Convenient wrapper functions for Bitwarden CLI
if command -v bw >/dev/null 2>&1; then
    # Path to the bitwarden helper script
    BW_HELPER="$HOME/shellscripts/bitwarden_helper.sh"
    
    # Quick Bitwarden functions
    bw-get() {
        if [[ -f "$BW_HELPER" ]]; then
            "$BW_HELPER" get "$@"
        else
            echo "Bitwarden helper script not found. Using direct bw command."
            bw get item "$1" 2>/dev/null | jq -r '.login.password // .notes // "Not found"'
        fi
    }
    
    bw-login() {
        if [[ -f "$BW_HELPER" ]]; then
            "$BW_HELPER" login
        else
            bw login
        fi
    }
    
    bw-unlock() {
        if [[ -f "$BW_HELPER" ]]; then
            "$BW_HELPER" unlock
        else
            export BW_SESSION=$(bw unlock --raw)
        fi
    }
    
    bw-status() {
        if [[ -f "$BW_HELPER" ]]; then
            "$BW_HELPER" status
        else
            bw status
        fi
    }
    
    # Copy secret to clipboard (requires xclip/pbcopy)
    bw-copy() {
        local secret=$(bw-get "$1")
        if [[ "$secret" != "Not found" && "$secret" != "BW_NOT_AVAILABLE" ]]; then
            if command -v xclip >/dev/null 2>&1; then
                echo "$secret" | xclip -selection clipboard
                echo "Secret copied to clipboard"
            elif command -v pbcopy >/dev/null 2>&1; then
                echo "$secret" | pbcopy
                echo "Secret copied to clipboard"
            else
                echo "Clipboard utility not available. Secret: $secret"
            fi
        else
            echo "Secret not found: $1"
        fi
    }
    
    # Generate and copy a random password
    bw-generate() {
        local length=${1:-20}
        if command -v bw >/dev/null 2>&1; then
            local password=$(bw generate --length "$length")
            if command -v xclip >/dev/null 2>&1; then
                echo "$password" | xclip -selection clipboard
                echo "Generated password copied to clipboard"
            elif command -v pbcopy >/dev/null 2>&1; then
                echo "$password" | pbcopy
                echo "Generated password copied to clipboard"
            else
                echo "Generated password: $password"
            fi
        fi
    }
fi
