#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# shellcheck source=/dev/null
source "$REPO_ROOT/lib/pkg.sh"

THEME_SOURCE_DIR="$REPO_ROOT/themes/tokyonight-qt"
# -----------------------------------------------------

print_msg() {
  echo -e "${GREEN}[*] $1${NC}"
}

print_error() {
  echo -e "${RED}[!] $1${NC}"
  exit 1
}

if [ "$EUID" -eq 0 ]; then
  print_error "Do not run this script as root. Run it as a regular user."
fi

if ! command -v paru &>/dev/null; then
  print_error "paru AUR helper is not installed. Please install it first."
fi

print_msg "Installing required packages..."
sudo pacman -S --needed --noconfirm qt5-base qt6-base gtk3 gtk4 papirus-icon-theme ttf-dejavu lxappearance kvantum breeze || print_error "Failed to install packages."

print_msg "Installing Tokyonight GTK theme..."
aur_install tokyonight-gtk-theme-git || print_error "Failed to install Tokyonight GTK theme."

print_msg "Checking for Qt config tools..."
sudo pacman -S --needed --noconfirm qt5ct qt6ct || print_error "Failed to install qtct."

print_msg "Setting up configuration directories..."
mkdir -p $HOME/.config/{gtk-2.0,gtk-3.0,gtk-4.0,qt5ct,qt6ct}
mkdir -p $HOME/.local/share/{themes,icons,fonts,color-schemes}
mkdir -p "$HOME/Pictures/Wallpapers"
mkdir -p $HOME/.config/Kvantum/Tokyonight

# `look` (installed by the dotfiles module on a full install) owns wallpaper and colors.
# Without it (--no-wm --with-theme) the static Tokyonight settings below are all there is.
LOOK="$HOME/.local/bin/look"
LOOK_READY=false
[ -x "$LOOK" ] && [ -f "$HOME/.config/look/targets.toml" ] && LOOK_READY=true

# Seed the wallpaper library (the picker's folder) so a fresh install has one to show.
WALLPAPER_PATH="$HOME/Pictures/Wallpapers/mima-1080.png"
if [ ! -f "$WALLPAPER_PATH" ]; then
  print_msg "Copying fallback wallpaper..."
  cp -f "$REPO_ROOT/assets/wallpapers/mima-1080.png" "$WALLPAPER_PATH" || true
fi

print_msg "Installing Kvantum Theme & KDE Color Scheme..."
# Copy your pre-configured files to the right places
cp -f "$THEME_SOURCE_DIR/Tokyonight.kvconfig" $HOME/.config/Kvantum/Tokyonight/
cp -f "$THEME_SOURCE_DIR/Tokyonight.svg" $HOME/.config/Kvantum/Tokyonight/
cp -f "$THEME_SOURCE_DIR/Tokyonight.colors" $HOME/.local/share/color-schemes/

if ! $LOOK_READY; then
  # Tell Kvantum to use the Tokyonight theme
  cat >$HOME/.config/Kvantum/kvantum.kvconfig <<KVEOF
[General]
theme=Tokyonight
KVEOF

  print_msg "Configuring GTK2..."
  cat >~/.gtkrc-2.0 <<GTKEOF
gtk-theme-name="Tokyonight-Dark"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="Rubik 9"
GTKEOF

  print_msg "Configuring GTK3..."
  cat >~/.config/gtk-3.0/settings.ini <<GTK3EOF
[Settings]
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Rubik 9
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
GTK3EOF

  print_msg "Configuring GTK4..."
  cat >~/.config/gtk-4.0/settings.ini <<GTK4EOF
[Settings]
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Rubik 9
GTK4EOF

  print_msg "Configuring Qt5 (Using Kvantum Engine)..."
  cat >~/.config/qt5ct/qt5ct.conf <<QT5EOF
[Appearance]
custom_palette=true
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum

[Fonts]
fixed="DejaVu LGC Sans,12,-1,5,50,0,0,0,0,0"
general="DejaVu LGC Sans,12,-1,5,50,0,0,0,0,0"
QT5EOF

  print_msg "Configuring Qt6 (Using Kvantum Engine)..."
  cat >~/.config/qt6ct/qt6ct.conf <<QT6EOF
[Appearance]
custom_palette=true
style=kvantum
icon_theme=Papirus-Dark

[Fonts]
fixed="DejaVu LGC Sans,12,-1,5,50,0,0,0,0,0"
general="DejaVu LGC Sans,12,-1,5,50,0,0,0,0,0"
QT6EOF
fi

print_msg "Ensuring fonts are installed..."
if ! fc-list | grep -q "DejaVu LGC Sans"; then
  print_msg "Installing DejaVu LGC Sans font..."
  sudo pacman -S --needed --noconfirm ttf-dejavu || print_error "Failed to install DejaVu font."
fi

print_msg "Refreshing font cache..."
fc-cache -fv >/dev/null || print_error "Failed to refresh font cache."

print_msg "Applying GTK and Dark Mode settings..."
# Run as the invoking user directly. This script refuses to run as root, so
# SUDO_USER was always empty here and every call expanded to `sudo -u ""`,
# which is a usage error. The `|| true` hid it: the settings silently never
# applied while the run reported success.
$LOOK_READY || gsettings set org.gnome.desktop.interface gtk-theme "Tokyonight-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.desktop.interface font-name "Rubik 9"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

if $LOOK_READY; then
  # The dotfiles module ran `look apply` before the base theme above existed, so the
  # GTK/Kvantum targets that recolor it could not render. Render everything now, and
  # set the wallpaper if none was chosen yet.
  print_msg "Applying the look..."
  "$LOOK" apply || print_msg "look apply failed; run it by hand"
  if ! "$LOOK" status 2>/dev/null | grep -q '^wallpaper: .'; then
    "$LOOK" wallpaper "$WALLPAPER_PATH" || true
  fi
fi

print_msg "Theme setup complete! Restart your applications or log out and log back in to apply changes."
print_msg "If themes/icons/fonts don't apply correctly, try running 'lxappearance' or 'qt5ct/qt6ct' manually."

exit 0
