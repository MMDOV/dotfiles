#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/personal}"

window_id="$1"
uuid="$2"

encoded_dir="$(printf '%s' "$(pwd)" | tr -c 'A-Za-z0-9' '-')"
jsonl="$HOME/.claude/projects/$encoded_dir/$uuid.jsonl"

# claude creates the session file lazily, so wait for it before tailing
for _ in $(seq 1 120); do
  [ -f "$jsonl" ] && break
  sleep 1
done
[ -f "$jsonl" ] || exit 0

session="$(tmux display-message -t "$window_id" -p '#S' 2>/dev/null)"

tail -F -n0 "$jsonl" 2>/dev/null | grep --line-buffered '"type":"ai-title"' | while IFS= read -r line; do
  title="$(printf '%s' "$line" | sed -n 's/.*"aiTitle":"\([^"]*\)".*/\1/p')"
  [ -z "$title" ] && continue
  slug="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//;s/-*$//' | cut -c1-40)"
  [ -z "$slug" ] && continue
  tmux rename-window -t "$window_id" "claude-$slug" 2>/dev/null || true
  # no after-rename-window hook anymore, so the state file needs an explicit nudge
  [ -n "$session" ] && "$DOTFILES_ROOT/tmux/scripts/sync-claude-windows.sh" "$session"
done
