#!/usr/bin/env bash

set -e

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  chmod +x "$REPO_ROOT/install/core/paru.sh"
  "$REPO_ROOT/install/core/paru.sh"
fi

paru -S --noconfirm --needed thunderbird telegram-desktop teamspeak3 torguard aria2
paru -S --noconfirm --needed btop espeakup gimp libreoffice-still remmina freerdp zathura zathura-pdf-mupdf mpv debtap

# --- AB Download Manager ----------------------------------------------------
# CachyOS ships it in its repo; plain Arch gets the AUR build. The two conflict,
# so only one is ever installed.
if pacman -Si ab-download-manager &>/dev/null; then
  sudo pacman -S --noconfirm --needed ab-download-manager
else
  paru -S --noconfirm --needed ab-download-manager-bin
fi
