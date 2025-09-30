#!/usr/bin/env bash
set -e

# Ensure dependencies
sudo pacman -S --noconfirm --needed yazi git mediainfo gvfs gvfs-mtp
rm -rf "$HOME/.config/yazi/"*
mkdir -p "$HOME/.config/yazi/plugins"



function add_yazi_pkg() {
    local pkg=$1
    if ! ya pkg list | grep -i "$pkg" > /dev/null; then
        ya pkg add "$pkg"
    else
        echo "Package $pkg already installed. Skipping..."
    fi
}

# Install plugins
add_yazi_pkg boydaihungst/gvfs
add_yazi_pkg boydaihungst/mediainfo
add_yazi_pkg pirafrank/what-size
add_yazi_pkg dedukun/bookmarks

# Upgrade all plugins (no args!)
ya pkg upgrade || true

# Copy configs
cp -rf "$HOME/personal/config/yazi/"*.toml "$HOME/.config/yazi/"
cp -rf "$HOME/personal/config/yazi/"*.lua "$HOME/.config/yazi/"

