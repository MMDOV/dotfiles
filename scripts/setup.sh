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
sudo pacman -S --noconfirm --needed reflector
sudo $scripts/pacman.sh $scripts


# Make sure paru is installed
if ! command -v paru &>/dev/null; then
    print_msg "Installing Paru"
    chmod +x "$scripts/paru.sh"
    $scripts/paru.sh
fi

# Install rust
print_msg "removing the pacman version if it exists"
sudo pacman -Rns rust
print_msg "Installing rust with rustup"
chmod +x "$scripts/rustup.sh"
$scripts/rustup.sh

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

# setup hyprland 
print_msg "Setting up hyprland"
chmod +x "$scripts/hyprland.sh"
$scripts/hyprland.sh $scripts 

# setup sddm
print_msg "Setting up sddm"
chmod +x "$scripts/sddm.sh"
$scripts/sddm.sh $scripts

# setup nvim
print_msg "Setting up nvim"
chmod +x "$scripts/nvim.sh"
$scripts/nvim.sh

# setup tmux
print_msg "Setting up tmux"
chmod +x "$scripts/tmux.sh"
$scripts/tmux.sh
mkdir -p $HOME/dev/

# install yazi
print_msg "Installing yazi"
chmod +x "$scripts/yazi.sh"
$scripts/yazi.sh

# Install thunar
print_msg "Installing thunar"
chmod +x "$scripts/thunar.sh"
$scripts/thunar.sh

# install extra apps
paru -S --noconfirm --needed zen-browser-bin firefox thunderbird chatterino2-git telegram-desktop discord teamspeak torguard aria2 yt-dlp
paru -S --noconfirm --needed btop espeakup gimp libreoffice-still remmina freerdp virt-manager zathura zathura-pdf-mupdf mpv

# Enable SDDM service
sudo systemctl enable sddm

# Verify NetworkManager is enabled
sudo systemctl enable NetworkManager

# setup zsh
chmod +x "$scripts/zshsetup.sh"
$scripts/zshsetup.sh
