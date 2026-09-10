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

if ! command -v paru &>/dev/null; then
  "$REPO_ROOT/install/core/paru.sh"
fi

paru -S --noconfirm --needed pavucontrol easyeffects pulsemixer

# --- HD Audio codec quirks --------------------------------------------------
# A kernel quirk can map a board's codec pins wrong — a mic that records
# digital silence, a jack that never switches — and nothing in PipeWire can
# route around it. snd-hda-intel's early patching fixes that at boot: it loads
# a firmware file of [codec] sections, and each section only touches the codec
# whose vendor and subsystem IDs it names.
#
# Each file in dotfiles/system/hda-quirks/ is one such section. Only those
# matching a codec present here get combined and installed, so no machine
# picks up another's fix. The paths are the ones alsa-tools' hdajackretask
# writes, so using both never stacks two conflicting patch= options.

QUIRK_DIR="$REPO_ROOT/dotfiles/system/hda-quirks"
QUIRK_FW=/usr/lib/firmware/hda-jack-retask.fw
QUIRK_CONF=/etc/modprobe.d/hda-jack-retask.conf

present_codecs=""
for codec in /sys/class/sound/hwC*D*; do
  [ -r "$codec/vendor_id" ] || continue
  present_codecs+="$(cat "$codec/vendor_id") $(cat "$codec/subsystem_id")"$'\n'
done

quirk_fw_tmp="$(mktemp)"
quirk_conf_tmp="$(mktemp)"
trap 'rm -f "$quirk_fw_tmp" "$quirk_conf_tmp"' EXIT

for quirk in "$QUIRK_DIR"/*.fw; do
  [ -f "$quirk" ] || continue
  ids="$(awk '/^\[codec\]/ { found = 1; next } found && NF && !/^#/ { print $1, $2; exit }' "$quirk")"
  if [ -n "$ids" ] && grep -qxF "$ids" <<<"$present_codecs"; then
    print_msg "hda quirk matches this machine: $(basename "$quirk")"
    cat "$quirk" >>"$quirk_fw_tmp"
  fi
done

# patch= is indexed by controller probe order, and a GPU's HDMI audio can probe
# before the onboard codec, so every controller gets the file. A controller
# whose codecs no section names is left untouched.
controllers=0
for dev in /sys/bus/pci/drivers/snd_hda_intel/0000:*; do
  [ -e "$dev" ] && controllers=$((controllers + 1))
done
[ "$controllers" -ge 1 ] || controllers=1
patch_list="$(printf "${QUIRK_FW##*/},%.0s" $(seq "$controllers"))"
echo "options snd-hda-intel patch=${patch_list%,}" >"$quirk_conf_tmp"

if [ ! -s "$quirk_fw_tmp" ]; then
  print_skip "hda quirks: none match this machine"
elif cmp -s "$quirk_fw_tmp" "$QUIRK_FW" && cmp -s "$quirk_conf_tmp" "$QUIRK_CONF"; then
  print_skip "hda quirks: already current"
else
  print_msg "installing hda quirks (reboot to apply)"
  sudo install -Dm644 "$quirk_fw_tmp" "$QUIRK_FW"
  sudo install -Dm644 "$quirk_conf_tmp" "$QUIRK_CONF"
fi
