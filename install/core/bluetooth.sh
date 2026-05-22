#!/usr/bin/env bash

sudo pacman -S --noconfirm --needed bluez bluez-utils
sudo systemctl enable bluetooth.service
