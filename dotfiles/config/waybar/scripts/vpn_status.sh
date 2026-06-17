#!/bin/bash

check_ping() {
  local ping_output
  ping_output=$(ping -c 1 -W 1 8.8.8.8 2>/dev/null | grep "time=")

  if [ -z "$ping_output" ]; then
    return 1
  fi

  echo "$ping_output" | awk -F'time=' '{print $2}' | awk '{if ($1 > 0 && $1 < 1) exit 0; else exit 1}'
}

CACHE_FILE="/tmp/vpn_state_cache"

if ip -o link show | awk -F': ' '{print $2}' | grep -qE 'tun[0-9]+' || pgrep -x "hiddify" >/dev/null 2>&1 || ss -tuln | grep -qE ':(8085|8086|8087|1080|12334)\b'; then
  CURRENT_IP=$(ip route get 8.8.8.8 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')

  CACHE_VALID=0
  if [ -s "$CACHE_FILE" ]; then
    CACHED_IP=$(awk '{print $1}' "$CACHE_FILE")
    if [ "$CACHED_IP" = "$CURRENT_IP" ]; then
      COUNTRY=$(awk '{print $2}' "$CACHE_FILE")
      CACHE_VALID=1
    fi
  fi

  if [ "$CACHE_VALID" -eq 0 ]; then
    COUNTRY=$(curl -s --max-time 2 ipinfo.io/country)
    if [ -n "$COUNTRY" ]; then
      echo "$CURRENT_IP $COUNTRY" >"$CACHE_FILE"
    else
      COUNTRY="VPN"
    fi
  fi
  printf '{"text": "%s", "class": "connected", "tooltip": "Connected: %s"}\n' "$COUNTRY" "$COUNTRY"
else
  rm -f "$CACHE_FILE" 2>/dev/null
  printf '{"text": "", "class": "disconnected", "tooltip": "Disconnected"}\n'
fi
