#!/bin/bash

IFACE="${1:-tun0}"

check_ping() {
  local ping_output
  ping_output=$(ping -c 1 -W 1 8.8.8.8 2>/dev/null | grep "time=")

  if [ -z "$ping_output" ]; then
    return 1
  fi

  echo "$ping_output" | awk -F'time=' '{print $2}' | awk '{if ($1 > 0 && $1 < 1) exit 0; else exit 1}'
}

if ip link show "$IFACE" >/dev/null 2>&1 || check_ping; then
  printf '{"text": "", "class": "connected", "tooltip": "Connected"}\n'
else
  printf '{"text": "", "class": "disconnected", "tooltip": "Disconnected"}\n'
fi
