#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

THEME_SOURCE_DIR="$REPO_ROOT/themes/konsole"
# -----------------------------------------------------

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

print_msg "Installing Tokyo Night color scheme and profile..."
mkdir -p "$HOME/.local/share/konsole"
cp -f "$THEME_SOURCE_DIR/TokyoNight.colorscheme" "$HOME/.local/share/konsole/TokyoNight.colorscheme"
cp -f "$THEME_SOURCE_DIR/TokyoNight.profile" "$HOME/.local/share/konsole/TokyoNight.profile"

print_msg "Setting TokyoNight as the default profile..."
kwriteconfig6 --file konsolerc --group "Desktop Entry" --key "DefaultProfile" "TokyoNight.profile"

print_msg "Hiding the menu bar..."
kwriteconfig6 --file konsolerc --group "MainWindow" --key "MenuBar" "Disabled"

print_msg "Disabling the close-all-tabs confirmation prompt..."
kwriteconfig6 --file konsolerc --group "Notification Messages" --key "CloseAllTabs" --type bool false

print_msg "Konsole setup complete!"

exit 0
