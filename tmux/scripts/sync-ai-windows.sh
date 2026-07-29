#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

session="$1"
[ -n "$session" ] || exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-ai"
mkdir -p "$state_dir" 2>/dev/null || exit 0
out="$state_dir/$session.tsv"

windows="$(tmux list-windows -t "$session" -F '#{window_id}' 2>/dev/null)" || exit 0
tmp="$(mktemp)" || exit 0

while IFS= read -r window_id; do
  [ -n "$window_id" ] || continue
  provider="$(tmux show-options -t "$window_id" -wv '@ai-provider' 2>/dev/null || true)"
  session_id="$(tmux show-options -t "$window_id" -wv '@ai-session-id' 2>/dev/null || true)"

  # Adopt tabs created by the old Claude-only scripts on their next sync.
  if [ -z "$provider" ] || [ -z "$session_id" ]; then
    legacy_id="$(tmux show-options -t "$window_id" -wv '@claude-session-id' 2>/dev/null || true)"
    if [ -n "$legacy_id" ]; then
      provider="claude"
      session_id="$legacy_id"
      pane_dir="$(tmux display-message -t "$window_id" -p '#{pane_current_path}' 2>/dev/null || true)"
      project_dir="$(ai_project_dir "${pane_dir:-$PWD}")"
      ai_set_window_metadata "$window_id" "$provider" "$session_id" "$project_dir"
    fi
  fi

  [ -n "$provider" ] && [ -n "$session_id" ] || continue
  project_dir="$(tmux show-options -t "$window_id" -wv '@ai-project-dir' 2>/dev/null || true)"
  if [ -z "$project_dir" ]; then
    pane_dir="$(tmux display-message -t "$window_id" -p '#{pane_current_path}' 2>/dev/null || true)"
    project_dir="$(ai_project_dir "${pane_dir:-$PWD}")"
    tmux set-option -t "$window_id" -w '@ai-project-dir' "$project_dir"
  fi
  name="$(tmux display-message -t "$window_id" -p '#{window_name}' 2>/dev/null || true)"
  [ -n "$name" ] || continue
  printf '%s\t%s\t%s\t%s\n' "$provider" "$session_id" "$name" "$project_dir" >> "$tmp"
done <<< "$windows"

mv "$tmp" "$out" 2>/dev/null
