#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g. with sudo)"
    exit 1
fi

pacman -S --noconfirm --needed reflector

install -Dm644 ../system/reflector.conf /etc/xdg/reflector/reflector.conf

systemctl enable --now reflector.timer

reflector --config /etc/xdg/reflector/reflector.conf
