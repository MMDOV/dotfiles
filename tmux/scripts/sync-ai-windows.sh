#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

session="$1"
[ -n "$session" ] || exit 0

# Who called us: parent and grandparent command lines, so a write can be traced.
ai_caller() {
  local pid="$PPID" chain="" i
  for i in 1 2 3; do
    [ -n "$pid" ] && [ "$pid" -gt 1 ] 2>/dev/null || break
    chain="$chain[$pid: $(ps -o args= -p "$pid" 2>/dev/null | cut -c1-160)] "
    pid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')"
  done
  printf '%s' "$chain"
}

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

# Prepend a provenance header (comment lines, ignored by readers) and keep the
# data lines of the file being replaced so an unwanted wipe can be diagnosed.
count="$(wc -l < "$tmp")"
prev_data=""
[ -f "$out" ] && prev_data="$(grep -v '^#' "$out" 2>/dev/null || true)"
now="$(date '+%Y-%m-%d %H:%M:%S')"
caller="$(ai_caller)"
{
  printf '# written: %s\n' "$now"
  printf '# session: %s (%s tracked ai windows of %s windows)\n' "$session" "$count" "$(printf '%s\n' "$windows" | grep -c .)"
  printf '# by: %s\n' "$(basename "$0")"
  printf '# caller: %s\n' "$caller"
  printf '# pane: %s  pid: %s\n' "${TMUX_PANE:-none}" "$$"
  if [ -n "$prev_data" ]; then
    printf '%s\n' "$prev_data" | sed 's/^/# replaced: /'
  else
    printf '# replaced: (nothing)\n'
  fi
  cat "$tmp"
} > "$tmp.out"
rm -f "$tmp"
mv "$tmp.out" "$out" 2>/dev/null
printf '%s session=%s tracked=%s prev_lines=%s caller=%s\n' "$now" "$session" "$count" \
  "$(printf '%s' "$prev_data" | grep -c .)" "$caller" >> "$state_dir/sync.log" 2>/dev/null || true
