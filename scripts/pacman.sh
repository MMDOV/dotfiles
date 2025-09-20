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

install -Dm644 $scripts/../system/pacman.conf /etc/pacman.conf

sudo reflector \
  --protocol https \
  --age 6 \
  --sort rate \
  --latest 10 \
  --save /etc/pacman.d/mirrorlist \
  --threads 5 \
  --country Iran,Germany,

if $systemupdate; then
    sudo pacman -Syu --noconfirm --needed
fi
