#!/usr/bin/env bash
# What `--no-wm` leaves alone. Source this, then ask scope_skips <name>.
#
#   source "$REPO_ROOT/lib/scope.sh"
#   scope_skips kitty && continue
#
# Two groups of entries under dotfiles/config/ are not deployed in no-wm mode:
#   WM_ONLY_CONFIG  configs for the compositor and its shell. Whatever session
#                   is already running owns this layer.
#   THEME_CONFIG    desktop look and default apps. Every desktop has its own;
#                   deployed only when SCOPE_WITH_THEME=true (--with-theme).
#
# Callers set SCOPE_NO_WM=true to turn the filter on. With it off, nothing is
# skipped, so full mode behaves exactly as before.

WM_ONLY_CONFIG=(
  hypr
  waybar
  look
  rofi
  quickshell
  uwsm
  xsettingsd
  hyprland-xdg-terminals.list
)

THEME_CONFIG=(
  gtk-3.0
  gtk-4.0
  qt5ct
  qt6ct
  kdeglobals
  dolphinrc
  mimeapps.list
)

# Returns 0 (true) when the named entry must NOT be deployed in this mode.
scope_skips() {
  local name="$1" e
  [ "${SCOPE_NO_WM:-false}" = true ] || return 1
  for e in "${WM_ONLY_CONFIG[@]}"; do
    [ "$e" = "$name" ] && return 0
  done
  if [ "${SCOPE_WITH_THEME:-false}" != true ]; then
    for e in "${THEME_CONFIG[@]}"; do
      [ "$e" = "$name" ] && return 0
    done
  fi
  return 1
}
