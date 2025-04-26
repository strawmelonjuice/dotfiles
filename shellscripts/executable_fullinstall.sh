#!/bin/env bash

distribution="$(cat /etc/os-release | grep "ID_LIKE" | cut -d "=" -f 2 | sed 's/\n.*//')"
if [ -z "$distribution" ]; then
  # If ID_LIKE is not found, default to ID (Fedora, for example)
  distribution="$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | sed 's/\n.*//')"

fi

echo "Detected distribution: $distribution"

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
  # Install yoghurt if not there.
  if command -v yay &>/dev/null; then

    sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay
  fi
elif [ "$distribution" == "fedora" ]; then
  sudo dnf copr enable solopasha/hyprland
  sudo dnf copr enable varlad/zellij
  sudo dnf install zellij
  curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
  sudo dnf install -y gtk-layer-shell gtk-layer-shell-devel gtk3-devel hyprland-devel
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

# install the package
install_package librewolf
install_package "curl"
install_package "git"
install_package "alacritty"
install_package "kitty"
install_package "foot"
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
install_package "tidal-hifi"
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
install_package "epiphany"
install_package "zen-browser"
install_package "google-chrome"
install_package "github-cli"
install_package "hyfetch"
install_package "inkscape"
install_package "slurp"
install_package "wev"
install_package "wofi"
install_package "zsh"
install_package "zoxide"
install_package "zsh-syntax-highlighting"
install_package "zsh-fast-syntax-highlighting"
install_package accountsservice
install_package acpi
install_package alsa-firmware
install_package alsa-plugins
install_package alsa-utils
install_package arandr
install_package arc-gtk-theme-eos
install_package archlinux-xdg-menu
install_package aspell
install_package awesome-terminal-fonts
install_package b43-fwcutter
install_package bash-completion
install_package bind
install_package bluez
install_package bluez-utils
install_package btrfs-progs
install_package cantarell-fonts
install_package cryptsetup
install_package cups
install_package cups-browsed
install_package cups-filters
install_package cups-pdf
install_package device-mapper
install_package dex
install_package diffutils
install_package dmenu
install_package dmidecode
install_package dmraid
install_package dnsmasq
install_package dosfstools
install_package downgrade
install_package dracut
install_package duf
install_package dunst
install_package e2fsprogs
install_package efibootmgr
install_package efitools
install_package endeavouros-branding
install_package endeavouros-keyring
install_package endeavouros-mirrorlist
install_package eos-apps-info
install_package eos-hooks
install_package eos-lightdm-slick-theme
install_package eos-log-tool
install_package eos-packagelist
install_package eos-qogir-icons
install_package eos-quickstart
install_package eos-rankmirrors
install_package eos-settings-i3wm
install_package ethtool
install_package exfatprogs
install_package f2fs-tools
install_package fastfetch
install_package feh
install_package ffmpegthumbnailer
install_package firefox
install_package firewalld
install_package foomatic-db
install_package foomatic-db-engine
install_package foomatic-db-gutenprint-ppds
install_package foomatic-db-nonfree
install_package foomatic-db-nonfree-ppds
install_package foomatic-db-ppds
install_package galculator
install_package ghostscript
install_package git
install_package glances
install_package gsfonts
install_package gst-libav
install_package gst-plugin-pipewire
install_package gst-plugins-bad
install_package gst-plugins-ugly
install_package gutenprint
install_package gvfs
install_package gvfs-afc
install_package gvfs-gphoto2
install_package gvfs-mtp
install_package gvfs-nfs
install_package gvfs-smb
install_package haveged
install_package hdparm
install_package hplip
install_package hwdetect
install_package hwinfo
install_package hyfetch
install_package i3-wm
install_package i3blocks
install_package i3lock
install_package i3status
install_package inetutils
install_package intel-ucode
install_package inxi
install_package iptables-nft
install_package iwd
install_package jfsutils
install_package jq
install_package libdvdcss
install_package libgsf
install_package libopenraw
install_package libwnck3
install_package lightdm
install_package lightdm-slick-greeter
install_package logrotate
install_package lsb-release
install_package lsscsi
install_package lvm2
install_package man-db
install_package man-pages
install_package mdadm
install_package meld
install_package mesa-utils
install_package modemmanager
install_package mpv
install_package mtools
install_package nano
install_package nano-syntax-highlighting
install_package netctl
install_package network-manager-applet
install_package networkmanager
install_package networkmanager-openconnect
install_package networkmanager-openvpn
install_package nfs-utils
install_package nilfs-utils
install_package noto-fonts
install_package noto-fonts-cjk
install_package noto-fonts-emoji
install_package noto-fonts-extra
install_package nss-mdns
install_package ntfs-3g
install_package ntp
install_package numlockx
install_package nwg-look
install_package openssh
install_package pacman-contrib
install_package pavucontrol
install_package perl
install_package pipewire-alsa
install_package pipewire-jack
install_package pipewire-pulse
install_package pkgfile
install_package playerctl
install_package plocate
install_package polkit-gnome
install_package poppler-glib
install_package power-profiles-daemon
install_package pv
install_package python
install_package python-defusedxml
install_package python-packaging
install_package python-pillow
install_package python-pyqt5
install_package python-pyqt6
install_package python-reportlab
install_package rebuild-detector
install_package reflector
install_package reflector-simple
install_package rofi
install_package rsync
install_package rtkit
install_package rustup
install_package s-nail
install_package sane
install_package scrot
install_package sg3_utils
install_package smartmontools
install_package sof-firmware
install_package splix
install_package sudo
install_package sysfsutils
install_package sysstat
install_package system-config-printer
install_package systemd-sysvcompat
install_package texinfo
install_package thunar
install_package thunar-archive-plugin
install_package thunar-volman
install_package tldr
install_package ttf-bitstream-vera
install_package ttf-dejavu
install_package ttf-liberation
install_package ttf-opensans
install_package tumbler
install_package unrar
install_package upower
install_package usb_modeswitch
install_package usbutils
install_package welcome
install_package wget
install_package which
install_package wireplumber
install_package wra_supplicant
install_package xarchiver
install_package xbindkeys
install_package xdg-user-dirs
install_package xdg-user-dirs-gtk
install_package xdg-utils
install_package xed
install_package xf86-input-libinput
install_package xfsprogs
install_package xl2tpd
install_package xorg-server
install_package xorg-xbacklight
install_package xorg-xdpyinfo
install_package xorg-xinit
install_package xorg-xinput
install_package xorg-xkill
install_package xorg-xrandr
install_package xss-lock
install_package zip

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

## Anyrun
git clone https://github.com/anyrun-org/anyrun && cd anyrun && cargo build --release && cargo install --path anyrun/ && mkdir -p ~/.config/anyrun/plugins && cp target/release/*.so ~/.config/anyrun/plugins && cp examples/config.ron ~/.config/anyrun/config.ron && cd .. && rm -rf ./anyrun

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
#
# Note: Mise en place gets installed on first launch of either zsh or bash.
## Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
## Bun
curl -fsSL https://bun.sh/install | bash
echo 'alias bun="~/.bun/bin/bun"' >>~/.bashrc
## OMZ
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh $(whoami) -s /bin/zsh

# Cargo installs
## Bananen
cargo install bananen

## Cargo binstall
cargo install cargo-binstall

## Cargo watch
cargo install cargo-watch

## Cargo clean all
cargo install cargo-clean-all

## Watchexec
cargo install watchexec

## Starship
cargo install starship --locked

## Zellij
if [ "$distribution" != "fedora" ]; then
  cargo install --locked zellij
fi

# Go installs
## Bombardier
go install github.com/codesenberg/bombardier@latest

# Flatpak packages
flatpak install chat.revolt.RevoltDesktop
flatpak install me.timtimschneeberger.GalaxyBudsClient

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
