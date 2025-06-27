#!/usr/bin/env bash

set -euo pipefail

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Script metadata
readonly SCRIPT_NAME="$(basename "${0:-smart_install.sh}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Environment detection
detect_environment() {
    local env="unknown"
    
    # Check for GitHub Codespaces
    if [[ -n "${CODESPACES:-}" ]]; then
        env="codespace"
    # Check for other cloud environments
    elif [[ -n "${GITPOD_WORKSPACE_ID:-}" ]]; then
        env="gitpod"
    elif [[ -n "${REPLIT_DB_URL:-}" ]]; then
        env="replit"
    # Check for CI environments
    elif [[ -n "${CI:-}" ]]; then
        env="ci"
    # Check for containers
    elif [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        env="container"
    # Default to local
    else
        env="local"
    fi
    
    echo "$env"
}

# Distribution detection (enhanced from your existing code)
detect_distribution() {
    local distribution
    distribution="$(grep "ID_LIKE" /etc/os-release 2>/dev/null | cut -d "=" -f 2 | tr -d '"' || true)"
    
    if [[ -z "$distribution" ]]; then
        distribution="$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d '=' -f 2 | tr -d '"' || true)"
    fi
    
    # Normalize common variants
    case "$distribution" in
        *debian*) echo "debian" ;;
        *ubuntu*) echo "debian" ;;
        *fedora*) echo "fedora" ;;
        *rhel*) echo "fedora" ;;
        *arch*) echo "arch" ;;
        *alpine*) echo "alpine" ;;
        *) echo "$distribution" ;;
    esac
}

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        ERROR)   echo -e "${RED}[ERROR]${NC} $message" >&2 ;;
        WARN)    echo -e "${YELLOW}[WARN]${NC} $message" ;;
        INFO)    echo -e "${GREEN}[INFO]${NC} $message" ;;
        DEBUG)   [[ "${DEBUG:-0}" == "1" ]] && echo -e "${BLUE}[DEBUG]${NC} $message" ;;
        *)       echo "$message" ;;
    esac
}

# Print a fancy banner
print_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                           🏠 Dotfiles Installer 🏠                          ║
║                                                                              ║
║  Smart installation script that adapts to your environment                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

# Configuration based on environment
configure_for_environment() {
    local env="$1"
    local distribution="$2"
    
    case "$env" in
        codespace)
            log INFO "Configuring for GitHub Codespaces..."
            # Minimal installation for codespaces
            INSTALL_GUI=false
            INSTALL_DESKTOP=false
            INSTALL_MINIMAL=true
            USE_BITWARDEN=false  # Might not be available
            ;;
        gitpod|replit)
            log INFO "Configuring for cloud development environment..."
            INSTALL_GUI=false
            INSTALL_DESKTOP=false
            INSTALL_MINIMAL=true
            USE_BITWARDEN=false
            ;;
        ci)
            log INFO "Configuring for CI environment..."
            INSTALL_GUI=false
            INSTALL_DESKTOP=false
            INSTALL_MINIMAL=true
            USE_BITWARDEN=false
            SKIP_INTERACTIVE=true
            ;;
        container)
            log INFO "Configuring for container environment..."
            INSTALL_GUI=false
            INSTALL_DESKTOP=false
            INSTALL_MINIMAL=true
            USE_BITWARDEN=false
            ;;
        local)
            log INFO "Configuring for local installation..."
            INSTALL_GUI=${INSTALL_GUI:-true}
            INSTALL_DESKTOP=${INSTALL_DESKTOP:-true}
            INSTALL_MINIMAL=false
            USE_BITWARDEN=${USE_BITWARDEN:-true}
            ;;
        *)
            log WARN "Unknown environment, using conservative defaults..."
            INSTALL_GUI=false
            INSTALL_DESKTOP=false
            INSTALL_MINIMAL=true
            USE_BITWARDEN=false
            ;;
    esac
}

# Handle special package builds (like niri-taskbar)
handle_special_builds() {
    local distribution="$1"
    local packages=("$@")
    shift
    
    # Check if niri is being installed and handle niri-taskbar
    for package in "${packages[@]}"; do
        if [[ "$package" == "niri" ]]; then
            log INFO "Niri detected, setting up niri-taskbar..."
            
            # Ensure rust is available
            if ! command -v cargo >/dev/null 2>&1; then
                log INFO "Installing Rust for niri-taskbar build..."
                if ! sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y; then
                    log WARN "Failed to install Rust, niri-taskbar build may fail"
                else
                    # Source the cargo environment
                    export PATH="$HOME/.cargo/bin:$PATH"
                fi
            fi
            
            # Build niri-taskbar
            if [[ -f "$SCRIPT_DIR/executable_niri_taskbar_builder.sh" ]]; then
                log INFO "Building niri-taskbar..."
                if bash "$SCRIPT_DIR/executable_niri_taskbar_builder.sh" build; then
                    log INFO "niri-taskbar built successfully"
                else
                    log WARN "niri-taskbar build failed, but continuing..."
                fi
            else
                log WARN "niri-taskbar builder script not found"
            fi
            break
        fi
    done
}

# Package installation wrapper
install_packages() {
    local distribution="$1"
    shift
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log DEBUG "No packages to install"
        return 0
    fi
    
    log INFO "Installing packages: ${packages[*]}"
    
    # Handle special builds first
    handle_special_builds "$distribution" "${packages[@]}"
    
    case "$distribution" in
        debian)
            sudo apt-get update
            sudo apt-get install -y "${packages[@]}"
            ;;
        fedora)
            sudo dnf install -y "${packages[@]}"
            ;;
        arch)
            sudo pacman -S --noconfirm "${packages[@]}" || true
            ;;
        alpine)
            doas apk add "${packages[@]}"
            ;;
        *)
            log ERROR "Unsupported distribution: $distribution"
            return 1
            ;;
    esac
}

# Setup mise (version manager) for development tools
setup_mise() {
    log INFO "Setting up mise (development version manager)..."
    
    # Apply mise config from chezmoi first
    if command -v chezmoi >/dev/null 2>&1; then
        log INFO "Applying mise configuration from dotfiles..."
        if chezmoi apply ~/.config/mise/config.toml 2>/dev/null; then
            log INFO "Mise config applied successfully"
        else
            log WARN "Failed to apply mise config, continuing..."
        fi
    fi
    
    # Install mise if not present
    if ! command -v mise >/dev/null 2>&1; then
        log INFO "Installing mise..."
        if curl https://mise.run | sh; then
            # Add mise to PATH for current session
            export PATH="$HOME/.local/bin:$PATH"
            
            # Check if mise is now available
            if command -v mise >/dev/null 2>&1; then
                log INFO "Mise installed successfully"
            else
                log WARN "Mise installation completed but command not found in PATH"
                return 1
            fi
        else
            log WARN "Failed to install mise, skipping version manager setup"
            return 1
        fi
    else
        log INFO "Mise already installed"
    fi
    
    # Install tools defined in mise config
    if command -v mise >/dev/null 2>&1; then
        log INFO "Installing development tools via mise..."
        
        # Change to home directory to ensure mise finds the config
        local original_dir=$(pwd)
        cd "$HOME" || return 1
        
        # Before installing other tools, ensure cargo-binstall is available, this makes mise's install process much faster
        if mise install cargo-binstall; then
            log INFO "Development tools installed successfully via mise"
        else
            log WARN "Some mise tools failed to install, but continuing..."
        fi

        if mise install; then
            log INFO "Development tools installed successfully via mise"
        else
            log WARN "Some mise tools failed to install, but continuing..."
        fi
        
        # Return to original directory
        cd "$original_dir" || true
    fi
}

# Main installation logic
main() {
    local environment distribution
    
    print_banner
    
    # Detect environment and distribution
    environment=$(detect_environment)
    distribution=$(detect_distribution)
    
    log INFO "Environment: $environment"
    log INFO "Distribution: $distribution"
    
    # Configure based on environment
    configure_for_environment "$environment" "$distribution"
    
    # Interactive prompts (if not in CI/automated mode)
    if [[ "${SKIP_INTERACTIVE:-false}" != "true" ]]; then
        if [[ "$environment" == "local" ]]; then
            read -p "Install GUI packages? (Y/n): " -r gui_input
            INSTALL_GUI=$(echo "${gui_input:-Y}" | grep -iq '^n' && echo false || echo true)
            
            read -p "Use Bitwarden for secrets? (Y/n): " -r bw_input
            USE_BITWARDEN=$(echo "${bw_input:-Y}" | grep -iq '^n' && echo false || echo true)
        fi
    fi
    
    log INFO "Configuration:"
    log INFO "  GUI packages: $INSTALL_GUI"
    log INFO "  Desktop environment: $INSTALL_DESKTOP"
    log INFO "  Minimal installation: $INSTALL_MINIMAL"
    log INFO "  Use Bitwarden: $USE_BITWARDEN"
    
    # Install base packages
    log INFO "Installing base packages..."
    local base_packages=(curl git)
    
    if [[ "$INSTALL_MINIMAL" == "false" ]]; then
        base_packages+=(bat fzf htop zsh ripgrep unzip wget)
    fi
    
    install_packages "$distribution" "${base_packages[@]}"
    
    # Install chezmoi if not already present
    if ! command -v chezmoi >/dev/null 2>&1; then
        log INFO "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Setup mise (version manager) early for development tools
    setup_mise
    
    # Setup Bitwarden CLI if requested
    if [[ "$USE_BITWARDEN" == "true" ]]; then
        log INFO "Setting up Bitwarden CLI..."
        # Add bitwarden setup logic here
    fi
    
    # Call your existing installation scripts based on environment
    if [[ "$INSTALL_MINIMAL" == "false" ]]; then
        log INFO "Running full installation script..."
        # You can call your existing fullinstall script here with appropriate flags
        # "$SCRIPT_DIR/executable_fullinstall_exp-v2.sh"
    fi
    
    log INFO "Installation completed successfully! 🎉"
    log INFO "You may need to restart your shell or source your config files."
}

# Script entry point
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    main "$@"
fi
