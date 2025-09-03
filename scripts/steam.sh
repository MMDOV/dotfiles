#!/bin/bash
set -e

paru -S --noconfirm --needed steam protontricks protonplus ttf-liberation lib32-pipewire
paru -S --noconfirm --needed xpadneo-dkms triggerhappy

sudo systemctl stop triggerhappy || true
sudo systemctl disable triggerhappy || true

mkdir -p ~/.config/triggerhappy/triggers.d
cat > ~/.config/triggerhappy/triggers.d/xbox.conf <<'EOF'
BTN_MODE 1 sh -c "sleep 0.25; hyprctl dispatch workspace 1"
EOF

cp -f $HOME/personal/local/share/steam.desktop $HOME/.local/share/applications/steam.desktop
