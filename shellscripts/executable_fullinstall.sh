#!/bin/env bash

distribution="$(cat /etc/os-release | grep "ID_LIKE" | cut -d "=" -f 2 | sed 's/\n.*//')"
if [ -z "$distribution" ]; then
  # If ID_LIKE is not found, default to ID (Fedora, for example)
  distribution="$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | sed 's/\n.*//')"

fi

# Handle Alpine specifically
if [ "$distribution" == "alpine" ]; then
  echo "Alpine Linux detected"
  # First ensure doas is installed using sudo (if it exists)
  command -v sudo >/dev/null 2>&1 && sudo apk add doas || apk add doas
  # Configure doas
  echo "permit :wheel" | doas tee /etc/doas.d/doas.conf
  # Enable community repository
  doas sed -i 's/#http/http/' /etc/apk/repositories
  doas sed -i 's/#community/community/' /etc/apk/repositories
  doas apk update
  # Install basic build tools
  doas apk add alpine-sdk build-base
fi

echo "Detected distribution: $distribution"

echo This is supposed to be a full install script for my dotfiles. It will install chezmoi, neovim, and other necessary packages.
echo Please do note I am still mapping out the necessary packages for this script to work on all distributions.
echo also note that this script is not yet complete and may not work as intended.
echo Installation takes about 20 minutes to complete.

cd
if [ "$distribution" == "alpine" ]; then
  doas echo "Root access granted." || exit 1
else
  sudo echo "Root access granted." || exit 1
fi

# Add GUI installation prompt
read -p "Install GUI packages? (Y/n) " install_gui
install_gui=${install_gui:-Y}
if [[ $install_gui =~ ^[Nn]$ ]]; then
  echo "Skipping GUI package installation"
fi

if [ "$distribution" == "debian" ]; then

  # Check if it's Linux Mint
  if ! grep -q "MINT" /etc/os-release; then
    echo "\n\n\n"
    echo "*****************************************ERROR*****************************************"
    echo "*                                                                                     *"
    echo "*                                                                                     *"
    echo "*                This script now only supports Linux Mint for Debian-based           *"
    echo "*                distributions. Please use Linux Mint 21.3+ or switch to             *"
    echo "*                Arch Linux/Fedora for the best experience.                          *"
    echo "*                                                                                     *"
    echo "*                                                                                     *"
    echo "*****************************************ERROR*****************************************"
    exit 1
  else
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
  fi

  # Add required repos for Mint
  echo "Adding required repositories for Linux Mint..."
  sudo add-apt-repository ppa:nrbrtx/xorg-hotkeys -y
  sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream -y
  
  # Add Hyprland repository
  echo "Adding Hyprland repository..."
  sudo mkdir -p /etc/apt/keyrings
  wget -O- https://pkg.hyprland.dev/key.pgp | sudo tee /etc/apt/keyrings/hyprland.pgp > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/hyprland.pgp] https://pkg.hyprland.dev/debian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hyprland.list > /dev/null
  
  # Update system
  sudo apt update || exit 1
  sudo apt upgrade -y || exit 1
elif [ "$distribution" == "arch" ]; then
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf
  sudo pacman -Syu
  # Install bird if not there.
  if command -v paru &>/dev/null; then
    sudo pacman -S --needed base-devel bat devtools && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si && cd .. && rm -rf paru
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

# install the package
install_a_gui_package librewolf
install_package "curl"
install_package "git"
install_a_gui_package "alacritty"
install_a_gui_package "kitty"
install_a_gui_package "foot"
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
install_a_gui_package "tidal-hifi"
install_package "libssl-dev"
install_package "wayland-scanner++"
install_package "libgles2-mesa-dev"
install_package "fzf"
install_package "htop"
install_a_gui_package "pavucontrol"
install_package "pulseaudio"
install_a_gui_package "element-desktop"
install_package "flatpak"
priv_exec flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
install_package "ripgrep"
install_a_gui_package "dunst"
install_a_gui_package "ark"
install_a_gui_package "brightnessctl"
install_package "unzip"
install_package "wget"
install_package "snapd"
install_package "go"
install_a_gui_package "nautilus"
install_package "fastfetch"
install_a_gui_package "firefox"
install_a_gui_package "epiphany"
install_package "github-cli"
install_a_gui_package "inkscape"
install_a_gui_package "slurp"
install_a_gui_package "wev"
install_a_gui_package "wofi"
install_package "fish"
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
install_package xfce4-clipman-plugin
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
install_a_gui_package "i3-wm"
install_a_gui_package "i3blocks"
install_a_gui_package "i3lock"
install_a_gui_package "i3status"
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
install_package blueman
install_package rofi-greenclip
install_package clipman
install_package zed

# Some fonts
install_package ttf-font-awesome
install_package ttf-lilex-nerd
install_package ttf-iosevka-nerd

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
install_a_gui_package "hyprpaper"
install_a_gui_package "hyprlock"
install_a_gui_package "hyprpolkitagent"
install_a_gui_package "hyprshot"
install_a_gui_package "waybar"
install_a_gui_package "wlogout"

## Anyrun
git clone https://github.com/anyrun-org/anyrun && cd anyrun && cargo build --release && cargo install --path anyrun/ && mkdir -p ~/.config/anyrun/plugins && cp target/release/*.so ~/.config/anyrun/plugins && cp examples/config.ron ~/.config/anyrun/config.ron && cd .. && rm -rf ./anyrun

source ~/.bashrc

# Self-installers
#
# Note: Mise en place gets installed on first launch of either zsh or bash. Mise is slowly taking over most of these installs.
## OMZ
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
priv_exec chsh $(whoami) -s /usr/bin/fish

# Cargo installs

## Cargo binstall
cargo install cargo-binstall


# Flatpak packages
flatpak install chat.revolt.RevoltDesktop -y
flatpak install flathub xyz.armcord.ArmCord -y
flatpak install me.timtimschneeberger.GalaxyBudsClient -y

# Snap packages
if [ "$distribution" == "alpine" ]; then
  echo "Snap is not available on Alpine Linux. Skipping Snap package installation."
else
  sudo systemctl enable snapd.socket
  sudo systemctl start snapd.socket
  sudo ln /var/lib/snapd/snap /snap -ds
  sudo systemctl enable snapd
  sudo snap install discord
  sudo snap install gnome-taquin
fi

# Install chezmoi dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply strawmelonjuice
cp ~/.config/zed/set-settings.json ~/.config/zed/settings.json
nvim --headless '+Lazy! sync' +qa

# Set git up with author
git config --global user.email "mar@strawmelonjuice.com"
git config --global user.name "MLC Bloeiman"

# ready
echo "Installation complete. Please consider restarting your system to apply some changes."
