#!/usr/bin/env bash

if ! command -v paru &>/dev/null; then
    sudo pacman -S --noconfirm --needed base-devel
    mkdir -p $HOME/.parupack
    git clone https://aur.archlinux.org/paru.git $HOME/.parupack
    CURRENTDIR=$(pwd)
    cd $HOME/.parupack
    makepkg -si
    cd "$CURRENTDIR"
fi
