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
install -Dm644 $scripts/../system/mirrorlist /etc/pacman.d/mirrorlist

if $systemupdate; then
  sudo pacman -Syu --noconfirm --needed
fi
