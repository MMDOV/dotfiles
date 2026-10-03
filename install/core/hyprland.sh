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

# shellcheck source=/dev/null
source "$REPO_ROOT/lib/pkg.sh"

paru -S --noconfirm --needed hyprland hyprlock hyprpicker hypridle hyprpaper hyprshutdown hyprshade
paru -S --noconfirm --needed qt5-wayland qt6-wayland
paru -S --noconfirm --needed xdg-desktop-portal-hyprland xdg-utils xdg-desktop-portal-gtk uwsm
paru -S --noconfirm --needed grim slurp swappy wl-clipboard cliphist
paru -S --noconfirm --needed playerctl brightnessctl wlogout

# Hyprbars supplies the compact titlebar used only for floating windows. It is
# an official Hyprland plugin, so hyprpm pins and rebuilds it for the installed
# Hyprland version. Keep each operation conditional: setup.sh is safe to rerun.
HYPRLAND_PLUGINS_REPO="https://github.com/hyprwm/hyprland-plugins"
if ! hyprpm list | grep -q "Repository hyprland-plugins"; then
  hyprpm add "$HYPRLAND_PLUGINS_REPO"
fi
hyprpm update
if ! hyprpm list | grep -A2 "Plugin hyprbars" | grep -q "enabled:.*true"; then
  hyprpm enable hyprbars
fi

# Fonts, CLI tools, the DOTFILES_ROOT profile block, fcitx5 and the audio and
# VPN apps are in tools.sh, which runs before this module in every mode.
aur_install polkit polkit-gnome yad

# update hyprland config
echo "Setting up hyprland config"
chmod +x "$REPO_ROOT/scripts/utils/update-config.sh"
"$REPO_ROOT/scripts/utils/update-config.sh" config hypr
# Enable hyprpaper as a service
systemctl --user enable --now hyprpaper.service
# Enable hyprshade
hyprshade install
systemctl --user enable --now hyprshade.timer

# setup theme
echo "Setting up theme"
chmod +x "$REPO_ROOT/install/desktop/theme.sh"
"$REPO_ROOT/install/desktop/theme.sh"

# setup walker
echo "Setting up walker"
chmod +x "$REPO_ROOT/scripts/helpers/walker.sh"
"$REPO_ROOT/scripts/helpers/walker.sh"

# Machine facts consumed by the Hyprland Lua config (see keybinds.lua).
"$REPO_ROOT/scripts/utils/facts.sh" --write-lua

# setting up apps
chmod +x "$REPO_ROOT/scripts/utils/install.sh"
# waybar-git, not the stable package: Hyprland 0.55 moved its IPC to Lua and
# stable waybar (0.15.0, tagged before that) has no support for it. The config
# in dotfiles/config/waybar depends on it — the workspace scroll handlers
# dispatch Lua, e.g. hyprctl dispatch 'hl.dsp.focus({ workspace = "-1" })'.
# Second argument is the config directory, which stays "waybar".
"$REPO_ROOT/scripts/utils/install.sh" waybar-git waybar
"$REPO_ROOT/scripts/utils/install.sh" mako
"$REPO_ROOT/scripts/utils/install.sh" fuzzel
