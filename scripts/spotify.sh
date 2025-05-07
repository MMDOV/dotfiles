#!/usr/bin/env bash

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
    chmod +x $HOME/personal/scripts/paru.sh
    $HOME/personal/scripts/paru.sh
fi

# Make sure curl is installed
sudo pacman -S --noconfirm --needed curl

# install spotify
paru -S --noconfirm --needed spotify

# check permissions
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

# install spotx
bash <(curl -sSL https://spotx-official.github.io/run.sh) -f

# install and apply spicetify
curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
cp -rf "$HOME/personal/.config/spicetify/" "$HOME/.config/"
curl -fsSL https://raw.githubusercontent.com/NYRI4/Comfy-spicetify/main/install.sh | sh
spicetify apply
