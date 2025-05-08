#!/usr/bin/env bash

set -e

scripts=$1
# update pacman settings and mirrorlist
chmod +x "$scripts/pacman.sh"
chmod +x "$scripts/reflector.sh"
sudo $scripts/pacman.sh $scripts
sudo $scripts/reflector.sh $scripts

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
    chmod +x "$scripts/paru.sh"
    $scripts/paru.sh
fi

# setup NetworkManager
chmod +x "$scripts/networkmanager.sh"
$scripts/networkmanager.sh

# setup pipewire
chmod +x "$scripts/pipewire.sh"
$scripts/pipewire.sh

# setup bluetooth
chmod +x "$scripts/bluetooth.sh"
$scripts/bluetooth.sh

# install drivers
chmod +x "$scripts/drivers.sh"
$scripts/drivers.sh

# install hyprland and dependencies
paru -S --noconfirm --needed hyprland xdg-desktop-portal-hyprland xdg-utils uwsm qt5-wayland qt6-wayland hyprlock hyprpicker hypridle walker-bin
paru -S --noconfirm --needed grim slurp swappy wl-clipboard cliphist
paru -S --noconfirm --needed playerctl easyeffects brightnessctl
paru -S --noconfirm --needed fuzzel wlogout sddm which
paru -S --noconfirm --needed noto-fonts ttf-fira-code tokyonight-gtk-theme-git swww bicon-git breeze
paru -S --noconfirm --needed polkit polkit-gnome dbus fcitx5 bc unzip fzf fastfetch
paru -S --noconfirm --needed zen-browser-bin vesktop-bin thunderbird btop chatterino2-git espeakup gimp libreoffice-still remmina telegram-desktop tldr virt-manager zathura zathura-pdf-mupdf

# setup sdddm theme
chmod +x "$scripts/sddm.sh"
$scripts/sddm.sh $scripts

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
chmod +x "$scripts/bashsetup.sh"
$scripts/bashsetup.sh

# install apps
chmod +x "$scripts/install.sh"
$scripts/install.sh ghostty $scripts
$scripts/install.sh nvim $scripts
$scripts/install.sh waybar $scripts
$scripts/install.sh yazi $scripts
$scripts/install.sh mako $scripts

# setup walker config
chmod +x "$scripts/update-config.sh"
$scripts/update-config.sh config walker

#sudo systemctl restart sddm Enable SDDM service
sudo systemctl enable sddm

# Verify NetworkManager is enabled
sudo systemctl enable NetworkManager
