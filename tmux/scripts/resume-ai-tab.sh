#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

[ "${1:-}" = --picker ] || exit 2
project_dir="$(ai_project_dir "$2")"
picker_window="$(tmux display-message -p '#{window_id}')"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

one_line() {
  printf '%s' "$1" | tr '\t\n\r' ' ' | sed 's/  */ /g' | cut -c1-80
}

add_claude_candidates() {
  local encoded_dir transcript session_id title modified epoch
  encoded_dir="$(printf '%s' "$project_dir" | tr -c 'A-Za-z0-9' '-')"
  [ -d "$HOME/.claude/projects/$encoded_dir" ] || return
  while IFS= read -r -d '' transcript; do
    session_id="$(basename "${transcript%.jsonl}")"
    title="$(jq -r 'select(.type == "ai-title") | .aiTitle // empty' "$transcript" 2>/dev/null | sed -n '1p')" || true
    if [ -z "$title" ]; then
      title="$(jq -r 'select(.type == "user" and .message.role == "user") | .message.content | if type == "string" then . else empty end' "$transcript" 2>/dev/null | sed -n '1p')" || true
    fi
    [ -n "$title" ] || title="claude-${session_id:0:8}"
    epoch="$(stat -c %Y "$transcript")"
    modified="$(date -d "@$epoch" '+%Y-%m-%d %H:%M')"
    printf 'claude\t%s\t%s\t%s\t%s\n' "$session_id" "$(one_line "$title")" "$modified" "$epoch" >> "$tmp"
  done < <(find "$HOME/.claude/projects/$encoded_dir" -maxdepth 1 -type f -name '*.jsonl' -print0 2>/dev/null)
}

add_codex_candidates() {
  local transcript transcript_project session_id title modified epoch
  while IFS= read -r -d '' transcript; do
    transcript_project="$(jq -r 'select(.type == "session_meta") | .payload.cwd // empty' "$transcript" 2>/dev/null | sed -n '1p')" || true
    [ -n "$transcript_project" ] || continue
    [ "$(ai_project_dir "$transcript_project")" = "$project_dir" ] || continue
    session_id="$(jq -r 'select(.type == "session_meta") | .payload.session_id // empty' "$transcript" 2>/dev/null | sed -n '1p')" || true
    [ -n "$session_id" ] || continue
    title="$(ai_codex_title "$transcript")" || true
    [ -n "$title" ] || title="codex-${session_id:0:8}"
    epoch="$(stat -c %Y "$transcript")"
    modified="$(date -d "@$epoch" '+%Y-%m-%d %H:%M')"
    printf 'codex\t%s\t%s\t%s\t%s\n' "$session_id" "$(one_line "$title")" "$modified" "$epoch" >> "$tmp"
  done < <(find "$HOME/.codex/sessions" -type f -name '*.jsonl' -print0 2>/dev/null)
}

add_claude_candidates
add_codex_candidates
[ -s "$tmp" ] || { tmux display-message 'No saved Claude or Codex chats for this project'; exit 0; }

selected="$(sort -t $'\t' -k5,5nr -k1,1 -k2,2 "$tmp" | fzf --no-sort --prompt='Resume AI chat: ' --delimiter=$'\t' --with-nth=1,3,4 --height=100% --reverse)" || exit 0
IFS=$'\t' read -r provider session_id title _ _ <<< "$selected"

current_session="$(tmux display-message -p '#S')"
while IFS= read -r window_id; do
  [ -n "$window_id" ] || continue
  active_provider="$(tmux show-options -t "$window_id" -wv '@ai-provider' 2>/dev/null || true)"
  active_id="$(tmux show-options -t "$window_id" -wv '@ai-session-id' 2>/dev/null || true)"
  if [ "$active_provider" = "$provider" ] && [ "$active_id" = "$session_id" ]; then
    tmux select-window -t "$window_id"
    tmux kill-window -t "$picker_window"
    exit 0
  fi
done < <(tmux list-windows -t "$current_session" -F '#{window_id}')

slug="$(ai_slug "$title")"
[ -n "$slug" ] || slug="${session_id:0:8}"
tmux rename-window -t "$picker_window" "$provider-$slug"
ai_set_window_metadata "$picker_window" "$provider" "$session_id" "$project_dir"
"$DOTFILES_ROOT/tmux/scripts/sync-ai-windows.sh" "$current_session"

"$DOTFILES_ROOT/tmux/scripts/watch-ai-title.sh" \
  "$picker_window" "$provider" "$session_id" "$project_dir" &
case "$provider" in
  claude) exec claude --resume "$session_id" ;;
  codex) exec codex resume "$session_id" ;;
esac
