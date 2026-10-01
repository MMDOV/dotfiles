#!/usr/bin/env bash
# paru (AUR helper).
#
# makepkg uses the distro's stock DLAGENTS (curl). An earlier version of this
# module installed an aria2c DLAGENTS drop-in; it is removed here if present.

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
print_msg() { echo -e "${GREEN}[*] $1${NC}"; }
print_skip() { echo -e "${BLUE}[=] $1${NC}"; }

# --- legacy makepkg drop-in -------------------------------------------------

LEGACY_DROPIN=/etc/makepkg.conf.d/10-dlagents.conf
if [ -f "$LEGACY_DROPIN" ]; then
  print_msg "removing aria2 DLAGENTS drop-in (reverting makepkg to curl)"
  sudo rm -f "$LEGACY_DROPIN"
fi

# --- paru -------------------------------------------------------------------

if command -v paru &>/dev/null; then
  print_skip "paru: already installed"
  exit 0
fi

print_msg "installing paru from the AUR"
sudo pacman -S --noconfirm --needed base-devel bat git

builddir="$(mktemp -d)"
trap 'rm -rf "$builddir"' EXIT
git clone --depth 1 https://aur.archlinux.org/paru.git "$builddir/paru"
(cd "$builddir/paru" && makepkg -si --noconfirm)
