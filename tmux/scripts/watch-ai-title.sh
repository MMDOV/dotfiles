#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

window_id="$1"
provider="$2"
session_id="$3"
project_dir="$4"

if [ "$provider" = "claude" ]; then
  encoded_dir="$(printf '%s' "$project_dir" | tr -c 'A-Za-z0-9' '-')"
  transcript="$HOME/.claude/projects/$encoded_dir/$session_id.jsonl"
  for _ in $(seq 1 120); do
    [ -f "$transcript" ] && break
    sleep 1
  done
  [ -f "$transcript" ] || exit 0

  tail -F -n0 "$transcript" 2>/dev/null | grep --line-buffered '"type":"ai-title"' | while IFS= read -r line; do
    title="$(printf '%s' "$line" | sed -n 's/.*"aiTitle":"\([^"]*\)".*/\1/p')"
    slug="$(ai_slug "$title")"
    [ -n "$slug" ] || continue
    tmux rename-window -t "$window_id" "claude-$slug" 2>/dev/null || true
    session="$(tmux display-message -t "$window_id" -p '#S' 2>/dev/null || true)"
    [ -n "$session" ] && "$DOTFILES_ROOT/tmux/scripts/sync-ai-windows.sh" "$session"
  done
  exit 0
fi

transcript="$(ai_codex_transcript "$session_id")"
[ -n "$transcript" ] || exit 0
title=""
for _ in $(seq 1 120); do
  title="$(ai_codex_title "$transcript")"
  [ -n "$title" ] && break
  sleep 1
done
slug="$(ai_slug "$title")"
[ -n "$slug" ] || exit 0
tmux rename-window -t "$window_id" "codex-$slug" 2>/dev/null || true
session="$(tmux display-message -t "$window_id" -p '#S' 2>/dev/null || true)"
[ -n "$session" ] && "$DOTFILES_ROOT/tmux/scripts/sync-ai-windows.sh" "$session"
