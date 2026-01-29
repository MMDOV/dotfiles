#!/bin/bash

IFACE="${1:-tun0}"

check_ping() {
  ping -c 1 -W 1 8.8.8.8 | grep "time=" | awk -F'time=' '{print $2}' | awk '$1 < 1 {exit 0} {exit 1}'
}

if ip link show "$IFACE" >/dev/null 2>&1 || check_ping; then
  printf '{"text": "", "class": "connected", "tooltip": "Connected"}\n'
else
  printf '{"text": "", "class": "disconnected", "tooltip": "Disconnected"}\n'
fi
