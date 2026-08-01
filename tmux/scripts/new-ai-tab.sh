#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

provider="$1"
project_dir="$(ai_project_dir "$PWD")"
session="$(tmux display-message -p '#S')"

case "$provider" in
  claude)
    session_id="$(uuidgen)"
    window_name="claude-${session_id:0:8}"
    window_id="$(tmux new-window -d -P -F '#{window_id}' -c "$project_dir" -n "$window_name")"
    ai_set_window_metadata "$window_id" claude "$session_id" "$project_dir"
    tmux send-keys -t "$window_id" \
      "'$DOTFILES_ROOT/tmux/scripts/watch-ai-title.sh' '$window_id' claude '$session_id' '$project_dir' & exec claude --session-id '$session_id'" C-m
    ;;
  codex)
    started_at="$(date +%s)"
    window_name="codex-new"
    window_id="$(tmux new-window -d -P -F '#{window_id}' -c "$project_dir" -n "$window_name")"
    tmux send-keys -t "$window_id" \
      "'$DOTFILES_ROOT/tmux/scripts/watch-codex-session.sh' '$window_id' '$project_dir' '$started_at' & exec codex" C-m
    ;;
  *)
    exit 2
    ;;
esac

tmux select-window -t "$window_id"
"$DOTFILES_ROOT/tmux/scripts/sync-ai-windows.sh" "$session"
