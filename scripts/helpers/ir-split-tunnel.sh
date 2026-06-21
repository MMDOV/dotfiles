#!/bin/bash

CUSTOM_IPS=("45.81.17.138" "5.42.217.174" "212.33.201.77")

if [[ -n "$1" ]]; then
  CUSTOM_IPS+=("$1")
fi

GATEWAY=$(ip route show table main | grep default | grep -v tun | awk '{print $3}' | head -n 1)
INTERFACE=$(ip route show table main | grep default | grep -v tun | awk '{print $5}' | head -n 1)

if [[ -z "$GATEWAY" ]]; then
  echo "Error: Could not find a local gateway."
  exit 1
fi

echo "Detected Gateway: $GATEWAY (on $INTERFACE)"
echo "Fetching v2fly/geoip IR CIDR blocks..."

curl -sSfL "https://raw.githubusercontent.com/v2fly/geoip/release/text/ir.txt" | grep "\." >/tmp/ir_cidr.txt || {
  echo "Failed to download CIDR list"
  exit 1
}

>/tmp/route_batch.txt

for IP in "${CUSTOM_IPS[@]}"; do
  if [[ ! "$IP" =~ / ]]; then
    IP="$IP/32"
  fi
  echo "route replace $IP via $GATEWAY dev $INTERFACE onlink" >>/tmp/route_batch.txt
done

while read -r CIDR; do
  [[ -z "$CIDR" ]] && continue
  echo "route replace $CIDR via $GATEWAY dev $INTERFACE onlink" >>/tmp/route_batch.txt
done </tmp/ir_cidr.txt

echo "Applying routes..."
sudo ip -force -batch /tmp/route_batch.txt

rm -f /tmp/ir_cidr.txt /tmp/route_batch.txt
echo "SUCCESS: Custom IPs and Iran IP ranges are bypassing the VPN."
