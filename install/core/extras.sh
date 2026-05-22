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

paru -S --noconfirm --needed thunderbird chatterino2-git telegram-desktop teamspeak torguard aria2
paru -S --noconfirm --needed btop espeakup gimp libreoffice-still remmina freerdp zathura zathura-pdf-mupdf mpv debtap
