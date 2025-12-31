#!/bin/bash

IFACE="${1:-tun0}"

if ip link show "$IFACE" >/dev/null 2>&1; then
  printf '{"text": "", "class": "connected", "tooltip": "Connected: %s"}\n' "$IFACE"
else
  printf '{"text": "", "class": "disconnected", "tooltip": "Disconnected"}\n'
fi
