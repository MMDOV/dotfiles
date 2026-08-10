#!/usr/bin/env bash
# paru (AUR helper) plus our makepkg customisations.
#
# The makepkg config is applied as a drop-in under /etc/makepkg.conf.d/ instead
# of overwriting /etc/makepkg.conf. Overwriting that file discards distro tuning
# — on CachyOS it carries the x86-64-v3/v4 compiler flags that are the entire
# reason to be on those repos — and it happened on every run regardless of
# whether paru was already installed.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'
print_msg() { echo -e "${GREEN}[*] $1${NC}"; }
print_skip() { echo -e "${BLUE}[=] $1${NC}"; }
print_warn() { echo -e "${YELLOW}[!] $1${NC}"; }

# --- makepkg drop-in --------------------------------------------------------

DROPIN_SRC="$REPO_ROOT/dotfiles/system/makepkg.conf.d/10-dlagents.conf"
DROPIN_DEST=/etc/makepkg.conf.d/10-dlagents.conf

if [ ! -d /etc/makepkg.conf.d ]; then
  print_warn "makepkg.conf.d not supported by this pacman; skipping DLAGENTS drop-in"
elif [ -f "$DROPIN_DEST" ] && cmp -s "$DROPIN_SRC" "$DROPIN_DEST"; then
  print_skip "makepkg DLAGENTS drop-in: already current"
else
  print_msg "installing makepkg DLAGENTS drop-in"
  sudo install -Dm644 "$DROPIN_SRC" "$DROPIN_DEST"
fi

# aria2 is what the drop-in actually calls; without it makepkg fails to fetch.
if ! command -v aria2c &>/dev/null; then
  print_msg "installing aria2 (required by the DLAGENTS drop-in)"
  sudo pacman -S --noconfirm --needed aria2
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
