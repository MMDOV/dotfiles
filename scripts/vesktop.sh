#!/usr/bin/env bash

set -e

scripts=$1

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi

paru -S --noconfirm --needed vesktop
echo "--disable-gpu-compositing" >>~/.config/vesktop-flags.conf
