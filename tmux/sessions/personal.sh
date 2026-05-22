#!/usr/bin/env bash

tmux new-window -dn scratch
tmux new-window -dn gapcode

tmux send-keys -t scratch "clear" C-m

tmux send-keys -t gapcode "gapcode" C-m
tmux send-keys -t gapcode "clear" C-m

clear
vim .
