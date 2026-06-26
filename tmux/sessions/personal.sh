#!/usr/bin/env bash

tmux new-window -dn scratch
tmux new-window -dn claude
tmux new-window -dn opencode

tmux send-keys -t scratch "clear" C-m

tmux send-keys -t claude "claude" C-m
tmux send-keys -t claude "clear" C-m

tmux send-keys -t opencode "opencode" C-m
tmux send-keys -t opencode "clear" C-m

clear
vim .
