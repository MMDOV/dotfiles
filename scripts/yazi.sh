#!/usr/bin/env bash

set -e

sudo pacman -S --noconfirm --needed yazi git mediainfo

function add_yazi_pkg() {
    local pkg=$1
    if ! ya pkg list | grep -i "$pkg"; then
        ya pkg add "$pkg"
    else
        echo "Package $pkg already installed. Skipping..."
    fi
}

add_yazi_pkg boydaihungst/mediainfo
add_yazi_pkg Reledia/miller
add_yazi_pkg pirafrank/what-size
add_yazi_pkg yazi-rs/plugins:mount
add_yazi_pkg dedukun/bookmarks

cp -rfvp $HOME/personal/config/yazi/* $HOME/.config/yazi/

