#!/usr/bin/env bash

scripts=$2
echo "scripts in install: $scripts"

if ! command -v paru &>/dev/null; then
    chmod +x "$scripts/paru.sh"
    $scripts/paru.sh
fi

paru -S --noconfirm --needed "$1"

chmod +x "$scripts/update-config.sh"
$scripts/update-config.sh config $1
