#!/usr/bin/env bash

# Dotfiles Bootstrap Script
# This is the main entry point for setting up the dotfiles environment
# It can be run directly from a fresh system or downloaded via curl

set -euo pipefail

# Constants
readonly DOTFILES_REPO="https://github.com/strawmelonjuice/dotfiles.git"  # Update this to your actual repo!
readonly CHEZMOI_SOURCE_DIR="$HOME/.local/share/chezmoi"
readonly SCRIPT_URL="https://raw.githubusercontent.com/strawmelonjuice/dotfiles/main/bootstrap.sh"

# Colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() {
    echo -e "${GREEN}[BOOTSTRAP]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    exit 1
}

# Check if we're running in a supported environment
check_prerequisites() {
    # Check for required commands
    for cmd in curl git; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error "Required command '$cmd' not found. Please install it first."
        fi
    done
    
    # Check for bash version (need 4.0+ for associative arrays)
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        error "Bash 4.0 or higher is required. Current version: $BASH_VERSION"
    fi
}

# Install chezmoi if not present
install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        log "chezmoi is already installed"
        return 0
    fi
    
    log "Installing chezmoi..."
    
    # Create local bin directory
    mkdir -p "$HOME/.local/bin"
    
    # Install chezmoi
    if ! sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"; then
        error "Failed to install chezmoi"
    fi
    
    # Add to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    
    log "chezmoi installed successfully"
}

# Initialize chezmoi with dotfiles
init_dotfiles() {
    log "Initializing dotfiles with chezmoi..."
    
    # If chezmoi source directory doesn't exist, initialize it
    if [[ ! -d "$CHEZMOI_SOURCE_DIR" ]]; then
        log "Cloning dotfiles repository..."
        chezmoi init --apply "$DOTFILES_REPO"
    else
        log "Dotfiles already initialized, updating..."
        chezmoi update
    fi
}

# Run the smart installation script
run_installation() {
    local install_script="$CHEZMOI_SOURCE_DIR/shellscripts/executable_smart_install.sh"
    
    if [[ -f "$install_script" ]]; then
        log "Running smart installation script..."
        bash "$install_script" "$@"
    else
        log "Smart install script not found, running basic setup..."
        # Fallback to basic setup
        chezmoi apply
    fi
}

# Main bootstrap function
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🚀 Dotfiles Bootstrap 🚀                             ║
║                                                                              ║
║  This script will set up your development environment from scratch          ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log "Starting dotfiles bootstrap process..."
    
    # Run setup steps
    check_prerequisites
    install_chezmoi
    init_dotfiles
    run_installation "$@"
    
    echo
    log "🎉 Bootstrap completed successfully!"
    log "You may need to restart your shell or run 'exec \$SHELL' to reload your configuration."
    
    # Show next steps
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Restart your shell: exec \$SHELL"
    echo "  3. Run the smart install script: bash $HOME/.local/share/chezmoi/shellscripts/executable_smart_install.sh"
    echo "  3. Check your configuration: chezmoi doctor"
    echo "  4. Update dotfiles anytime: chezmoi update"
    echo
}

# Allow the script to be sourced for testing
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    main "$@"
fi
