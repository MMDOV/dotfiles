#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/personal}"

uuid="$(uuidgen)"
window_name="claude-${uuid:0:8}"

tmux new-window -dn "$window_name"
window_id="$(tmux display-message -t "$window_name" -p '#{window_id}')"
session="$(tmux display-message -p '#S')"
tmux set-option -t "$window_id" -w "@claude-session-id" "$uuid"
tmux send-keys -t "$window_id" \
  "$DOTFILES_ROOT/tmux/scripts/watch-ai-title.sh '$window_id' '$uuid' & exec claude --session-id $uuid" C-m
tmux select-window -t "$window_id"

# don't wait for the after-new-window hook - it fires before the option above
# is set, so a reboot before the first ai-title would lose this tab otherwise
"$DOTFILES_ROOT/tmux/scripts/sync-claude-windows.sh" "$session"
