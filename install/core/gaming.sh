#!/usr/bin/env bash
# Gaming stack.
#
# Absorbs what used to be scripts/helpers/steam.sh and scripts/helpers/lutris.sh.
# Those were install-time scripts living in a directory of runtime helpers, and
# most of what they installed is now supplied by the CachyOS gaming meta
# packages. What remains here is the part that is genuinely ours.
#
# Two tiers, chosen by whether the CachyOS repos are available:
#   cachy   - cachyos-gaming-meta + cachyos-gaming-applications
#   vanilla - the equivalent library set, assembled by hand
#
# Exactly one process-priority mechanism is ever active. The CachyOS wiki is
# explicit that gamemode and ananicy-cpp must not be combined: both rewrite
# process niceness and fight each other. lutris.sh used to install gamemode
# unconditionally, which would have done exactly that.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/facts.sh"
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/pkg.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'
print_msg() { echo -e "${GREEN}[*] $1${NC}"; }
print_skip() { echo -e "${BLUE}[=] $1${NC}"; }
print_warn() { echo -e "${YELLOW}[!] $1${NC}"; }

pac() { sudo pacman -S --noconfirm --needed "$@"; }
aur() { aur_install "$@"; }

# --- core stack -------------------------------------------------------------

if [ "$FACT_CACHY_REPOS" = true ]; then
  print_msg "gaming stack: cachyos tier"
  # cachyos-settings supplies game-performance plus the sysctl and udev tuning
  # that this script used to write by hand.
  pac cachyos-settings
  # -meta brings the libraries, proton-cachyos-slr, wine-cachyos-opt,
  # umu-launcher, protontricks and winetricks.
  # -applications brings gamescope, MangoHud, goverlay and the launchers
  # (Steam, Lutris, Heroic, Faugus).
  pac cachyos-gaming-meta cachyos-gaming-applications
else
  print_msg "gaming stack: vanilla tier"
  # Transcribed from the cachyos-gaming-meta PKGBUILD, minus the packages that
  # only exist in the CachyOS repos (proton-cachyos-slr, wine-cachyos-opt).
  pac alsa-plugins giflib glfw gst-plugins-base-libs libjpeg-turbo libva \
    libxslt mpg123 openal opencl-icd-loader \
    lib32-alsa-plugins lib32-giflib lib32-gtk3 lib32-libjpeg-turbo \
    lib32-libva lib32-mpg123 lib32-openal lib32-opencl-icd-loader \
    ttf-liberation
  pac steam lutris wine winetricks
  aur protontricks umu-launcher protonup-qt gamescope mangohud lib32-mangohud
fi

# --- extras -----------------------------------------------------------------
# Kept from the old lutris.sh and steam.sh: everything neither meta package
# provides. Dropped as redundant or obsolete: lutris/steam/umu-launcher/
# winetricks/vulkan-tools (in the metas), python-pefile/python-protobuf/gvfs/
# libayatana-appindicator (pulled in as lutris dependencies), protonplus
# (superseded by proton-cachyos-slr), and xorg-xgamma (X11-only, dead here).

print_msg "gaming extras"
pac fluidsynth innoextract lib32-gnutls lib32-libldap lib32-libpulse \
  vkd3d lib32-vkd3d wine-mono wine-gecko lib32-pipewire

# --- process priority: exactly one mechanism --------------------------------

FACTS_REFRESH=1 source "$REPO_ROOT/lib/facts.sh"
wrapper="$(facts_game_wrapper)"

if [ "$wrapper" = "game-performance" ]; then
  print_msg "process priority: ananicy-cpp (wrapper: game-performance)"
  if [ "$FACT_CACHY_REPOS" = true ]; then
    pac ananicy-cpp cachyos-ananicy-rules
  else
    aur ananicy-cpp ananicy-rules-git
  fi
  sudo systemctl enable --now ananicy-cpp.service
  if pacman -Qq gamemode &>/dev/null; then
    print_warn "gamemode is installed but unused; it conflicts with ananicy-cpp"
  fi
else
  # Under the game-performance floor (roughly 6c/12t), or game-performance is
  # unavailable. Use gamemode, and make sure ananicy-cpp is not also running.
  print_msg "process priority: gamemode (wrapper: gamemoderun, $FACT_THREADS threads)"
  pac gamemode lib32-gamemode
  if systemctl is-enabled ananicy-cpp.service &>/dev/null; then
    print_warn "disabling ananicy-cpp: it conflicts with gamemode"
    sudo systemctl disable --now ananicy-cpp.service
  fi
fi

# --- kernel tunables --------------------------------------------------------
# cachyos-settings already ships both of these. Writing our own drop-ins on top
# would shadow theirs, so only do it when it is absent.

if [ "$FACT_HAS_CACHY_SETTINGS" = true ]; then
  print_skip "sysctl/ntsync: provided by cachyos-settings"
else
  print_msg "sysctl: vm.max_map_count"
  echo "vm.max_map_count = 2147483642" |
    sudo tee /etc/sysctl.d/80-gamecompatibility.conf >/dev/null
  print_msg "ntsync: enabling module"
  sudo modprobe ntsync 2>/dev/null || print_warn "ntsync not available in this kernel"
  echo "ntsync" | sudo tee /etc/modules-load.d/ntsync.conf >/dev/null
fi

# --- controller -------------------------------------------------------------
# xpadneo gives proper Xbox controller support over Bluetooth. triggerhappy
# watches the raw input device so the guide button reaches Steam even when
# nothing has focus; scripts/helpers/thd.sh runs it from the Hyprland session,
# so the system-wide unit must stay off to avoid two daemons on one device.

print_msg "controller support"
aur xpadneo-dkms triggerhappy

if systemctl is-enabled triggerhappy.service &>/dev/null; then
  print_msg "disabling system triggerhappy (run per-session instead)"
  sudo systemctl disable --now triggerhappy.service
else
  print_skip "system triggerhappy: already disabled"
fi

mkdir -p "$HOME/.config/triggerhappy/triggers.d"
cat >"$HOME/.config/triggerhappy/triggers.d/xbox.conf" <<'EOF'
BTN_MODE 1 sh -c "uwsm app -- steam -tenfoot"
BTN_MODE 1 sh -c "sleep 0.25; hyprctl dispatch workspace 1"
EOF

# --- desktop entry ----------------------------------------------------------

install -Dm644 "$REPO_ROOT/dotfiles/local/share/steam.desktop" \
  "$HOME/.local/share/applications/steam.desktop"

print_msg "gaming setup complete (launch wrapper: $wrapper)"
