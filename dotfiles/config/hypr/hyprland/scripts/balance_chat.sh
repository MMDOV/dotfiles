#!/usr/bin/env bash
# Give TeamSpeak a slim column and Vesktop the rest of workspace 5.
# CHAT_RATIO is TeamSpeak's share of the width (default 0.33).
set -euo pipefail

RATIO="${CHAT_RATIO:-0.33}"
TS='class:^(teamspeak-client|TeamSpeak 3)$'

# Both apps start in the background; wait until both have a window on 5.
for _ in $(seq 60); do
  info="$(hyprctl clients -j | python3 -c '
import json, re, sys
ws = [c for c in json.load(sys.stdin) if c["workspace"]["id"] == 5 and not c["floating"]]
ts = next((c for c in ws if re.match(r"^(teamspeak-client|TeamSpeak 3)$", c["class"])), None)
vk = next((c for c in ws if c["class"] == "vesktop"), None)
if ts and vk:
    gap = vk["at"][0] - (ts["at"][0] + ts["size"][0])
    print(ts["size"][0] + vk["size"][0] + gap, ts["size"][1])
')" && [ -n "$info" ] && break
  sleep 1
done
[ -n "${info:-}" ] || exit 0

read -r total height <<<"$info"
width="$(python3 -c "print(round($total * $RATIO))")"
hyprctl dispatch "hl.dsp.window.resize({ x = $width, y = $height, exact = true, window = \"$TS\" })"
