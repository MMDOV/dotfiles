#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

session="$1"
window_id="$2"

tmux kill-window -t "$window_id"
"$DOTFILES_ROOT/tmux/scripts/sync-ai-windows.sh" "$session"
