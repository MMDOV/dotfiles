#!/bin/bash

GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}')
INTERFACE_NAME=$(ip route show default | awk '/default/ {print $5}')
EXCLUDED_IPS=("172.67.139.236" "212.33.201.77")

sudo ip route del default dev tun0 metric 1

for IP in "${EXCLUDED_IPS[@]}"; do
  sudo ip route del $IP via $GATEWAY_IP dev $INTERFACE_NAME
done

sudo ip link delete dev tun0
