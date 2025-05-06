#!/usr/bin/env bash

sudo pacman -S --noconfirm --needed base-devel
mkdir $HOME/.cache/paru
git clone https://aur.archlinux.org/paru.git $HOME/.cache/paru
CURRENTDIR=$(pwd)
cd $HOME/.cache/paru
makepkg -si
cd "$CURRENTDIR"
