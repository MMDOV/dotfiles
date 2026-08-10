#!/usr/bin/env bash

set -euo pipefail

YELLOW='\033[0;33m'
NC='\033[0m'
print_warn() { echo -e "${YELLOW}[!] $1${NC}"; }

# NetworkManager and systemd-networkd both want to own the interfaces. Running
# them together produces intermittent, hard-to-diagnose connectivity loss, so
# say something rather than quietly enabling the second one.
if systemctl is-enabled systemd-networkd.service &>/dev/null; then
  print_warn "systemd-networkd is enabled; running it alongside NetworkManager will fight over interfaces"
  print_warn "  disable it first:  sudo systemctl disable --now systemd-networkd"
fi

sudo pacman -S --noconfirm --needed networkmanager nm-connection-editor network-manager-applet
sudo systemctl enable NetworkManager.service

# Mobile broadband. Harmless with no modem attached, but there is no reason to
# run the daemon on a machine that has never had one.
sudo pacman -S --noconfirm --needed modemmanager usb_modeswitch
sudo systemctl enable ModemManager.service

# `bind` is pulled in for the DNS client tools (dig, nslookup, host) — it
# provides bind-tools/dnsutils. It also ships named.service, which is left
# disabled; nothing here runs a DNS server.
sudo pacman -S --noconfirm --needed ppp bind

sudo pacman -S --noconfirm --needed networkmanager-openvpn networkmanager-openconnect openconnect openvpn
