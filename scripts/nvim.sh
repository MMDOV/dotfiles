#!/usr/bin/env bash

set -e 

scripts=$1

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
    echo "Installing Paru"
    chmod +x "$scripts/paru.sh"
    $scripts/paru.sh
fi

chmod +x "$scripts/install.sh"
$scripts/install.sh nvim $scripts

paru -S --noconfirm --needed go python python-pip pyenv npm luarocks ripgrep lua51 
