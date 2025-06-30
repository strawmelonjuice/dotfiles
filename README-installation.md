# Smart Dotfiles Installation System

This is an intelligent dotfiles setup that adapts to different environments and integrates with Bitwarden for secret management.

## Quick Start

### One-line Installation

```bash
# Download and run the bootstrap script
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/bootstrap.sh | bash
```

### Manual Installation

```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# 2. Initialize dotfiles
chezmoi init --apply https://github.com/YOUR_USERNAME/dotfiles.git

# 3. Run smart installer
~/.local/share/chezmoi/shellscripts/executable_smart_install.sh
```

## Environment Detection

The installation system automatically detects your environment and adapts:

| Environment | GUI Apps | Desktop | Bitwarden | Package Set |
|-------------|----------|---------|-----------|-------------|
| **Codespace** | ❌ | ❌ | ❌ | Minimal |
| **Local Desktop** | ✅ | ✅ | ✅ | Full |
| **Container** | ❌ | ❌ | ❌ | Development |
| **CI/Testing** | ❌ | ❌ | ❌ | Essential |

## Configuration

### Installation Config

Edit `install-config.toml` to customize:

```toml
# Add packages to different groups
[packages]
essential = ["curl", "git", "wget"]
development = ["neovim", "fzf", "ripgrep"]
gui = ["alacritty", "firefox"]

# Customize environment behavior
[environments.local]
install_gui = true
use_bitwarden = true
package_groups = ["essential", "development", "gui"]
```

### Environment Variables

Control behavior with environment variables:

```bash
# Force specific environment detection
FORCE_ENVIRONMENT=codespace ./bootstrap.sh

# Skip interactive prompts
SKIP_INTERACTIVE=true ./bootstrap.sh

# Bitwarden settings
BW_EMAIL=your@email.com
BW_SERVER=https://your-bitwarden-server.com

# Debug mode
DEBUG=1 ./bootstrap.sh
```

## Bitwarden Integration

### Setup

```bash
# Install and setup Bitwarden CLI
./shellscripts/executable_bitwarden_helper.sh install
./shellscripts/executable_bitwarden_helper.sh login
```

### Usage in Templates

Use Bitwarden secrets in your chezmoi templates:

```go-template
# In any .tmpl file
{{ $token := output "shellscripts/executable_bitwarden_helper.sh" "template" "GitHub Token" | trim }}
{{ if ne $token "BW_NOT_AVAILABLE" }}
export GITHUB_TOKEN="{{ $token }}"
{{ end }}
```

### Manual Secret Retrieval

```bash
# Get a password
./shellscripts/executable_bitwarden_helper.sh get "My Service"

# Get a specific field
./shellscripts/executable_bitwarden_helper.sh get "SSH Key" "private_key"

# Check status
./shellscripts/executable_bitwarden_helper.sh status
```

## Bitwarden CLI Integration

The installation system includes automatic **Bitwarden CLI** setup for secret management in your dotfiles:

### Automatic Installation

When Bitwarden is enabled (`USE_BITWARDEN=true`), the system:
1. **Checks for existing installation** - skips if already present
2. **Uses Bun to install** - `bun install -g @bitwarden/cli` (installed via mise)
3. **Verifies installation** - confirms `bw` command is available
4. **Shows version info** - displays installed version

### Installation Methods (Priority Order)

1. **Bun** (preferred) - Fast, reliable, consistent across platforms
2. **Snap** (Linux) - `sudo snap install bw`
3. **npm** (fallback) - `npm install -g @bitwarden/cli`
4. **Homebrew** (macOS) - `brew install bitwarden-cli`

### Environment Behavior

| Environment | Bitwarden CLI |
|-------------|---------------|
| **Local Desktop** | ✅ Installed automatically |
| **Codespace** | ❌ Skipped (not needed) |
| **Container** | ❌ Skipped (security) |
| **CI/Testing** | ❌ Skipped (not applicable) |

### Manual Management

Use the dedicated Bitwarden helper:

```bash
# Install Bitwarden CLI
./shellscripts/executable_bitwarden_helper.sh install

# Login to your vault
./shellscripts/executable_bitwarden_helper.sh login

# Unlock vault
./shellscripts/executable_bitwarden_helper.sh unlock

# Get a secret
./shellscripts/executable_bitwarden_helper.sh get "GitHub Token"

# Check status
./shellscripts/executable_bitwarden_helper.sh status
```

### Template Integration

Once installed, use in your chezmoi templates:

```go-template
{{- $token := output "shellscripts/executable_bitwarden_helper.sh" "template" "GitHub Token" | trim }}
{{- if and (ne $token "BW_NOT_AVAILABLE") (ne $token "BW_SECRET_NOT_FOUND") }}
export GITHUB_TOKEN="{{ $token }}"
{{- end }}
```

### Prerequisites

- **Bun** (installed via mise) - Primary installation method
- **Internet access** - For downloading CLI
- **Valid Bitwarden account** - For accessing secrets

### Configuration

Set environment variables for automatic setup:

```bash
# Your Bitwarden email
export BW_EMAIL="your@email.com"

# Custom server (optional)
export BW_SERVER="https://your-server.com"

# Force Bitwarden setup even in restricted environments
export USE_BITWARDEN=true
```

This ensures your secrets are available across environments while maintaining security best practices! 🔐

## Package Management

### Supported Distributions

- **Debian/Ubuntu**: `apt`
- **Fedora/RHEL**: `dnf`
- **Arch Linux**: `pacman`
- **Alpine Linux**: `apk` (with `doas`)

### Package Groups

| Group | Description | Examples |
|-------|-------------|----------|
| `essential` | Core utilities | `curl`, `git`, `wget` |
| `development` | Dev tools | `neovim`, `fzf`, `ripgrep` |
| `gui` | GUI applications | `alacritty`, `firefox` |
| `desktop` | Desktop environment | `hyprland`, `waybar` |
| `cloud` | Cloud-specific tools | `zoxide`, `starship` |

### External Tools

Some tools are installed via their own installers:

- **chezmoi**: Official installer script
- **starship**: Official installer script  
- **zoxide**: Official installer script
- **Bitwarden CLI**: Package manager or npm

## Scripts Overview

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | Main entry point, sets up everything |
| `executable_smart_install.sh` | Intelligent package installer |
| `executable_bitwarden_helper.sh` | Bitwarden CLI integration |
| `executable_fullinstall.sh` | Legacy full installer |
| `executable_fullinstall_exp-v2.sh` | Experimental installer |

## Customization

### Adding New Environments

1. Add environment detection in `detect_environment()`
2. Add configuration in `configure_for_environment()`
3. Update `install-config.toml`

### Adding New Packages

1. Add to appropriate group in `install-config.toml`
2. Add distribution-specific mappings if needed
3. For external tools, add to `[external_tools]` section

### Adding New Distributions

1. Add detection logic in `detect_distribution()`
2. Add package manager commands in `install-config.toml`
3. Add package mappings for distribution-specific names

## Troubleshooting

### Common Issues

**Bitwarden not working:**
```bash
# Check status
./shellscripts/executable_bitwarden_helper.sh status

# Re-login
./shellscripts/executable_bitwarden_helper.sh login
```

**Package installation fails:**
```bash
# Enable debug mode
DEBUG=1 ./bootstrap.sh

# Check distribution detection
grep "ID" /etc/os-release
```

**Environment not detected correctly:**
```bash
# Force environment
FORCE_ENVIRONMENT=local ./bootstrap.sh
```

### Debug Mode

Enable debug logging:

```bash
DEBUG=1 ./bootstrap.sh
```

### Logs

Installation logs are printed to stdout. For persistent logging, redirect:

```bash
./bootstrap.sh 2>&1 | tee install.log
```

## Migration from Old Scripts

Your existing `executable_fullinstall.sh` and `executable_fullinstall_exp-v2.sh` are preserved. The new system can call them or you can migrate packages to the new configuration format.

## Security Notes

- Bitwarden session tokens are stored in `~/.cache/bw-session` with 600 permissions
- Templates handle missing Bitwarden gracefully (won't break if BW unavailable)
- No secrets are logged or stored in plain text
- Session tokens expire and are automatically refreshed

## Contributing

1. Test changes in different environments (local, codespace, container)
2. Update `install-config.toml` for new packages/distributions
3. Add environment detection for new platforms
4. Document new features in this README

## Niri Integration

The installation system includes special handling for **Niri** (the scrollable-tiling Wayland compositor):

### Automatic Setup

When `niri` is installed, the system automatically:
1. Installs Rust (if not present)
2. Initializes the `niri-taskbar` git submodule  
3. Builds the taskbar library with `cargo build --release`
4. Creates `libniri_taskbar.so` for waybar integration

### Manual Management

Use the dedicated niri-taskbar builder:

```bash
# Build niri-taskbar
./shellscripts/executable_niri_taskbar_builder.sh build

# Check status
./shellscripts/executable_niri_taskbar_builder.sh status

# Update to latest version
./shellscripts/executable_niri_taskbar_builder.sh update

# Clean build artifacts
./shellscripts/executable_niri_taskbar_builder.sh clean
```

### Waybar Integration

The built library is automatically available for waybar:

```json
// In waybar config
"cffi/niri-taskbar": {
    "module_path": "/home/user/.local/share/chezmoi/.dotfiles/deps/niri-taskbar/target/release/libniri_taskbar.so"
}
```

### Prerequisites

- **Git**: For submodule management
- **Rust/Cargo**: For building the taskbar
- **Niri**: The compositor itself

### Distribution Support

| Distribution | Niri Package | Status |
|--------------|--------------|--------|
| **Arch Linux** | `niri` | ✅ Full support |
| **Fedora** | `niri` | ✅ Full support |
| **Debian/Ubuntu** | ❌ | Excluded (too old) |
| **Alpine** | ❌ | Excluded (not available) |

## Mise Integration (Development Version Manager)

The installation system includes integrated support for **mise** (formerly rtx) to manage development tool versions:

### Automatic Setup

During installation, the system automatically:
1. **Applies mise config** from your dotfiles: `chezmoi apply ~/.config/mise/config.toml`
2. **Installs mise** if not present via the official installer
3. **Runs `mise install`** to install all configured development tools

### Supported Tools

Based on your mise configuration, tools like:
- **Node.js** (specific versions)
- **Python** (multiple versions)
- **Go** (latest or pinned versions)  
- **Rust** (stable/nightly)
- **And many more** defined in your `config.toml`

### Manual Management

After installation, you can manage tools with:

```bash
# Install all tools from config
mise install

# Install specific tool
mise install node@20

# List installed tools
mise list

# Update all tools
mise upgrade

# Check status
mise doctor
```

### Environment Integration

Mise automatically:
- **Activates in shell** (if configured in your dotfiles)
- **Sets environment variables** for active tool versions
- **Manages PATH** for installed tools
- **Works with direnv** for project-specific versions

### Configuration Location

Your mise configuration is managed by chezmoi at:
- **Template**: `~/.local/share/chezmoi/dot_config/mise/config.toml.tmpl`
- **Applied**: `~/.config/mise/config.toml`

### Environment-Specific Behavior

| Environment | Mise Setup |
|-------------|------------|
| **Local Desktop** | ✅ Full tool installation |
| **Codespace** | ✅ Development tools only |
| **Container** | ✅ Minimal development setup |
| **CI/Testing** | ❌ Skipped for speed |

This ensures you have consistent development tool versions across all your environments! 🛠️
