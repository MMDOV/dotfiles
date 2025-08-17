#!/usr/bin/env bash

scripts=$1

chmod +x "$scripts/steam.sh"
$scripts/steam.sh

chmod +x "$scripts/lutris.sh"
$scripts/lutris.sh

echo "vm.max_map_count = 2147483642" | sudo tee /etc/sysctl.d/80-gamecompatibility.conf
