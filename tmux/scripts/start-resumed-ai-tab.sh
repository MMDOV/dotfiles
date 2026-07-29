#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

provider="$1"
session_id="$2"
project_dir="$3"
window_name="$4"
select_window="${5:-false}"
session="$(tmux display-message -p '#S')"

tmux new-window -d -c "$project_dir" -n "$window_name"
window_id="$(tmux display-message -t "$window_name" -p '#{window_id}')"
ai_set_window_metadata "$window_id" "$provider" "$session_id" "$project_dir"
"$DOTFILES_ROOT/tmux/scripts/sync-ai-windows.sh" "$session"

case "$provider" in
  claude)
    tmux send-keys -t "$window_id" \
      "'$DOTFILES_ROOT/tmux/scripts/watch-ai-title.sh' '$window_id' claude '$session_id' '$project_dir' & exec claude --resume '$session_id'" C-m
    ;;
  codex)
    tmux send-keys -t "$window_id" \
      "'$DOTFILES_ROOT/tmux/scripts/watch-ai-title.sh' '$window_id' codex '$session_id' '$project_dir' & exec codex resume '$session_id'" C-m
    ;;
  *)
    exit 2
    ;;
esac

[ "$select_window" = true ] && tmux select-window -t "$window_id"
