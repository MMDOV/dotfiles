#!/usr/bin/env bash

mnt=$1

pacstrap -K $mnt base linux linux-firmware sof-firmware linux-firmware-whence qemu-system-x86-firmware linux-firmware-marvell alsa-firmware vim man-db man-pages texinfo --noconfirm --needed
genfstab -U $mnt >>/mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime
hwclock --systohc
locale-gen
passwd
bootctl install
