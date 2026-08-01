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
  local transcript="$1" prompt
  prompt="$(jq -r '
    select(.type == "response_item" and .payload.type == "message" and .payload.role == "user")
    | .payload.content[]?
    | select(.type == "input_text")
    | .text
    | select(startswith("# AGENTS.md instructions for ") | not)
    | select(startswith("<environment_context>") | not)
  ' "$transcript" 2>/dev/null | sed -n '1p')" || true

  # Codex prompts commonly put files and context first, with the actual task
  # in the final sentence. Keep that stable initial intent as the tab label.
  printf '%s' "$prompt" | tr '\n\r' ' ' | awk '
    {
      gsub(/[[:space:]]+/, " ")
      sub(/^ /, "")
      sub(/ $/, "")
      count = split($0, parts, /[.!?]+[[:space:]]*/)
      for (i = count; i >= 1; i--) {
        candidate = parts[i]
        sub(/^ /, "", candidate)
        sub(/ $/, "", candidate)
        if (length(candidate) > 0) {
          print candidate
          exit
        }
      }
    }
  '
}
