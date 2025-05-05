#!/usr/bin/env bash

set -e
scripts=$1

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g. with sudo)"
    exit 1
fi

install -Dm644 $scripts/../system/pacman.conf /etc/pacman.conf
