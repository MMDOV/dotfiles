#!/usr/bin/env bash

ai_project_dir() {
  local dir="$1"
  git -C "$dir" rev-parse --show-toplevel 2>/dev/null || (cd "$dir" && pwd -P)
}

ai_slug() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9' '-' \
    | sed 's/^-*//;s/-*$//' \
    | cut -c1-40
}

ai_set_window_metadata() {
  local window_id="$1"
  local provider="$2"
  local session_id="$3"
  local project_dir="$4"

  tmux set-option -t "$window_id" -w "@ai-provider" "$provider"
  tmux set-option -t "$window_id" -w "@ai-session-id" "$session_id"
  tmux set-option -t "$window_id" -w "@ai-project-dir" "$project_dir"
}

ai_codex_transcript() {
  local session_id="$1"
  find "$HOME/.codex/sessions" -type f -name "*-${session_id}.jsonl" -print -quit 2>/dev/null
}

ai_codex_title() {
  local transcript="$1"
  jq -r '
    select(.type == "response_item" and .payload.type == "message" and .payload.role == "user")
    | .payload.content[]?
    | select(.type == "input_text")
    | .text
    | select(startswith("# AGENTS.md instructions for ") | not)
    | select(startswith("<environment_context>") | not)
  ' "$transcript" 2>/dev/null | sed -n '1p'
}
