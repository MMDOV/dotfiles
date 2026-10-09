#!/usr/bin/env bash

set -e

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

GREEN='\033[0;32m'
NC='\033[0m'

if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root. Run it as a regular user."
  exit 1
fi

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  "$REPO_ROOT/install/core/paru.sh"
fi

echo -e "${GREEN}[*] Installing Spotify and spicetify...${NC}"
# spotify-launcher keeps Spotify under ~/.local/share, so spicetify can patch it
# without root.
paru -S --noconfirm --needed spotify-launcher spicetify-bin

# spotify-launcher downloads Spotify on its first launch, and spicetify needs
# the files that launch creates (its docs: log in for at least 60 seconds first). The `look` theme is applied by spicetify-setup,
# which `look apply` runs; it does nothing until Spotify has been started once.
echo -e "${GREEN}[*] Open Spotify and log in for a minute, then run: spicetify-setup${NC}"
