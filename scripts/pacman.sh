#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g. with sudo)"
    exit 1
fi

install -Dm644 ../system/pacman.conf /etc/pacman.conf
