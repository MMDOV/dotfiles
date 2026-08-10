#!/usr/bin/env bash

set -euo pipefail

# bluez/bluez-utils are the same packages CachyOS's bluetooth-support
# metapackage depends on, and that metapackage declares no conflicts, so
# installing them directly is safe on either tier.
#
# bluetooth.service carries no Alias, so enabling it is a plain idempotent
# operation with nothing to collide with.
sudo pacman -S --noconfirm --needed bluez bluez-utils
sudo systemctl enable bluetooth.service
