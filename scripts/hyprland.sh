#!/usr/bin/env bash

set -e

scripts=$1

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  chmod +x "$scripts/paru.sh"
  $scripts/paru.sh
fi

paru -S --noconfirm --needed hyprland hyprlock hyprpicker hypridle hyprpaper
paru -S --noconfirm --needed qt5-wayland qt6-wayland
paru -S --noconfirm --needed xdg-desktop-portal-hyprland xdg-utils uwsm
paru -S --noconfirm --needed grim slurp swappy wl-clipboard cliphist
paru -S --noconfirm --needed playerctl easyeffects brightnessctl wlogout
paru -S --noconfirm --needed \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  noto-fonts-extra \
  ttf-fira-code \
  ttf-material-symbols-variable-git \
  ttf-dejavu \
  ttf-liberation
paru -S --noconfirm --needed polkit polkit-gnome bicon-git breeze
paru -S --noconfirm --needed dbus bc unzip fzf fastfetch curl wget tldr

# update hyprland config
echo "Setting up hyprland config"
chmod +x "$scripts/update-config.sh"
$scripts/update-config.sh config hypr

# setup theme
echo "Setting up theme"
chmod +x "$scripts/theme.sh"
$scripts/theme.sh

# setup walker
echo "Setting up walker"
chmod +x "$scripts/walker.sh"
$scripts/walker.sh

# setting up apps
chmod +x "$scripts/install.sh"
$scripts/install.sh kitty $scripts
$scripts/install.sh waybar $scripts
$scripts/install.sh mako $scripts
$scripts/install.sh fuzzel $scripts
$scripts/install.sh fcitx5 $scripts
