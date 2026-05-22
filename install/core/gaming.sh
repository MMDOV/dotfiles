#!/usr/bin/env bash

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

chmod +x "$REPO_ROOT/scripts/helpers/steam.sh"
"$REPO_ROOT/scripts/helpers/steam.sh"

chmod +x "$REPO_ROOT/scripts/helpers/lutris.sh"
"$REPO_ROOT/scripts/helpers/lutris.sh"

echo "vm.max_map_count = 2147483642" | sudo tee /etc/sysctl.d/80-gamecompatibility.conf
