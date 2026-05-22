#!/usr/bin/env bash

set -e

scripts=$1

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi

paru -S --noconfirm --needed walker-bin elephant-providerlist elephant-desktopapplications

# update walker config
echo "Setting up walker config"
chmod +x "$scripts/update-config.sh"
$scripts/update-config.sh config walker
