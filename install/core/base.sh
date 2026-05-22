#!/usr/bin/env bash

# WARNING: this is not compelete yet DO NOT USE
mnt=$1
if ! mountpoint -q "$mnt"; then
    echo "Error: $mnt is not a mount point. Please mount the root filesystem."
    exit 1
fi
if ! mountpoint -q "$mnt/boot"; then
    echo "Error: $mnt/boot is not mounted. Please mount the ESP."
    exit 1
fi

pacstrap -K $mnt base linux linux-firmware sof-firmware linux-firmware-whence qemu-system-x86-firmware linux-firmware-marvell alsa-firmware vim man-db man-pages texinfo networkmanager --noconfirm --needed
genfstab -U $mnt >>/mnt/etc/fstab
arch-chroot $mnt
ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime
hwclock --systohc
locale-gen
passwd
bootctl install
