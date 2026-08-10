#!/usr/bin/env bash

set -e

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  "$REPO_ROOT/install/core/paru.sh"
fi

paru -S --noconfirm --needed libvirt virt-manager qemu-full dnsmasq dmidecode
