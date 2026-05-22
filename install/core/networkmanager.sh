#!/usr/bin/env bash

sudo pacman -S --noconfirm --needed networkmanager nm-connection-editor network-manager-applet
sudo systemctl enable NetworkManager.service

sudo pacman -S --noconfirm --needed modemmanager usb_modeswitch
sudo systemctl enable ModemManager.service

sudo pacman -S --noconfirm --needed ppp bind

sudo pacman -S --noconfirm --needed networkmanager-openvpn networkmanager-openconnect openconnect openvpn
