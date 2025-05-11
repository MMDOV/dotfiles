#!/usr/bin/env bash

USBNAME=$(lsblk -o NAME,TRAN | awk '$2 == "usb" || $2 == "mmc" {print $1}' | grep -v "└─\|├─" | head -n 1)

MOUNTROW=$(lsblk -o NAME,LABEL | grep -E "${USBNAME}p?[0-9]" | grep -v "${USBNAME}$" | sed 's/^[├└]─//' | head -n 1)

if [ -n "$MOUNTROW" ]; then
    MOUNTNAME=$(echo "$MOUNTROW" | awk '{print $1}')

    MOUNT_OUTPUT=$(udisksctl mount -b "/dev/$MOUNTNAME" 2>&1)

    if echo "$MOUNT_OUTPUT" | grep -q "AlreadyMounted"; then
        MOUNTPOINT=$(lsblk -o NAME,MOUNTPOINT | grep "$MOUNTNAME" | awk '{print $2}')
    else
        MOUNTPOINT=$(echo "$MOUNT_OUTPUT" | grep "at" | awk '{print $NF}')
    fi
else
    echo "No mountable partition found for $USBNAME"
    exit 1
fi
