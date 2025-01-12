#!/bin/bash

if [ -f /etc/debian_version ]; then
    sudo apt-get update || exit 1
fi

install_package() {
    PACKAGE_NAME=$1
    if [ -f /etc/debian_version ]; then
        sudo apt-get install -y "$PACKAGE_NAME"
    elif [ -f /etc/arch-release ]; then
        if command -v yay &> /dev/null; then
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
install_package "chezmoi"

# Neovim needs to be downloaded manually for Debian. Otherwise it'll be too outdated.

if [ -f /etc/debian_version ]; then
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz
  rm nvim-linux64.tar.gz
  echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
  else
  install_package "neovim"
fi


