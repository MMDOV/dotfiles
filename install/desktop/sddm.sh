#!/usr/bin/env bash

# Exit on any error
set -e

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

sudo pacman -S sddm --noconfirm --needed

# Variables
THEME_DIR="/usr/share/sddm/themes/where_is_my_sddm_theme"
THEME_CONF="${THEME_DIR}/theme.conf"
SDDM_CONF="/etc/sddm.conf"
WALLPAPER_PATH="${THEME_DIR}/mima-1080.png"

sudo bash <(curl -sSL https://raw.githubusercontent.com/stepanzubkov/where-is-my-sddm-theme/main/install.sh)

if [ ! -f $WALLPAPER_PATH ]; then
  echo "Copying wallpaper..."
  install -Dm644 "$REPO_ROOT/assets/wallpapers/mima-1080.png" "${WALLPAPER_PATH}"
fi

echo "Writing theme.conf..."
install -Dm644 "$REPO_ROOT/themes/sddm/where_is_my_sddm_theme/theme.conf" "$THEME_CONF"

echo "Configuring SDDM..."
install -Dm644 "$REPO_ROOT/themes/sddm/sddm.conf" "$SDDM_CONF"
