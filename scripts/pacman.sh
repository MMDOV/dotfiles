#!/usr/bin/env bash

set -e
scripts=$1
systemupdate=true
if [ $# -eq 2 ]; then
    systemupdate=$2
fi

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g. with sudo)"
    exit 1
fi
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm --needed
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm --needed

install -Dm644 $scripts/../system/pacman.conf /etc/pacman.conf

if $systemupdate; then
    sudo pacman -Syu --noconfirm --needed
fi
