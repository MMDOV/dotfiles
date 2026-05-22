#!/usr/bin/env bash

sudo pacman -S --noconfirm --needed nemo nemo-fileroller \
  gvfs gvfs-mtp ffmpegthumbnailer

xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

gsettings set org.nemo.desktop show-desktop-icons false
