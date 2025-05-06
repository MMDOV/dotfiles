#!/usr/bin/env bash

# Install tmux and dependencies
sudo pacman -S --noconfirm --needed tmux git bash bc coreutils jq playerctl

# Copy tmux config
cp -f $HOME/personal/home/.tmux.conf $HOME/.tmux.conf
cp -rf $HOME/personal/.tmux/ $HOME/.tmux/plugins/

# Install tmux package manager
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
