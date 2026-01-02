#!/usr/bin/env bash

set -e

scripts=$1

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi

paru -S --noconfirm --needed nvim go python python-pip pyenv npm luarocks ripgrep lua51 lazygit fd
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

chmod +x "$scripts/sync_brain.sh"
chmod +x "$scripts/obsidian_git.sh"
$scripts/obsidian_git.sh config nvim

chmod +x "$scripts/update-config.sh"
$scripts/update-config.sh config nvim
