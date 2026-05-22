#!/usr/bin/env bash

set -e

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  print_msg "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi
paru -S --nonfirm --needed libvirt virt-manager qemu-full dnsmasq dmidecode
