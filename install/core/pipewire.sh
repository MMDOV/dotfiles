#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

YELLOW='\033[0;33m'
NC='\033[0m'
print_warn() { echo -e "${YELLOW}[!] $1${NC}"; }

# pipewire-pulse and pipewire-jack replace pulseaudio and jack2 rather than
# coexisting with them. Under --noconfirm pacman answers the replacement
# prompt affirmatively and removes them without stopping, so flag it first.
# Any distro that already ships pipewire — CachyOS included — hits none of
# this, since --needed makes the whole block a no-op there.
for conflicting in pulseaudio pulseaudio-alsa jack2; do
  if pacman -Qq "$conflicting" &>/dev/null; then
    print_warn "$conflicting is installed and will be replaced by the pipewire equivalent"
  fi
done

sudo pacman -S --noconfirm --needed \
  pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse wireplumber

if ! command -v paru &>/dev/null; then
  "$REPO_ROOT/install/core/paru.sh"
fi

paru -S --noconfirm --needed pavucontrol easyeffects pulsemixer
