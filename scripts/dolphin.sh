#!/usr/bin/env bash
set -e

echo "Installing Dolphin and dependencies..."

sudo pacman -S --needed --noconfirm \
  dolphin \
  kio \
  kio-admin \
  kio-extras \
  kde-cli-tools \
  xdg-desktop-portal-kde \
  plasma-workspace \
  kvantum \
  qt6ct \
  breeze-icons \
  ffmpegthumbs \
  kdegraphics-thumbnailers \
  ark \
  git

# ---- Fix applications.menu if missing ----

if [ ! -f /etc/xdg/menus/applications.menu ]; then
  if [ -f /etc/xdg/menus/plasma-applications.menu ]; then
    sudo ln -sf /etc/xdg/menus/plasma-applications.menu /etc/xdg/menus/applications.menu
  fi
fi

# ---- Apply Tokyonight Theme Configuration ----

echo "Forcing Dolphin to use Tokyonight Color Scheme..."
# Ensures the config directory exists
mkdir -p ~/.config
# Automatically writes exactly what clicking "Configure -> Window Color Scheme" does
kwriteconfig6 --file dolphinrc --group KDE --key colorScheme "Tokyonight"

echo "Clearing Dolphin cache to force a fresh render..."
rm -rf ~/.cache/dolphin

# ---- Reload KDE background services ----

echo "Reloading KDE services..."
rm -rf ~/.cache/ksycoca6*
kbuildsycoca6 --noincremental || true
killall kded6 2>/dev/null || true

echo "Dolphin installation and theming complete! You can now launch Dolphin."
