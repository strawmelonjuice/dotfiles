#!/bin/env bash

distribution="$(cat /etc/os-release | grep "ID_LIKE" | cut -d "=" -f 2)"
if [ -z "$distribution" ]; then
  # If ID_LIKE is not found, default to ID (Fedora, for example)
  distribution="$(cat /etc/os-release | grep "ID" | cut -d "=" -f 2)"
fi
echo This is supposed to be a full install script for my dotfiles. It will install chezmoi, neovim, and other necessary packages.
echo Please do note I am still mapping out the necessary packages for this script to work on all distributions.
echo also note that this script is not yet complete and may not work as intended.
echo Installation takes about 20 minutes to complete.

cd
sudo echo Root access granted. || exit 1

if [ "$distribution" == "debian" ]; then
  echo "\n\n\n"
  echo "*****************************************WARNING*****************************************"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                         Debian and Ubuntu repositories are usually                    *"
  echo "*                         outdated. Please be advised and ready for error.              *"
  echo "*                         If you want a more stable experience, consider a              *"
  echo "*                         distribution like Arch Linux or even Fedora.                  *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*                                                                                       *"
  echo "*****************************************WARNING*****************************************"
  if grep -q "Ubuntu" /etc/os-release; then
    VERSION_ID=$(grep "VERSION_ID" /etc/os-release | cut -d '"' -f 2)
    if [ "$(echo "$VERSION_ID" | awk -F. '{print $1$2}')" -gt "2409" ]; then
      echo "Ubuntu version is newer than 24.10. Continuing..."
      sudo add-apt-repository universe
      sudo snap install chezmoi --classic
      sudo apt-get install --install-recommends linux-generic-hwe-16.04
    else
      echo Your Ubuntu version is too old. Please upgrade to 24.10 or newer.
      exit 1
    fi
  fi
  sudo apt-get update || exit 1
elif [ "$distribution" == "arch" ]; then
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf
  sudo pacman -Syu
  # Install yoghurt
  sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
elif ["$distribution" == "fedora"]; then
  sudo dnf copr enable solopasha/hyprland
fi

install_package() {
  PACKAGE_NAME=$1
  if [ "$distribution" == "debian" ]; then
    sudo apt-get install -y "$PACKAGE_NAME" --install-recommends
  elif [ "$distribution" == "arch" ]; then
    if command -v yay &>/dev/null; then
      yay -S --noconfirm "$PACKAGE_NAME"
    else
      sudo pacman -S --noconfirm "$PACKAGE_NAME"
    fi
  elif [ "$distribution" == "fedora" ]; then
    sudo dnf install -y "$PACKAGE_NAME"
  else
    echo "Unsupported distribution"
    exit 1
  fi
}

# Install necessary packages.
install_package "curl"
install_package "git"
install_package "alacritty"
install_package "contour"
install_package "bat"
install_package "clang"
install_package "clangd"
install_package "meson"
install_package "ninja"
install_package "cpio"
install_package "cmake"
install_package "build-essential"
install_package "mesa-utils"
install_package "pkg-config"
install_package "libssl-dev"
install_package "wayland-scanner++"
install_package "libgles2-mesa-dev"
install_package "fzf"
install_package "htop"
install_package "pavucontrol"
install_package "pulseaudio"
install_package "flatpak"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
install_package "ripgrep"
install_package "dunst"
install_package "ark"
install_package "brightnessctl"
install_package "unzip"
install_package "wget"
install_package "snapd"
install_package "go"
install_package "nautilus"
install_package "fastfetch"
install_package "firefox"
install_package "zen-browser"
install_package "github-cli"
install_package "google-chrome"
install_package "hyfetch"
install_package "inkscape"
install_package "kitty"
install_package "slurp"
install_package "wev"
install_package "rofi"
install_package "zsh"
install_package "zoxide"
install_package "zsh-syntax-highlighting"
install_package "zsh-fast-syntax-highlighting"

## Hyprland and its dependencies
install_package "hyprland"
if [ "$distribution" == "debian" ]; then
  # https://github.com/hyprwm/hyprpaper/releases/download/v0.7.3/v0.7.3.tar.gz
  PAPER_VERSION=$(curl -s "https://api.github.com/repos/hyprwm/hyprpaper/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo hyprpaper.tar.gz "https://github.com/hyprwm/hyprpaper/releases/latest/download/v${PAPER_VERSION}.tar.gz"
  tar xf hyprpaper.tar.gz hyprpaper/hyprpaper
  sudo install ./hyprpaper/hyprpaper /usr/local/bin
elif [ "$distribution" == "arch" ]; then
  install_package "xcb-util-xkb"
fi
install_package "hyprpaper"
install_package "hyprlock"
install_package "hyprpolkitagent"
install_package "hyprshot"
install_package "waybar"
install_package "wlogout"

## Neovim and Lazygit need to be downloaded manually for Debian.

if [ "$distribution" == "debian" ]; then
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz
  rm nvim-linux64.tar.gz
  echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >>~/.bashrc

  # and lazygit
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit.tar.gz
  rm -r ./lazygit
else
  install_package "neovim"
  install_package "lazygit"
fi
source ~/.bashrc

# Self-installers
## Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
## Bun
curl -fsSL https://bun.sh/install | bash
echo 'alias bun="~/.bun/bin/bun"' >>~/.bashrc
## OMZ
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh $(whoami) -s /bin/zsh
## ASDF
if [ $distribution == "debian" ]; then
  sudo apt-get install -y curl git
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
elif [ "$distribution" == "arch" ]; then
  git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si
  cd
fi

# Cargo installs
## Bananen
cargo install bananen

## Cargo binstall
cargo install cargo-binstall

## Cargo watch
cargo install cargo-watch

## Watchexec
cargo install watchexec

## Starship
cargo install starship --locked

## Zellij
cargo install --locked zellij

# Go installs
## Bombardier
go install github.com/codesenberg/bombardier@latest

# Flatpak packages
flatpak install chat.revolt.RevoltDesktop -y
flatpak install me.timtimschneeberger.GalaxyBudsClient -y

# Snap packages
sudo snap install discord -y
sudo snap install spotify -y
sudo snap install gnome-taquin -y

# Install chezmoi dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply strawmelonjuice
cp ~/.config/zed/set-settings.json ~/.config/zed/settings.json
nvim --headless '+Lazy! sync' +qa

# ready
echo "Installation complete. Please consider restarting your system to apply some changes."
