#!/usr/bin/env bash

# Install tmux and dependencies
sudo pacman -S --noconfirm --needed tmux git bash bc coreutils jq playerctl

# Install tmux package manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Copy tmux config
cp -f $HOME/personal/dev/.tmux.conf $HOME/.tmux.conf
