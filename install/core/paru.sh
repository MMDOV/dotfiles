#!/usr/bin/env bash

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if ! command -v paru &>/dev/null; then
  install -Dm644 "$REPO_ROOT/dotfiles/system/makepkg.conf" /etc/makepkg.conf
  sudo pacman -S --noconfirm --needed base-devel bat aria2
  mkdir -p "$HOME/.parupack"
  git clone https://aur.archlinux.org/paru.git "$HOME/.parupack"
  CURRENTDIR=$(pwd)
  cd "$HOME/.parupack"
  makepkg -si
  cd "$CURRENTDIR"
fi
