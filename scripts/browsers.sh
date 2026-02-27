#!/usr/bin/env bash

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  print_msg "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi

paru -S --noconfirm --needed firefox chromium vivaldi-snapshot vivaldi-snapshot-ffmpeg-codecs

install -Dm644 $BASE_DIR/../local/share/chromium.desktop /usr/share/applications/chromium.desktop
cp -f $BASE_DIR/../local/share/youtube-music.desktop $HOME/.local/share/applications/youtube-music.desktop
