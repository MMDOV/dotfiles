#!/usr/bin/env bash

session="$1"
[ -z "$session" ] && exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-claude"
mkdir -p "$state_dir" 2>/dev/null
out="$state_dir/$session.tsv"

# a session with zero windows can't exist, so a failure here means the whole
# session (or server) is going away - e.g. window-unlinked fires on the last
# window during a kill-server/reboot, after the session is already gone.
# leave the last-known-good file alone rather than clobbering it with nothing
windows="$(tmux list-windows -t "$session" -F '#{window_id}' 2>/dev/null)" || exit 0

# full resync instead of a diff: window-unlinked fires after the window is
# already gone from list-windows, so closed tabs drop out for free
tmp="$(mktemp 2>/dev/null)" || exit 0
while IFS= read -r window_id; do
  [ -z "$window_id" ] && continue
  uuid="$(tmux show-options -t "$window_id" -wv "@claude-session-id" 2>/dev/null)" || continue
  [ -z "$uuid" ] && continue
  name="$(tmux display-message -t "$window_id" -p '#{window_name}' 2>/dev/null)" || continue
  printf '%s\t%s\n' "$uuid" "$name" >> "$tmp"
done <<< "$windows"

# this is a background sync script - never let a transient failure (e.g. a
# near-full disk) leak its stderr into whatever pane happens to be focused
mv "$tmp" "$out" 2>/dev/null
