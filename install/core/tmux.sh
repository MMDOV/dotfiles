#!/usr/bin/env bash

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Install tmux and dependencies
sudo pacman -S --noconfirm --needed tmux git bash bc coreutils jq playerctl

# Copy tmux config
cp -f "$REPO_ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Copy tmux sessionizer to local bin
mkdir -p "$HOME/.local/bin"
cp -f "$REPO_ROOT/tmux/sessionizer" "$HOME/.local/bin/tmux-sessionizer"
chmod +x "$HOME/.local/bin/tmux-sessionizer"

# Install tmux package manager
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
