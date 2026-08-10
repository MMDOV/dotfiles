#!/usr/bin/env bash
# Toggle the secondary display off, or bring it back.
#
# Previously hardcoded to HDMI-A-1, which made it a no-op on any machine whose
# external display sits on a different connector. The secondary is now whatever
# is not the primary, using the same rule as hyprland/roles.lua: the built-in
# panel is primary when present, otherwise the highest refresh rate wins.

set -euo pipefail

monitors_json="$(hyprctl monitors -j)"

# Name of the display to toggle: first non-internal, preferring higher refresh.
secondary="$(printf '%s' "$monitors_json" | jq -r '
  [ .[] | select(.disabled == false) ]
  | (map(select(.name | test("^(eDP|LVDS)"))) | length) as $has_internal
  | if $has_internal > 0
    then map(select((.name | test("^(eDP|LVDS)")) | not))
    else sort_by(-.refreshRate, -(.width * .height)) | .[1:]
    end
  | sort_by(-.refreshRate, -(.width * .height))
  | first // empty
  | .name
')"

if [ -z "$secondary" ]; then
  # Either only one display is attached, or the secondary is already disabled —
  # a disabled monitor drops out of `hyprctl monitors`. Reloading re-applies
  # monitors.lua, which brings it back. This is the "toggle on" half.
  hyprctl reload
  exit 0
fi

hyprctl eval "hl.monitor({ output = \"$secondary\", disabled = true })"
