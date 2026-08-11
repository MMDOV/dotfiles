#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_msg() {
  echo -e "${GREEN}[*] $1${NC}"
}

print_error() {
  echo -e "${RED}[!] $1${NC}"
  exit 1
}

if [ "$EUID" -eq 0 ]; then
  print_error "Do not run this script as root. Run it as a regular user."
fi

print_msg "Installing Konsole..."
sudo pacman -S --needed --noconfirm konsole || print_error "Failed to install Konsole."

# The TokyoNight colorscheme/profile live in dotfiles/local/share/konsole
# and are deployed to ~/.local/share/konsole by update-config.sh (dotmmd),
# same as every other tracked config file — run dotmmd if you haven't, or
# this DefaultProfile setting will point at a profile that isn't there yet.

print_msg "Setting TokyoNight as the default profile..."
kwriteconfig6 --file konsolerc --group "Desktop Entry" --key "DefaultProfile" "TokyoNight.profile"

print_msg "Hiding the menu bar..."
kwriteconfig6 --file konsolerc --group "MainWindow" --key "MenuBar" "Disabled"

print_msg "Disabling the close-all-tabs confirmation prompt..."
kwriteconfig6 --file konsolerc --group "Notification Messages" --key "CloseAllTabs" --type bool false

print_msg "Konsole setup complete!"

exit 0
