#!/bin/bash

# Ping 8.8.8.8 once and extract the latency
PING=$(ping -c 1 8.8.8.8 | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')

if [ -n "$PING" ]; then
    echo "📡 ${PING}ms"
else
    echo "📡 N/A"
fi
