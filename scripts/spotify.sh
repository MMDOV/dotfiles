#!/usr/bin/env bash

# Make sure curl is installed
sudo pacman -S --noconfirm --needed curl

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
cp -rf "$HOME/personal/config/spicetify/" "$HOME/.config/"
curl -fsSL https://raw.githubusercontent.com/NYRI4/Comfy-spicetify/main/install.sh | sh
spicetify backup apply
spicetify config color_scheme catppuccin-mocha
spicetify apply
