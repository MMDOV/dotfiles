#!/usr/bin/env bash
set -e

sudo pacman -S --needed --noconfirm \
  dolphin \
  kio \
  kio-extras \
  kde-cli-tools \
  xdg-desktop-portal-kde \
  plasma-workspace

echo "Checking XDG menu..."

if [ ! -f /etc/xdg/menus/applications.menu ]; then
  if [ -f /etc/xdg/menus/plasma-applications.menu ]; then
    echo "Creating applications.menu symlink -> plasma-applications.menu"
    sudo ln -sf /etc/xdg/menus/plasma-applications.menu /etc/xdg/menus/applications.menu
  else
    echo "Warning: plasma-applications.menu not found"
  fi
fi

echo "Rebuilding KDE service database..."

rm -f ~/.cache/ksycoca6*
kbuildsycoca6 --noincremental || true

echo "Updating desktop database..."

sudo update-desktop-database /usr/share/applications || true
update-desktop-database ~/.local/share/applications || true

echo "Restarting KDE services..."

killall kded6 2>/dev/null || true
