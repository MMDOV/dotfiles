#!/usr/bin/env bash

tmux new-window -dn scratch
tmux new-window -dn claude

tmux send-keys -t scratch "clear" C-m

tmux send-keys -t claude "claude" C-m
tmux send-keys -t claude "clear" C-m

clear
vim .
