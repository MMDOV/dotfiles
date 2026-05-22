#!/usr/bin/env bash

set -e

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  chmod +x "$REPO_ROOT/install/core/paru.sh"
  "$REPO_ROOT/install/core/paru.sh"
fi

paru -S --noconfirm --needed nvim go python python-pip pyenv npm luarocks ripgrep lua51 lazygit fd
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

chmod +x "$REPO_ROOT/scripts/utils/sync_brain.sh"
chmod +x "$REPO_ROOT/scripts/utils/obsidian_git.sh"
"$REPO_ROOT/scripts/utils/obsidian_git.sh" config nvim

chmod +x "$REPO_ROOT/scripts/utils/update-config.sh"
"$REPO_ROOT/scripts/utils/update-config.sh" config nvim
