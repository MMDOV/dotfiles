#!/usr/bin/env bash

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi
# Intel UHD Graphics 620 (integrated) - handled by mesa
sudo pacman -S --noconfirm --needed mesa libva-mesa-driver mesa-vdpau libva-intel-driver mesa-demos

# NVIDIA GeForce GTX 1050 Mobile (discrete)
paru -S --noconfirm --needed lib32-nvidia-580xx-utils nvidia-580xx-dkms nvidia-580xx-utils nvidia-580xx-settings nvidia-prime

# Install CPU microcode
if lscpu | grep -i intel; then
  sudo pacman -S --noconfirm --needed intel-ucode
elif lscpu | grep -i amd; then
  sudo pacman -S --noconfirm --needed amd-ucode
fi
