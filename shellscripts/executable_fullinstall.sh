#!/bin/env bash

echo This is supposed to be a full install script for my dotfiles. It will install chezmoi, neovim, and other necessary packages.
echo Please do note I am still mapping out the necessary packages for this script to work on all distributions.
echo also note that this script is not yet complete and may not work as intended.
echo Installation takes about 15 minutes to complete.

cd
sudo echo Root access granted. || exit 1

if [ -f /etc/debian_version ]; then
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
else
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf
  sudo pacman -Syu
fi

install_package() {
  PACKAGE_NAME=$1
  if [ -f /etc/debian_version ]; then
    sudo apt-get install -y "$PACKAGE_NAME"
  elif [ -f /etc/arch-release ]; then
    if command -v yay &>/dev/null; then
      yay -S --noconfirm "$PACKAGE_NAME"
    else
      sudo pacman -S --noconfirm "$PACKAGE_NAME"
    fi
  else
    echo "Unsupported distribution"
    exit 1
  fi
}

# Install necessary packages.
install_package "curl"
install_package "git"
install_package "alacritty"
install_package "bat"
install_package "clang"
install_package "meson"
install_package "ninja"
install_package "cpio"
install_package "cmake"
install_package "build-essential"
install_package "mesa-utils"
install_package "fzf"
install_package "flatpak"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
install_package "ripgrep"
install_package "spotify"
install_package "dunst"
install_package "ark"
install_package "bombardier"
install_package "brightnessctl"
install_package "unzip"
install_package "wget"
install_package "discord"
install_package "dolphin"
install_package "fastfetch"
install_package "firefox"
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
install_package "hyprlock"
install_package "hyprpolkitagent"
install_package "hyprshot"
install_package "waybar"

# Neovim and Lazygit need to be downloaded manually for Debian. Otherwise it'll be too outdated.

if [ -f /etc/debian_version ]; then
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
nvim --headless '+Lazy! sync' +qa

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
if [ -f /etc/debian_version ]; then
  sudo apt-get install -y curl git
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0
elif [ -f /etc/arch-release ]; then
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

# Flatpak packages
flatpak install com.visualstudio.code -y

# Install chezmoi dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply strawmelonjuice
