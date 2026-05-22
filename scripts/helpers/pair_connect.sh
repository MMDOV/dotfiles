#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <MAC-address>"
    exit 1
fi

MAC="$1"

bluetoothctl power on

bluetoothctl info "$MAC" 2>&1 | grep -q "Paired: yes" && {
    echo "Removing old pairing for $MAC..."
    bluetoothctl remove "$MAC"
}

echo "Scanning for device..."
SCAN_OUTPUT=$({
    echo scan on
    sleep 5
    echo scan off
} | bluetoothctl)

echo "$SCAN_OUTPUT" | grep -q "$MAC" || {
    echo "Device $MAC not found during scan. Make sure it's in pairing mode."
    exit 1
}

echo "Pairing with $MAC..."
PAIR_OUTPUT=$(bluetoothctl pair "$MAC" 2>&1 || true)
echo "$PAIR_OUTPUT" | grep -q "Pairing successful" || {
    echo "Failed to pair with $MAC."
    exit 2
}

echo "Trusting and connecting to $MAC..."
bluetoothctl trust "$MAC" >/dev/null
CONN_OUTPUT=$(bluetoothctl connect "$MAC" 2>&1 || true)
echo "$CONN_OUTPUT" | grep -q "Connection successful" && {
    echo "Successfully connected to $MAC."
    exit 0
}

echo "Failed to connect to $MAC."
exit 3
