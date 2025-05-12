#!/usr/bin/env bash

# Exit on any error
set -e

scripts=$1

# Variables
THEME_DIR="/usr/share/sddm/themes/sugar-candy"
THEME_CONF="${THEME_DIR}/theme.conf"
SDDM_CONF="/etc/sddm.conf"
WALLPAPER_URL="https://hyprland.org/imgs/blog/contestWinners/corndog.png"
WALLPAPER_PATH="${THEME_DIR}/Backgrounds/corndog.png"

paru -S --noconfirm --needed sddm-sugar-candy-git

sudo mkdir -p "${THEME_DIR}/Backgrounds"

if [ ! -f $WALLPAPER_PATH ]; then
    echo "Downloading wallpaper..."
    sudo wget "${WALLPAPER_URL}" -O "${WALLPAPER_PATH}"
fi

echo "Writing Sugar Candy theme.conf..."
sudo cp -rf $scripts/../sddm/sugar-candy/theme.conf $THEME_CONF

echo "Configuring SDDM to use Sugar Candy theme..."
sudo cp -rf $scripts/../sddm/sddm.conf $SDDM_CONF
