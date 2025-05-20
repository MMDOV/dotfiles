#!/usr/bin/env bash

set -e

if ! command -v spotify &>/dev/null; then
    echo "please install spotify first"
    exit 1
fi

# reinstall spotify
sudo pacman -R spotify --noconfirm
sudo pacman -S spotify --noconfirm

# check permissions
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

# install spotx
bash <(curl -sSL https://spotx-official.github.io/run.sh) -f

# install and apply spicetify
if ! command -v spicetify &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        source "$HOME/.zshrc"
    fi
fi

spicetify update

if [ ! -d "$HOME/.config/spicetify/" ]; then
    cp -rf "$HOME/personal/config/spicetify/" "$HOME/.config/"
    curl -fsSL https://raw.githubusercontent.com/NYRI4/Comfy-spicetify/main/install.sh | sh
    spicetify restore backup
    spicetify config color_scheme catppuccin-mocha
fi

spicetify backup apply
spicetify apply
