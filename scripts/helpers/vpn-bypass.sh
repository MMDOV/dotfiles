#!/bin/bash

GROUP="novpn"
MARK=42
TABLE=42

# 1. Get Physical Interface and Gateway
# (Filters out tun/wg interfaces to find the real one)
GATEWAY=$(ip route show table main | grep default | grep -v -E 'tun|wg' | awk '{print $3}' | head -n 1)
INTERFACE=$(ip route show table main | grep default | grep -v -E 'tun|wg' | awk '{print $5}' | head -n 1)

if [[ -z "$GATEWAY" ]]; then
  echo "Error: Physical gateway not found."
  exit 1
fi

echo "Bypassing VPN via $GATEWAY on $INTERFACE"

# 2. Relax Reverse Path Filtering (Crucial)
# If set to 1 (strict), the kernel drops return traffic because it expects
# packets to come from the VPN interface, not the physical one.
sysctl -w net.ipv4.conf.all.rp_filter=2 >/dev/null
sysctl -w net.ipv4.conf.$INTERFACE.rp_filter=2 >/dev/null

# 3. Create the Routing Table
ip route flush table $TABLE
ip route add default via $GATEWAY dev $INTERFACE table $TABLE

# 4. Add the Routing Rule
ip rule del fwmark $MARK table $TABLE 2>/dev/null
ip rule add fwmark $MARK table $TABLE

# 5. Mark packets from the 'novpn' group
iptables -t mangle -D OUTPUT -m owner --gid-owner $GROUP -j MARK --set-mark $MARK 2>/dev/null
iptables -t mangle -A OUTPUT -m owner --gid-owner $GROUP -j MARK --set-mark $MARK

# 6. MASQUERADE (NAT) the marked packets (The Fix)
# This changes the packet source IP from VPN_IP to ISP_IP
iptables -t nat -D POSTROUTING -m mark --mark $MARK -o $INTERFACE -j MASQUERADE 2>/dev/null
iptables -t nat -A POSTROUTING -m mark --mark $MARK -o $INTERFACE -j MASQUERADE

echo "VPN Bypass active for group: $GROUP"
