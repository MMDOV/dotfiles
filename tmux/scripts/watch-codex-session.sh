#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

window_id="$1"
project_dir="$2"
started_at="$3"

for _ in $(seq 1 120); do
  transcript="$(find "$HOME/.codex/sessions" -type f -name '*.jsonl' -newermt "@$started_at" -print 2>/dev/null | while IFS= read -r candidate; do
    candidate_project="$(jq -r 'select(.type == "session_meta") | .payload.cwd // empty' "$candidate" 2>/dev/null | head -n1)"
    [ -n "$candidate_project" ] || continue
    [ "$(ai_project_dir "$candidate_project")" = "$project_dir" ] || continue
    printf '%s\n' "$candidate"
  done | head -n1)"
  if [ -n "$transcript" ]; then
    session_id="$(jq -r 'select(.type == "session_meta") | .payload.session_id // empty' "$transcript" 2>/dev/null | head -n1)"
    if [ -n "$session_id" ]; then
      ai_set_window_metadata "$window_id" codex "$session_id" "$project_dir"
      session="$(tmux display-message -t "$window_id" -p '#S' 2>/dev/null || true)"
      [ -n "$session" ] && "$DOTFILES_ROOT/tmux/scripts/sync-ai-windows.sh" "$session"
      "$DOTFILES_ROOT/tmux/scripts/watch-ai-title.sh" "$window_id" codex "$session_id" "$project_dir" &
      exit 0
    fi
  fi
  sleep 1
done
