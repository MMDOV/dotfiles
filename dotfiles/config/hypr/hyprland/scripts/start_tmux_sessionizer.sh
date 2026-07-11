#!/usr/bin/env bash

tmux new-session -d \; run-shell "$HOME/.local/bin/tmux-sessionizer $HOME" \; attach
