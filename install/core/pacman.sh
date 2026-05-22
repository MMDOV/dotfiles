#!/usr/bin/env bash

set -e

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

systemupdate=true
if [ $# -eq 1 ]; then
  systemupdate=$1
fi

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g. with sudo)"
  exit 1
fi

install -Dm644 "$REPO_ROOT/dotfiles/system/pacman.conf" /etc/pacman.conf
sudo pacman -S --noconfirm --needed reflector

sudo reflector \
  --protocol https \
  --age 5 \
  --delay 0.25 \
  --sort rate \
  --fastest 10 \
  --save /etc/pacman.d/mirrorlist \
  --threads 5

if $systemupdate; then
  sudo pacman -Syu --noconfirm --needed
fi
