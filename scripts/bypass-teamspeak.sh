#!/bin/bash

# Define an array of TeamSpeak server IPs
TS_IPS=("45.81.17.138" "5.42.217.174")

# Check for an optional argument to add an extra IP
if [[ -n "$1" ]]; then
  TS_IPS+=("$1")
fi

GATEWAY=$(ip route show table main | grep default | grep -v tun | awk '{print $3}' | head -n 1)
INTERFACE=$(ip route show table main | grep default | grep -v tun | awk '{print $5}' | head -n 1)

if [[ -z "$GATEWAY" ]]; then
  echo "Error: Could not find a local gateway. Are you connected to the internet?"
  exit 1
fi

echo "Detected Mobile/Local Gateway: $GATEWAY (on $INTERFACE)"

# Process each IP in the list
for TS_IP in "${TS_IPS[@]}"; do
  sudo ip route del $TS_IP 2>/dev/null
  sudo ip route add $TS_IP/32 via $GATEWAY dev $INTERFACE
  echo "SUCCESS: Traffic to $TS_IP is now bypassing the VPN."
done
