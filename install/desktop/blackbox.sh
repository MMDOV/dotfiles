#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

THEME_SOURCE_DIR="$REPO_ROOT/themes/blackbox"
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

if ! command -v paru &>/dev/null; then
  print_error "paru AUR helper is not installed. Please install it first."
fi

print_msg "Installing BlackBox terminal..."
paru -S --needed --noconfirm blackbox-terminal || print_error "Failed to install BlackBox terminal."

print_msg "Installing Tokyo Night color scheme..."
mkdir -p "$HOME/.local/share/blackbox/schemes"
cp -f "$THEME_SOURCE_DIR/tokyo-night.json" "$HOME/.local/share/blackbox/schemes/tokyo-night.json"

print_msg "Applying BlackBox settings..."
gsettings set com.raggesilver.BlackBox theme-dark 'Tokyo Night'
gsettings set com.raggesilver.BlackBox font 'JetBrains Mono 11'
gsettings set com.raggesilver.BlackBox terminal-padding "(uint32 5, uint32 5, uint32 5, uint32 5)"
gsettings set com.raggesilver.BlackBox opacity uint32 97
gsettings set com.raggesilver.BlackBox floating-controls true
gsettings set com.raggesilver.BlackBox headerbar-drag-area false
gsettings set com.raggesilver.BlackBox show-headerbar false

print_msg "BlackBox setup complete!"

exit 0
