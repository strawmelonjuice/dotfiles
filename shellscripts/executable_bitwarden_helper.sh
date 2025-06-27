#!/usr/bin/env bash

# Bitwarden Helper for Dotfiles
# This script helps manage Bitwarden CLI integration

set -euo pipefail

readonly BW_CONFIG_DIR="$HOME/.config/Bitwarden CLI"
readonly BW_SESSION_FILE="$HOME/.cache/bw-session"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() {
    echo -e "${GREEN}[BW]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[BW WARN]${NC} $*"
}

error() {
    echo -e "${RED}[BW ERROR]${NC} $*" >&2
}

# Check if Bitwarden CLI is installed
check_bw_cli() {
    if ! command -v bw >/dev/null 2>&1; then
        warn "Bitwarden CLI not found. Installing..."
        install_bw_cli
    fi
}

# Install Bitwarden CLI
install_bw_cli() {
    case "$(uname -s)" in
        Linux*|Darwin*)
            # Try Bun first (if available), then package manager, then npm fallback
            if command -v bun >/dev/null 2>&1; then
                log "Installing Bitwarden CLI via Bun..."
                bun install -g @bitwarden/cli
            elif command -v snap >/dev/null 2>&1; then
                sudo snap install bw
            elif command -v npm >/dev/null 2>&1; then
                npm install -g @bitwarden/cli
            elif [[ "$(uname -s)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
                brew install bitwarden-cli
            else
                error "Cannot install Bitwarden CLI. Please install manually."
                return 1
            fi
            ;;
        *)
            error "Unsupported operating system for automatic Bitwarden CLI installation"
            return 1
            ;;
    esac
}

# Login to Bitwarden
bw_login() {
    local email="${BW_EMAIL:-}"
    
    if [[ -z "$email" ]]; then
        read -p "Enter your Bitwarden email: " -r email
    fi
    
    if [[ -n "${BW_SERVER:-}" ]]; then
        bw config server "$BW_SERVER"
    fi
    
    log "Logging in to Bitwarden..."
    if ! bw login "$email"; then
        error "Failed to login to Bitwarden"
        return 1
    fi
}

# Unlock Bitwarden and save session
bw_unlock() {
    local session
    local password_file="$HOME/.bitwarden_password"
    
    # Try to use password file first (silent for automated operations)
    if [[ -f "$password_file" ]]; then
        if session=$(bw unlock --passwordfile "$password_file" --raw 2>/dev/null); then
            # Save session to file for reuse
            mkdir -p "$(dirname "$BW_SESSION_FILE")"
            echo "$session" > "$BW_SESSION_FILE"
            chmod 600 "$BW_SESSION_FILE"
            export BW_SESSION="$session"
            return 0
        else
            warn "Password file seems invalid, removing it"
            rm -f "$password_file"
        fi
    fi
    
    # Fall back to interactive unlock
    log "Unlocking Bitwarden vault..."
    echo -n "Enter your Bitwarden master password: "
    read -s password
    echo
    
    if session=$(bw unlock $password --raw); then
        # Password works, save it for future use
        echo "$password" > "$password_file"
        chmod 600 "$password_file"
        log "Password saved for future automatic unlocking"
        
        # Save session to file for reuse
        mkdir -p "$(dirname "$BW_SESSION_FILE")"
        echo "$session" > "$BW_SESSION_FILE"
        chmod 600 "$BW_SESSION_FILE"
        export BW_SESSION="$session"
        log "Bitwarden vault unlocked successfully"
        return 0
    else
        error "Failed to unlock Bitwarden vault - incorrect password"
        return 1
    fi
}

# Setup password file for automatic unlocking
bw_setup_password_file() {
    local password_file="$HOME/.bitwarden_password"
    
    if [[ -f "$password_file" ]]; then
        echo -n "Password file already exists. Replace it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "Password file setup cancelled"
            return 0
        fi
    fi
    
    echo -n "Enter your Bitwarden master password: "
    read -s password
    echo
    
    # Test the password
    if session=$(echo "$password" | bw unlock --raw 2>/dev/null); then
        echo "$password" > "$password_file"
        chmod 600 "$password_file"
        
        # Save session for current shell and future use
        mkdir -p "$(dirname "$BW_SESSION_FILE")"
        echo "$session" > "$BW_SESSION_FILE"
        chmod 600 "$BW_SESSION_FILE"
        export BW_SESSION="$session"
        
        log "Password file created successfully at $password_file"
        log "Future operations will use this password automatically"
        log "Session is now active in current shell"
    else
        error "Invalid password. Password file not created."
        return 1
    fi
}

# Load existing session
bw_load_session() {
    if [[ -f "$BW_SESSION_FILE" ]]; then
        local session_token
        session_token="$(cat "$BW_SESSION_FILE")"
        
        # Test if session is still valid using the session token
        if BW_SESSION="$session_token" bw list items --length 1 >/dev/null 2>&1; then
            export BW_SESSION="$session_token"
            return 0
        else
            # Session expired, remove the file silently
            rm -f "$BW_SESSION_FILE"
        fi
    fi
    return 1
}

# Get a secret from Bitwarden
bw_get_secret() {
    local item_name="$1"
    local field="${2:-password}"
    
    if ! bw_ensure_session; then
        error "Cannot access Bitwarden vault"
        return 1
    fi
    
    local item_id
    if item_id=$(bw list items --search "$item_name" | jq -r '.[0].id // empty' 2>/dev/null); then
        if [[ -n "$item_id" ]]; then
            bw get "$field" "$item_id" 2>/dev/null || {
                error "Failed to get $field for $item_name"
                return 1
            }
        else
            error "Item '$item_name' not found in Bitwarden vault"
            return 1
        fi
    else
        error "Failed to search for item '$item_name'"
        return 1
    fi
}

# Ensure we have a valid Bitwarden session
bw_ensure_session() {
    # Try to load existing session first
    if bw_load_session; then
        return 0
    fi
    
    # Check if we're logged in
    if ! bw status | grep -q '"status":"unlocked"' 2>/dev/null; then
        # Try to unlock if logged in but locked
        if bw status | grep -q '"status":"locked"' 2>/dev/null; then
            bw_unlock
        else
            # Need to login first
            bw_login && bw_unlock
        fi
    else
        # Already unlocked, just set the session
        bw_load_session || bw_unlock
    fi
}

# Template helper: get secret for use in chezmoi templates
bw_template_helper() {
    local item_name="$1"
    local field="${2:-password}"
    
    # This is designed to be called from chezmoi templates
    # It should fail gracefully if Bitwarden is not available
    if ! command -v bw >/dev/null 2>&1; then
        echo "BW_NOT_AVAILABLE"
        return 0
    fi
    
    if ! bw_get_secret "$item_name" "$field" 2>/dev/null; then
        echo "BW_SECRET_NOT_FOUND"
        return 0
    fi
}

# Main function
main() {
    local action="${1:-help}"
    
    case "$action" in
        install)
            install_bw_cli
            ;;
        login)
            check_bw_cli
            bw_login
            ;;
        unlock)
            check_bw_cli
            bw_unlock
            ;;
        setup-password)
            check_bw_cli
            bw_setup_password_file
            ;;
        get)
            shift
            check_bw_cli
            bw_get_secret "$@"
            ;;
        template)
            shift
            bw_template_helper "$@"
            ;;
        session)
            check_bw_cli
            bw_ensure_session
            ;;
        status)
            if command -v bw >/dev/null 2>&1; then
                bw status
            else
                echo "Bitwarden CLI not installed"
            fi
            ;;
        help|*)
            cat << EOF
Bitwarden Helper for Dotfiles

Usage: $0 <command> [arguments]

Commands:
    install     Install Bitwarden CLI
    login       Login to Bitwarden
    unlock      Unlock Bitwarden vault
    setup-password  Set up automatic password file for unlocking
    get <item> [field]  Get a secret from Bitwarden
    template <item> [field]  Get secret for use in templates (safe)
    session     Ensure valid session exists
    status      Show Bitwarden status
    help        Show this help

Environment Variables:
    BW_EMAIL    Your Bitwarden email
    BW_SERVER   Custom Bitwarden server URL
    BW_SESSION  Current session token (set automatically)

Password File:
    The script can use ~/.bitwarden_password for automatic unlocking.
    Use 'setup-password' command to create this file securely.

Examples:
    $0 install
    $0 login
    $0 setup-password
    $0 get "GitHub Token"
    $0 get "SSH Key" "private_key"
    $0 template "API Key" "password"
EOF
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    main "$@"
fi
