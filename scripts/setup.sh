#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_msg() {
    echo -e "${GREEN}[*] $1${NC}"
}

print_error() {
    echo -e "${RED}[!] $1${NC}"
    exit 1
}

scripts=$1
# update pacman settings and mirrorlist
print_msg "updating pacman settings and mirrorlist"
chmod +x "$scripts/pacman.sh"
chmod +x "$scripts/reflector.sh"
sudo $scripts/pacman.sh $scripts
sudo $scripts/reflector.sh $scripts

# Make sure rust is installed
print_msg "Making sure rust is installed"
chmod +x "$scripts/rustup.sh"
$scripts/rustup.sh

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
    print_msg "Installing Paru"
    chmod +x "$scripts/paru.sh"
    $scripts/paru.sh
fi

# setup NetworkManager
print_msg "Setting up NetworkManager"
chmod +x "$scripts/networkmanager.sh"
$scripts/networkmanager.sh

# setup pipewire
print_msg "Setting up pipewire"
chmod +x "$scripts/pipewire.sh"
$scripts/pipewire.sh

# setup bluetooth
print_msg "Setting up bluetooth"
chmod +x "$scripts/bluetooth.sh"
$scripts/bluetooth.sh

# install drivers
print_msg "Installing drivers"
chmod +x "$scripts/drivers.sh"
$scripts/drivers.sh

# install hyprland and dependencies
print_msg "installing hyprland and dependencies"
paru -S --noconfirm --needed hyprland xdg-desktop-portal-hyprland xdg-utils uwsm qt5-wayland qt6-wayland hyprlock hyprpicker hypridle || print_error "Failed to install hyprland"
paru -S --noconfirm --needed grim slurp swappy wl-clipboard cliphist || print_error "Failed"
paru -S --noconfirm --needed playerctl easyeffects brightnessctl || print_error "Failed"
paru -S --noconfirm --needed fuzzel wlogout sddm walker-bin || print_error "Failed"
paru -S --noconfirm --needed noto-fonts ttf-fira-code swww bicon-git breeze || print_error "Failed"
paru -S --noconfirm --needed polkit polkit-gnome dbus fcitx5 bc unzip fzf fastfetch curl wget tldr || print_error "Failed"
paru -S --noconfirm --needed zen-browser-bin firefox thunderbird chatterino2-git telegram-desktop vesktop-bin torguard || print_error "Failed"
paru -S --noconfirm --needed btop espeakup gimp libreoffice-still remmina virt-manager zathura zathura-pdf-mupdf || print_error "Failed"

# setup theme
print_msg "Setting up gtk/qt theme"
chmod +x "$scripts/theme.sh"
$scripts/theme.sh

# setup sddm theme
print_msg "Setting up sddm"
chmod +x "$scripts/sddm.sh"
$scripts/sddm.sh $scripts

# update hyprland config
print_msg "Setting up hyprland config"
chmod +x "$scripts/update-config.sh"
$scripts/update-config.sh config hypr

# setup tmux
print_msg "Setting up tmux"
chmod +x "$scripts/tmux.sh"
$scripts/tmux.sh

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

# Enable SDDM service
sudo systemctl enable sddm

# Verify NetworkManager is enabled
sudo systemctl enable NetworkManager

# setup zsh
chmod +x "$scripts/zshsetup.sh"
$scripts/zshsetup.sh
