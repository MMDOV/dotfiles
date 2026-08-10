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

# Third-party theme installer, fetched and run as root. Only done when the
# theme is not already present: re-downloading and re-executing a remote script
# on every run is both wasteful and a standing supply-chain exposure, for no
# benefit once the theme is installed.
if [ -d "$THEME_DIR" ]; then
  echo "SDDM theme already installed, skipping remote installer"
else
  echo "Installing SDDM theme from upstream installer"
  sudo bash <(curl -sSL https://raw.githubusercontent.com/stepanzubkov/where-is-my-sddm-theme/main/install.sh)
fi

# All three destinations are root-owned (/usr/share/sddm, /etc). These used to
# work only because pacman.sh demanded root, forcing the whole setup to run
# under sudo; now that each module elevates only where it needs to, they have
# to ask for it themselves.
if [ ! -f "$WALLPAPER_PATH" ]; then
  echo "Copying wallpaper..."
  sudo install -Dm644 "$REPO_ROOT/assets/wallpapers/mima-1080.png" "$WALLPAPER_PATH"
fi

echo "Writing theme.conf..."
sudo install -Dm644 "$REPO_ROOT/themes/sddm/where_is_my_sddm_theme/theme.conf" "$THEME_CONF"

echo "Configuring SDDM..."
sudo install -Dm644 "$REPO_ROOT/themes/sddm/sddm.conf" "$SDDM_CONF"
