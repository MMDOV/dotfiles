#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'
print_msg() { echo -e "${GREEN}[*] $1${NC}"; }
print_skip() { echo -e "${BLUE}[=] $1${NC}"; }
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

# The mixer and effects apps (pavucontrol, easyeffects, pulsemixer) live in
# tools.sh, which runs in every mode; this module is only the audio stack.
