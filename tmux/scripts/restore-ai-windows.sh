#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

session="$1"
project_dir="$(ai_project_dir "$2")"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-ai"
state_file="$state_dir/$session.tsv"
legacy_file="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-claude/$session.tsv"
saved_sessions=""

[ -s "$state_file" ] && saved_sessions="$(cat "$state_file")"
if [ -z "$saved_sessions" ] && [ -s "$legacy_file" ]; then
  mkdir -p "$state_dir"
  while IFS=$'\t' read -r session_id window_name; do
    [ -n "$session_id" ] || continue
    printf 'claude\t%s\t%s\t%s\n' "$session_id" "$window_name" "$project_dir"
  done < "$legacy_file" > "${state_file}.import"
  mv "${state_file}.import" "$state_file"
  saved_sessions="$(cat "$state_file")"
fi

restored=false
while IFS=$'\t' read -r provider session_id window_name saved_project; do
  [ -n "$provider" ] && [ -n "$session_id" ] || continue
  [ "$saved_project" = "$project_dir" ] || continue
  case "$provider" in
    claude)
      encoded_dir="$(printf '%s' "$project_dir" | tr -c 'A-Za-z0-9' '-')"
      [ -f "$HOME/.claude/projects/$encoded_dir/$session_id.jsonl" ] || continue
      ;;
    codex)
      transcript="$(ai_codex_transcript "$session_id")"
      [ -n "$transcript" ] || continue
      transcript_project="$(jq -r 'select(.type == "session_meta") | .payload.cwd // empty' "$transcript" 2>/dev/null | sed -n '1p')" || true
      [ -n "$transcript_project" ] && [ "$(ai_project_dir "$transcript_project")" = "$project_dir" ] || continue
      ;;
    *) continue ;;
  esac
  [ -n "$window_name" ] || window_name="$provider-${session_id:0:8}"
  "$DOTFILES_ROOT/tmux/scripts/start-resumed-ai-tab.sh" \
    "$provider" "$session_id" "$project_dir" "$window_name"
  restored=true
done <<< "$saved_sessions"

if $restored; then
  "$DOTFILES_ROOT/tmux/scripts/sync-ai-windows.sh" "$session"
fi
