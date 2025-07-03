#!/bin/env bash

# Helper functions
print_box() {
    local message=$1
    local type=${2:-"WARNING"}
    local width=80
    
    echo
    printf '%*s\n' $width | tr ' ' '*'
    echo "*"
    while IFS= read -r line; do
        printf "* %-76s *\n" "$line"
    done < <(echo "$message" | fold -s -w 74)
    echo "*"
    printf '%*s\n' $width | tr ' ' '*'
    echo
}

# Package groups
declare -A PKG_GROUPS=(
    [BASE]="curl git bat clang clangd meson ninja cpio cmake build-essential mesa-utils pkg-config libssl-dev wayland-scanner++ libgles2-mesa-dev fzf htop"
    [SHELL]="zsh zoxide zsh-syntax-highlighting zsh-fast-syntax-highlighting"
    [TERMINALS]="alacritty kitty foot"
    [DESKTOP]="tidal-hifi pavucontrol element-desktop dunst ark brightnessctl nautilus"
    [BROWSERS]="librewolf firefox epiphany google-chrome"
    [HYPRLAND]="hyprland hyprpaper hyprlock hyprpolkitagent hyprshot waybar wlogout"
    [MEDIA]="pulseaudio mpv"
    [TOOLS]="flatpak ripgreg unzip wget snapd go github-cli inkscape"
    [SYSTEM]="accountsservice acpi alsa-firmware alsa-utils bluez bluez-utils cryptsetup cups networkmanager"
    [FONTS]="ttf-bitstream-vera ttf-dejavu ttf-liberation ttf-opensans noto-fonts noto-fonts-cjk noto-fonts-emoji"
)

# Distribution detection and setup
distribution="$(grep "ID_LIKE" /etc/os-release | cut -d "=" -f 2 | sed 's/\n.*//')"
if [ -z "$distribution" ]; then
    distribution="$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | sed 's/\n.*//')"
fi

echo "Detected distribution: $distribution"

# Root access check
if [ "$distribution" == "alpine" ]; then
    doas echo "Root access granted." || exit 1
else
    sudo echo "Root access granted." || exit 1
fi

# GUI installation prompt
read -p "Install GUI packages? (Y/n) " install_gui
install_gui=${install_gui:-Y}
if [[ $install_gui =~ ^[Nn]$ ]]; then
    echo "Skipping GUI package installation"
fi

# Distribution-specific setup
case "$distribution" in
    debian)
        if ! grep -q "MINT" /etc/os-release; then
            print_box "This script now only supports Linux Mint for Debian-based distributions.\nPlease use Linux Mint 21.3+ or switch to Arch Linux/Fedora." "ERROR"
            exit 1
        fi
        
        print_box "Debian and Ubuntu repositories are usually outdated.\nPlease be advised and ready for error.\nIf you want a more stable experience, consider Arch Linux or Fedora."
        
        # Configure repositories
        echo "Configuring repositories for Linux Mint..."
        sudo add-apt-repository -y ppa:nrbrtx/xorg-hotkeys
        sudo add-apt-repository -y ppa:pipewire-debian/pipewire-upstream
        
        # Hyprland repository
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://pkg.hyprland.dev/key.pgp | sudo tee /etc/apt/keyrings/hyprland.pgp > /dev/null
        echo "deb [signed-by=/etc/apt/keyrings/hyprland.pgp] https://pkg.hyprland.dev/debian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hyprland.list > /dev/null
        
        sudo apt update && sudo apt upgrade -y || exit 1
        ;;
    arch)
        # Chaotic AUR setup
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
                                'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
        sudo pacman -Syu --noconfirm
        # Install paru if needed
        if ! command -v paru &>/dev/null; then
            sudo pacman -S --needed --noconfirm base-devel
            git clone https://aur.archlinux.org/paru.git
            cd paru && makepkg -si --noconfirm && cd .. && rm -rf paru
        fi
        ;;
    fedora)
        sudo dnf copr enable -y solopasha/hyprland
        sudo dnf copr enable -y varlad/zellij
        sudo dnf install -y zellij
        curl -fsSL https://repo.librewolf.net/librewolf.repo | sudo tee /etc/yum.repos.d/librewolf.repo
        sudo dnf install -y gtk-layer-shell gtk-layer-shell-devel gtk3-devel hyprland-devel
        ;;
    *)
        print_box "Unsupported distribution: $distribution" "ERROR"
        exit 1
        ;;
esac

# install_package function
install_package() {
  PACKAGE_NAME=$1
  if [ "$distribution" == "debian" ]; then
    sudo apt-get install -y "$PACKAGE_NAME" --install-recommends
  elif [ "$distribution" == "arch" ]; then
    if command -v paru &>/dev/null; then
      paru -S --noconfirm "$PACKAGE_NAME"
    elif command -v yay &>/dev/null; then
      yay -S --noconfirm "$PACKAGE_NAME"
    else
      sudo pacman -S --noconfirm "$PACKAGE_NAME"
    fi
  elif [ "$distribution" == "fedora" ]; then
    sudo dnf install -y "$PACKAGE_NAME"
  elif [ "$distribution" == "alpine" ]; then
    # Convert some package names that are different in Alpine
    case "$PACKAGE_NAME" in
    "build-essential") PACKAGE_NAME="build-base" ;;
    "libssl-dev") PACKAGE_NAME="openssl-dev" ;;
    "pkg-config") PACKAGE_NAME="pkgconfig" ;;
    "snapd") echo "Skipping snapd - not available on Alpine" && return 0 ;;
    esac
    doas apk add "$PACKAGE_NAME"
  else
    echo "Unsupported distribution"
    exit 1
  fi
}

install_a_gui_package() {
  if [[ $install_gui =~ ^[Nn]$ ]]; then
    return 0
  fi
  PACKAGE_NAME=$1
  install_package "$PACKAGE_NAME"
}

# Helper function for privilege escalation
priv_exec() {
  if [ "$distribution" == "alpine" ]; then
    doas "$@"
  else
    sudo "$@"
  fi
}

# Install packages by group
echo "Installing base packages..."
for pkg in ${PKG_GROUPS[BASE]}; do
    install_package "$pkg"
done

echo "Installing shell packages..."
for pkg in ${PKG_GROUPS[SHELL]}; do
    install_package "$pkg"
done

if [[ ! $install_gui =~ ^[Nn]$ ]]; then
    echo "Installing GUI packages..."
    for pkg in ${PKG_GROUPS[TERMINALS]}; do
        install_a_gui_package "$pkg"
    done
    
    for pkg in ${PKG_GROUPS[DESKTOP]}; do
        install_a_gui_package "$pkg"
    done
    
    for pkg in ${PKG_GROUPS[BROWSERS]}; do
        install_a_gui_package "$pkg"
    done
    
    echo "Installing Hyprland and dependencies..."
    for pkg in ${PKG_GROUPS[HYPRLAND]}; do
        install_a_gui_package "$pkg"
    done
fi

echo "Installing media packages..."
for pkg in ${PKG_GROUPS[MEDIA]}; do
    install_package "$pkg"
done

echo "Installing system packages..."
for pkg in ${PKG_GROUPS[SYSTEM]}; do
    install_package "$pkg"
done

echo "Installing font packages..."
for pkg in ${PKG_GROUPS[FONTS]}; do
    install_package "$pkg"
done

# Development tools setup
setup_dev_tools() {
    echo "Setting up development tools..."
    
    # Install Neovim and Lazygit
    if [ "$distribution" == "debian" ]; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim-linux64.tar.gz
        rm nvim-linux64.tar.gz
        echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >>~/.bashrc

        # Install Lazygit
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    else
        install_package "neovim"
        install_package "lazygit"
    fi

    # Install Rust and cargo tools
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"

    # Install Bun
    curl -fsSL https://bun.sh/install | bash
    echo 'alias bun="~/.bun/bin/bun"' >>~/.bashrc

    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    priv_exec chsh "$(whoami)" -s /usr/bin/fish

    # Cargo installations
    cargo_tools=(
        "bananen"
        "cargo-binstall"
        "watchexec-cli"
        "cargo-clean-all"
        "watchexec"
        "starship"
        "kc"
    )

    for tool in "${cargo_tools[@]}"; do
        echo "Installing $tool..."
        if [ "$tool" = "watchexec-cli" ]; then
            cargo binstall "$tool"
        else
            cargo install "$tool"
        fi
    done

    # Install Zellij if not on Fedora
    if [ "$distribution" != "fedora" ]; then
        cargo install --locked zellij
    fi

    # Install Bombardier
    go install github.com/codesenberg/bombardier@latest
}

# Install flatpak packages
setup_flatpak() {
    echo "Setting up Flatpak packages..."
    flatpak_packages=(
        "chat.revolt.RevoltDesktop"
        "flathub xyz.armcord.ArmCord"
        "me.timtimschneeberger.GalaxyBudsClient"
    )

    for pkg in "${flatpak_packages[@]}"; do
        flatpak install "$pkg" -y
    done
}

# Setup snap packages
setup_snap() {
    if [ "$distribution" == "alpine" ]; then
        echo "Snap is not available on Alpine Linux. Skipping Snap package installation."
        return
    fi

    echo "Setting up Snap packages..."
    sudo systemctl enable snapd.socket
    sudo systemctl start snapd.socket
    sudo ln -sf /var/lib/snapd/snap /snap
    sudo systemctl enable snapd

    snap_packages=(
        "discord"
        "gnome-taquin"
    )

    for pkg in "${snap_packages[@]}"; do
        sudo snap install "$pkg"
    done
}

# Run setups
setup_dev_tools
setup_flatpak
setup_snap

# Final configuration
echo "Setting up final configurations..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply strawmelonjuice
cp ~/.config/zed/set-settings.json ~/.config/zed/settings.json
nvim --headless '+Lazy! sync' +qa

# Git configuration
git config --global user.email "mar@strawmelonjuice.com"
git config --global user.name "MLC Bloeiman"

# Installation complete
print_box "Installation complete.\nPlease restart your system to apply all changes." "INFO"
