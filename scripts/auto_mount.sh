#!/usr/bin/env bash

USBNAME=$(lsblk -o NAME,TRAN | awk '$2 == "usb" {print $1}')
MOUNTROW=$(lsblk -o NAME,LABEL | grep $USBNAME | awk '{print}' | sed 's/^[├└]─//' | grep '[0-9]' | head -n 1)

if [ -n "$MOUNTROW" ]; then
    MOUNTNAME=$(echo "$MOUNTROW" | awk '{print $1}')
    MOUNT_OUTPUT=$(udisksctl mount -b "/dev/$MOUNTNAME" 2>&1)

    if echo "$MOUNT_OUTPUT" | grep -q "AlreadyMounted"; then
        MOUNTPOINT=$(lsblk -o NAME,MOUNTPOINT | grep "$MOUNTNAME" | awk '{print $2}')
    else
        MOUNTPOINT=$(echo "$MOUNT_OUTPUT" | grep "at" | awk '{print $NF}')
    fi

fi
