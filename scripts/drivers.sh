#!/usr/bin/env bash

# Intel UHD Graphics 620 (integrated) - handled by mesa
sudo pacman -S --noconfirm --needed mesa libva-mesa-driver mesa-vdpau

# NVIDIA GeForce GTX 1050 Mobile (discrete)
sudo pacman -S --noconfirm --needed nvidia nvidia-utils libva-nvidia-driver nvidia-prime

# Install CPU microcode
if lscpu | grep -i intel; then
    sudo pacman -S --noconfirm --needed intel-ucode
elif lscpu | grep -i amd; then
    sudo pacman -S --noconfirm --needed amd-ucode
fi
