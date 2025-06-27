#!/usr/bin/env bash

# Niri Taskbar Builder
# This script handles the build process for the niri-taskbar submodule

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
    echo -e "${GREEN}[NIRI-TASKBAR]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[NIRI-TASKBAR WARN]${NC} $*"
}

error() {
    echo -e "${RED}[NIRI-TASKBAR ERROR]${NC} $*" >&2
}

info() {
    echo -e "${BLUE}[NIRI-TASKBAR INFO]${NC} $*"
}

# Configuration
readonly CHEZMOI_DIR="$HOME/.local/share/chezmoi"
readonly NIRI_TASKBAR_DIR="$CHEZMOI_DIR/dot_dotfiles/deps/niri-taskbar"
readonly TARGET_LIB="$NIRI_TASKBAR_DIR/target/release/libniri_taskbar.so"

# Check if niri-taskbar is already built
check_built() {
    if [[ -f "$TARGET_LIB" ]]; then
        log "niri-taskbar is already built at: $TARGET_LIB"
        return 0
    fi
    return 1
}

# Check prerequisites
check_prerequisites() {
    local missing_deps=()
    
    # Check for git
    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi
    
    # Check for cargo/rust
    if ! command -v cargo >/dev/null 2>&1; then
        missing_deps+=("cargo/rust")
    fi
    
    # Check for niri (optional warning)
    if ! command -v niri >/dev/null 2>&1; then
        warn "niri command not found - you may need to install niri first"
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        error "Please install these before building niri-taskbar"
        return 1
    fi
    
    return 0
}

# Initialize or update the submodule
setup_submodule() {
    log "Setting up niri-taskbar submodule..."
    
    # Ensure we're in the chezmoi directory
    if [[ ! -d "$CHEZMOI_DIR" ]]; then
        error "Chezmoi directory not found: $CHEZMOI_DIR"
        return 1
    fi
    
    cd "$CHEZMOI_DIR"
    
    # Check if this is a git repository
    if [[ ! -d ".git" ]]; then
        error "Not a git repository: $CHEZMOI_DIR"
        error "This script requires chezmoi to be managing a git repository"
        return 1
    fi
    
    # Check if submodule exists in .gitmodules
    if ! git config -f .gitmodules --get-regexp submodule | grep -q "niri-taskbar"; then
        warn "niri-taskbar submodule not found in .gitmodules"
        warn "You may need to add it manually with:"
        warn "  git submodule add <repo-url> dot_dotfiles/deps/niri-taskbar"
        return 1
    fi
    
    # Initialize/update submodule
    if [[ ! -d "dot_dotfiles/deps/niri-taskbar/.git" ]]; then
        info "Initializing niri-taskbar submodule..."
        git submodule update --init --recursive dot_dotfiles/deps/niri-taskbar
    else
        info "Updating niri-taskbar submodule..."
        git submodule update --recursive dot_dotfiles/deps/niri-taskbar
    fi
    
    return 0
}

# Build the niri-taskbar
build_taskbar() {
    log "Building niri-taskbar..."
    
    if [[ ! -d "$NIRI_TASKBAR_DIR" ]]; then
        error "niri-taskbar directory not found: $NIRI_TASKBAR_DIR"
        error "Please run setup first"
        return 1
    fi
    
    cd "$NIRI_TASKBAR_DIR"
    
    # Check for Cargo.toml
    if [[ ! -f "Cargo.toml" ]]; then
        error "Cargo.toml not found in $NIRI_TASKBAR_DIR"
        error "This doesn't appear to be a valid Rust project"
        return 1
    fi
    
    info "Building in release mode..."
    
    # Build with progress output
    if cargo build --release; then
        log "Build completed successfully!"
        
        # Verify the output
        if [[ -f "$TARGET_LIB" ]]; then
            log "Library built: $TARGET_LIB"
            
            # Show file info
            local file_size=$(du -h "$TARGET_LIB" | cut -f1)
            info "Library size: $file_size"
            
            return 0
        else
            error "Build completed but library not found at expected location"
            return 1
        fi
    else
        error "Build failed"
        return 1
    fi
}

# Clean build artifacts
clean() {
    log "Cleaning niri-taskbar build artifacts..."
    
    if [[ -d "$NIRI_TASKBAR_DIR" ]]; then
        cd "$NIRI_TASKBAR_DIR"
        
        if [[ -f "Cargo.toml" ]]; then
            cargo clean
            log "Build artifacts cleaned"
        else
            warn "No Cargo.toml found, skipping cargo clean"
        fi
    else
        warn "niri-taskbar directory not found, nothing to clean"
    fi
}

# Update submodule to latest
update() {
    log "Updating niri-taskbar to latest version..."
    
    cd "$CHEZMOI_DIR"
    
    # Update to latest commit
    git submodule update --remote dot_dotfiles/deps/niri-taskbar
    
    log "Submodule updated, rebuilding..."
    build_taskbar
}

# Show status
status() {
    echo "Niri Taskbar Status:"
    echo "==================="
    
    # Check if built
    if check_built; then
        echo "✅ Built: Yes"
        local file_size=$(du -h "$TARGET_LIB" | cut -f1)
        echo "📁 Location: $TARGET_LIB"
        echo "📊 Size: $file_size"
        
        # Check modification time
        local mod_time=$(stat -c %Y "$TARGET_LIB" 2>/dev/null || stat -f %m "$TARGET_LIB" 2>/dev/null || echo "unknown")
        if [[ "$mod_time" != "unknown" ]]; then
            local mod_date=$(date -d "@$mod_time" 2>/dev/null || date -r "$mod_time" 2>/dev/null || echo "unknown")
            echo "🕒 Built: $mod_date"
        fi
    else
        echo "❌ Built: No"
    fi
    
    # Check submodule status
    if [[ -d "$NIRI_TASKBAR_DIR/.git" ]]; then
        echo "📦 Submodule: Initialized"
        
        cd "$NIRI_TASKBAR_DIR"
        local commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        echo "🔖 Commit: $commit"
    else
        echo "❌ Submodule: Not initialized"
    fi
    
    # Check prerequisites
    echo ""
    echo "Prerequisites:"
    echo "============="
    
    command -v git >/dev/null 2>&1 && echo "✅ git" || echo "❌ git"
    command -v cargo >/dev/null 2>&1 && echo "✅ cargo" || echo "❌ cargo"
    command -v niri >/dev/null 2>&1 && echo "✅ niri" || echo "⚠️  niri (optional)"
}

# Main function
main() {
    local action="${1:-build}"
    
    case "$action" in
        build)
            check_prerequisites || exit 1
            setup_submodule || exit 1
            build_taskbar || exit 1
            ;;
        setup)
            check_prerequisites || exit 1
            setup_submodule || exit 1
            ;;
        clean)
            clean
            ;;
        update)
            check_prerequisites || exit 1
            update || exit 1
            ;;
        status)
            status
            ;;
        check)
            if check_built; then
                log "niri-taskbar is built and ready"
                exit 0
            else
                warn "niri-taskbar is not built"
                exit 1
            fi
            ;;
        help|--help|-h)
            cat << EOF
Niri Taskbar Builder

Usage: $0 <command>

Commands:
    build       Setup submodule and build niri-taskbar (default)
    setup       Initialize/update the submodule only
    clean       Clean build artifacts
    update      Update submodule to latest and rebuild
    status      Show detailed status information
    check       Check if niri-taskbar is built (exit code 0 = built)
    help        Show this help message

Examples:
    $0              # Build niri-taskbar
    $0 status       # Show current status
    $0 update       # Update to latest version
    $0 clean        # Clean build artifacts

The niri-taskbar library will be built at:
    $TARGET_LIB

This library is used by waybar for niri workspace integration.
EOF
            ;;
        *)
            error "Unknown command: $action"
            error "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
    main "$@"
fi
