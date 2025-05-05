#!/usr/bin/env bash

set -e

scripts=$1
# update pacman settings and mirrorlist
chmod +x "$scripts/pacman.sh"
chmod +x "$scripts/reflector.sh"
sudo $scripts/pacman.sh
sudo $scripts/reflector.sh

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
    chmod +x "$scripts/paru.sh"
    $scripts/paru.sh
fi

# install drivers
chmod +x "$scripts/drivers.sh"
$scripts/drivers.sh

# install hyprland and dependencies
paru -S --noconfirm --needed hyprland sddm grim polkit-gnome polkit hypridle dbus qt5-wayland qt6-wayland slurp xdg-desktop-portal-hyprland wl-clipboard noto-fonts swww fcitx5 easyeffects cliphist fzf unzip

# update hyprland config
chmod +x "$scripts/update-config.sh"
$scripts/update-config.sh config hypr

# Update gtk theme and font
$scripts/update-config.sh config gtk-3.0
$scripts/update-config.sh config gtk-4.0
$scripts/update-config.sh config qt5ct
$scripts/update-config.sh config xsettingsd

# setup tmux
chmod +x "$scripts/tmux.sh"
$scripts/tmux.sh

# setup bash
chmod +x "$scripts/bash.sh"
$scripts/bash.sh

# install apps
chmod +x "$scripts/install.sh"
$scripts/install.sh ghostty $scripts
$scripts/install.sh nvim $scripts
$scripts/install.sh walker $scripts
$scripts/install.sh waybar $scripts
$scripts/install.sh yazi $scripts
$scripts/install.sh mako $scriptscliphist

chmod +x "$scripts/spotify.sh"
$scripts/spotify.sh

# Enable SDDM service
sudo systemctl enable sddm

# Verify NetworkManager is enabled
sudo systemctl enable NetworkManager
