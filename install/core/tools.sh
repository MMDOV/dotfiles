#!/usr/bin/env bash
# Apps, fonts and CLI tools that work inside any desktop session.
#
# Runs in every mode, including --no-wm. Everything here used to live in
# hyprland.sh, pipewire.sh or networkmanager.sh, which made the compositor
# module the only way to get fonts and fzf. Nothing in this module defines,
# styles or owns the session, so it never conflicts with whatever DE or WM the
# machine already runs.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/pkg.sh"

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  "$REPO_ROOT/install/core/paru.sh"
fi

# --- fonts ------------------------------------------------------------------

aur_install \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  noto-fonts-extra \
  ttf-fira-code \
  ttf-material-symbols-variable-git \
  ttf-dejavu \
  ttf-liberation
aur_install bicon-git

# --- CLI tools --------------------------------------------------------------

paru -S --noconfirm --needed dbus bc unzip fzf fastfetch curl wget tldr

# `bind` is pulled in for the DNS client tools (dig, nslookup, host) — it
# provides bind-tools/dnsutils. It also ships named.service, which is left
# disabled; nothing here runs a DNS server.
sudo pacman -S --noconfirm --needed bind

# --- audio apps -------------------------------------------------------------
# The audio stack itself (pipewire.sh) belongs to the distro in --no-wm mode;
# these are just apps on top of it.

paru -S --noconfirm --needed easyeffects calf pavucontrol pulsemixer

# --- VPN --------------------------------------------------------------------
# The NetworkManager plugins depend on the networkmanager package, so this
# installs it, but nothing here enables or configures the service.

sudo pacman -S --noconfirm --needed \
  networkmanager-openvpn networkmanager-openconnect openconnect openvpn

# --- input method -----------------------------------------------------------

chmod +x "$REPO_ROOT/scripts/utils/install.sh"
"$REPO_ROOT/scripts/utils/install.sh" fcitx5

# --- DOTFILES_ROOT ----------------------------------------------------------
# Written as a delimited block so re-running replaces it instead of appending a
# duplicate export every time. The old version grew ~/.profile on each run.
echo "setting up .profile"
PROFILE="$HOME/.profile"
BEGIN_MARK="# >>> dotfiles managed >>>"
END_MARK="# <<< dotfiles managed <<<"

touch "$PROFILE"
if grep -qF "$BEGIN_MARK" "$PROFILE"; then
  # Drop the previous block; the new one is appended below.
  sed -i "/^${BEGIN_MARK}\$/,/^${END_MARK}\$/d" "$PROFILE"
fi
{
  echo "$BEGIN_MARK"
  echo "export DOTFILES_ROOT=$REPO_ROOT"
  echo "$END_MARK"
} >>"$PROFILE"
