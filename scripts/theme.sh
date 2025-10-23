#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

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
sudo pacman -S --needed --noconfirm qt5-base qt6-base gtk2 gtk3 gtk4 papirus-icon-theme ttf-dejavu lxappearance || print_error "Failed to install packages."

print_msg "Installing Tokyonight GTK theme..."
paru -S --needed --noconfirm tokyonight-gtk-theme-git || print_error "Failed to install Tokyonight GTK theme."

print_msg "Checking for Qt Fusion theme..."
if ! qt5ct &>/dev/null; then
    sudo pacman -S --needed --noconfirm qt5ct || print_error "Failed to install qt5ct."
fi

print_msg "Setting up configuration directories..."
mkdir -p $HOME/.config/{gtk-2.0,gtk-3.0,gtk-4.0,qt5ct,qt6ct}
mkdir -p $HOME/.local/share/{themes,icons,fonts}
mkdir -p $HOME/wallpaper/

WALLPAPER_PATH="$HOME/wallpaper/mima-1080.png"
if [ ! -f $WALLPAPER_PATH ]; then
    print_msg "Changing wallpaper..."
    cp -f $HOME/personal/wallpaper/mima-1080.png $WALLPAPER_PATH
fi

print_msg "Configuring GTK2..."
cat >~/.gtkrc-2.0 <<EOF
gtk-theme-name="Tokyonight-Dark"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="Rubik 9"
EOF

print_msg "Configuring GTK3..."
cat >~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Rubik 9
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
EOF

print_msg "Configuring GTK4..."
cat >~/.config/gtk-4.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Rubik 9
EOF

print_msg "Configuring Qt5..."
cat >~/.config/qt5ct/qt5ct.conf <<EOF
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/darker.conf
custom_palette=true
icon_theme=Papirus-Dark
standard_dialogs=default
style=Fusion

[Fonts]
fixed="DejaVu LGC Sans,12,-1,5,50,0,0,0,0,0"
general="DejaVu LGC Sans,12,-1,5,50,0,0,0,0,0"
EOF

print_msg "Configuring Qt6..."
cat >~/.config/qt6ct/qt6ct.conf <<EOF
[Appearance]
color_scheme_path=/usr/share/qt6ct/colors/darker.conf
custom_palette=true
style=Fusion
icon_theme=Papirus-Dark

[Fonts]
fixed="DejaVu LGC Sans,12,-1,5,50,0,0,0,0,0"
general="DejaVu LGC Sans,12,-1,5,50,0,0,0,0,0"
EOF

print_msg "Ensuring fonts are installed..."
if ! fc-list | grep -q "DejaVu LGC Sans"; then
    print_msg "Installing DejaVu LGC Sans font..."
    sudo pacman -S --needed --noconfirm ttf-dejavu || print_error "Failed to install DejaVu font."
fi

print_msg "Refreshing font cache..."
fc-cache -fv >/dev/null || print_error "Failed to refresh font cache."

print_msg "Applying GTK settings..."
gsettings set org.gnome.desktop.interface gtk-theme "Tokyonight-Dark" || true
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" || true
gsettings set org.gnome.desktop.interface font-name "Rubik 9" || true

print_msg "Theme setup complete! Restart your applications or log out and log back in to apply changes."
print_msg "If themes/icons/fonts don't apply correctly, try running 'lxappearance' to manually set them."

exit 0
