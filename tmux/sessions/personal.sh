#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/personal}"

session="$(tmux display-message -p '#S')"
state_file="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-claude/$session.tsv"
encoded_dir="$(printf '%s' "$(pwd)" | tr -c 'A-Za-z0-9' '-')"
sessions_dir="$HOME/.claude/projects/$encoded_dir"

# snapshot before creating any window below - each new-window call fires the
# global after-new-window hook, which resyncs this same state file and would
# clobber it with an empty result while no claude window has been restored yet
saved_sessions=""
[ -s "$state_file" ] && saved_sessions="$(cat "$state_file")"

tmux new-window -dn scratch

tmux send-keys -t scratch "clear" C-m

restored_any=false
if [ -n "$saved_sessions" ]; then
  while IFS=$'\t' read -r uuid dispname; do
    [ -z "$uuid" ] && continue
    [ -f "$sessions_dir/$uuid.jsonl" ] || continue

    win="${dispname:-claude-${uuid:0:8}}"
    tmux new-window -dn "$win"
    win_id="$(tmux display-message -t "$win" -p '#{window_id}')"
    tmux set-option -t "$win_id" -w "@claude-session-id" "$uuid"
    tmux send-keys -t "$win_id" \
      "$DOTFILES_ROOT/tmux/scripts/watch-ai-title.sh '$win_id' '$uuid' & exec claude --resume $uuid" C-m
    restored_any=true
  done <<<"$saved_sessions"
fi

if $restored_any; then
  "$DOTFILES_ROOT/tmux/scripts/sync-claude-windows.sh" "$session"
fi

clear
vim .
