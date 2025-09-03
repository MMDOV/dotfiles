#!/usr/bin/env bash

set -e

paru -S --noconfirm --needed steam protontricks protonplus ttf-liberation lib32-pipewire 

# controller setup
paru -S --noconfirm --needed xpadneo-dkms triggerhappy

cat > ~/.config/systemd/user/triggerhappy.service <<'EOF'
[Unit]
Description=Triggerhappy hotkey daemon (user)
After=graphical.target

[Service]
Type=simple
ExecStart=/usr/sbin/thd --triggers ~/.config/triggerhappy/triggers.d/ --deviceglob /dev/input/event*
Restart=on-failure
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

mkdir -p ~/.config/triggerhappy/triggers.d

cat > ~/.config/triggerhappy/triggers.d/xbox.conf <<'EOF'
BTN_MODE 1 hyprctl dispatch workspace 1
EOF

systemctl --user daemon-reload
systemctl --user enable --now triggerhappy


