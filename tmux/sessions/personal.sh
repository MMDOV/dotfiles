#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/personal}"

session="$(tmux display-message -p '#S')"

tmux new-window -dn scratch

tmux send-keys -t scratch "clear" C-m

"$DOTFILES_ROOT/tmux/scripts/restore-ai-windows.sh" "$session" "$(pwd)"

clear
vim .
