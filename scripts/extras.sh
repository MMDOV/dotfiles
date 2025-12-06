#!/usr/bin/env bash

set -e

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  print_msg "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi

paru -S --noconfirm --needed thunderbird chatterino2-git telegram-desktop teamspeak torguard aria2
paru -S --noconfirm --needed btop espeakup gimp libreoffice-still remmina freerdp zathura zathura-pdf-mupdf mpv debtap
