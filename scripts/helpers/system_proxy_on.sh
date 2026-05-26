#!/bin/bash

GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}')
INTERFACE_NAME=$(ip route show default | awk '/default/ {print $5}')

if [[ $# -eq 1 ]]; then
  PROXYPORT=$1
else
  PROXYPORT=10808
fi

EXCLUDED_IPS=("104.19.229.21" "212.33.201.77")

sudo ip tuntap add mode tun dev tun0
sudo ip addr add 198.18.0.1/15 dev tun0
sudo ip link set dev tun0 up

for IP in "${EXCLUDED_IPS[@]}"; do
  sudo ip route add $IP via $GATEWAY_IP dev $INTERFACE_NAME
done
sudo ip route add default dev tun0 metric 1

sudo tun2socks -tunName tun0 -proxyType socks -proxyServer 127.0.0.1:$PROXYPORT
