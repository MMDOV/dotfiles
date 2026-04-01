#!/usr/bin/env bash
set -e

echo "Installing Dolphin and dependencies..."

sudo pacman -S --needed --noconfirm \
  dolphin \
  kio \
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

# ---- Install Tokyonight Kvantum theme ----

mkdir -p ~/.local/share/Kvantum

if [ ! -d ~/.local/share/Kvantum/Tokyonight ]; then
  git clone https://github.com/Fausto-Korpsvart/Tokyonight-Kvantum.git /tmp/tokyonight-kvantum
  cp -r /tmp/tokyonight-kvantum/Tokyonight ~/.local/share/Kvantum/
fi

# ---- Configure Kvantum ----

mkdir -p ~/.config/Kvantum

cat >~/.config/Kvantum/kvantum.kvconfig <<EOF
[General]
theme=Tokyonight
EOF

# ---- Force Qt apps to use Kvantum ----

mkdir -p ~/.config/environment.d

cat >~/.config/environment.d/qt-theme.conf <<EOF
QT_QPA_PLATFORMTHEME=qt6ct
QT_STYLE_OVERRIDE=kvantum
EOF

# ---- Rebuild KDE caches ----

rm -rf ~/.cache/ksycoca6*
kbuildsycoca6 --noincremental || true
killall kded6 2>/dev/null || true

echo "Done. Log out and back in for Qt theme to fully apply."
