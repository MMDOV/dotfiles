#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/personal}"

session="$1"
window_id="$2"

tmux kill-window -t "$window_id"
"$DOTFILES_ROOT/tmux/scripts/sync-claude-windows.sh" "$session"
