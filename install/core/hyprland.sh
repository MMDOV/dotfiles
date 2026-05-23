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

paru -S --noconfirm --needed hyprland hyprlock hyprpicker hypridle hyprpaper hyprshutdown
paru -S --noconfirm --needed qt5-wayland qt6-wayland
paru -S --noconfirm --needed xdg-desktop-portal-hyprland xdg-utils xdg-desktop-portal-gtk uwsm
paru -S --noconfirm --needed grim slurp swappy wl-clipboard cliphist
paru -S --noconfirm --needed playerctl easyeffects calf brightnessctl wlogout
paru -S --noconfirm --needed \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  noto-fonts-extra \
  ttf-fira-code \
  ttf-material-symbols-variable-git \
  ttf-dejavu \
  ttf-liberation
paru -S --noconfirm --needed polkit polkit-gnome bicon-git breeze yad
paru -S --noconfirm --needed dbus bc unzip fzf fastfetch curl wget tldr

# update hyprland config
echo "Setting up hyprland config"
chmod +x "$REPO_ROOT/scripts/utils/update-config.sh"
"$REPO_ROOT/scripts/utils/update-config.sh" config hypr
# Enable hyprpaper as a service
systemctl --user enable --now hyprpaper.service

# setup theme
echo "Setting up theme"
chmod +x "$REPO_ROOT/install/desktop/theme.sh"
"$REPO_ROOT/install/desktop/theme.sh"

# setup walker
echo "Setting up walker"
chmod +x "$REPO_ROOT/scripts/helpers/walker.sh"
"$REPO_ROOT/scripts/helpers/walker.sh"

# setup DOTFILES_ROOT env variable
echo setting up .profile
PROFILE="$HOME/.profile"
CUSTOM_CONFIG=$(
  cat <<EOF
export DOTFILES_ROOT=$REPO_ROOT
EOF
)
echo "$CUSTOM_CONFIG" >>"$PROFILE"

# setting up apps
chmod +x "$REPO_ROOT/scripts/utils/install.sh"
"$REPO_ROOT/scripts/utils/install.sh" alacritty
"$REPO_ROOT/scripts/utils/install.sh" waybar
"$REPO_ROOT/scripts/utils/install.sh" mako
"$REPO_ROOT/scripts/utils/install.sh" fuzzel
"$REPO_ROOT/scripts/utils/install.sh" fcitx5
