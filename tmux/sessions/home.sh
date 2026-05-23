#!/usr/bin/env bash

tmux new-window -dn projects
tmux new-window -dn cmus

tmux send-keys -t projects "cd Projects" C-m
tmux send-keys -t projects "clear" C-m

tmux send-keys -t cmus "cmus" C-m
clear
fastfetch
