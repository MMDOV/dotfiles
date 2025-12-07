#!/usr/bin/env bash

set -e

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  print_msg "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi

paru -S --noconfirm --needed zen-browser-bin firefox chromium

install -Dm644 $HOME/personal/local/share/chromium.desktop /usr/share/applications/chromium.desktop
