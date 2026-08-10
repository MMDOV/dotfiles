#!/usr/bin/env bash

set -euo pipefail

# Self-locating, matching every other script in the repo. This used to read a
# scripts directory from $1, but its only caller (install/core/hyprland.sh)
# invokes it with no arguments — so the variable was empty and the paths
# collapsed to "/update-config.sh", failing under set -e and taking the whole
# hyprland module down with it.
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  "$REPO_ROOT/install/core/paru.sh"
fi

paru -S --noconfirm --needed walker-bin elephant-providerlist elephant-desktopapplications

# update walker config
echo "Setting up walker config"
"$REPO_ROOT/scripts/utils/update-config.sh" config walker
