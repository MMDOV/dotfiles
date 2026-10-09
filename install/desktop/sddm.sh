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
WALLPAPER_PATH="${THEME_DIR}/background"

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
  echo "Copying fallback wallpaper..."
  sudo install -Dm644 "$REPO_ROOT/assets/wallpapers/mima-1080.png" "$WALLPAPER_PATH"
fi

echo "Writing theme.conf..."
sudo install -Dm644 "$REPO_ROOT/themes/sddm/where_is_my_sddm_theme/theme.conf" "$THEME_CONF"

echo "Configuring SDDM..."
sudo install -Dm644 "$REPO_ROOT/themes/sddm/sddm.conf" "$SDDM_CONF"

# The login screen follows the current look: `look` rewrites theme.conf (colors)
# and background (the current wallpaper) here whenever the look changes. Both
# are root-owned, and the greeter cannot read ~/Pictures, so hand the theme
# folder to the user once instead of asking for sudo on every wallpaper change.
echo "Letting the look engine update the login screen..."
sudo chown "$USER": "$THEME_DIR" "$THEME_CONF" "$WALLPAPER_PATH"
if [ -x "$HOME/.local/bin/look" ]; then
  "$HOME/.local/bin/look" --no-reload apply ||
    echo "look apply failed; the login screen keeps the fallback theme until the next look change"
fi
