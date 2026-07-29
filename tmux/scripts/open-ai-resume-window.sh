#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
# shellcheck source=ai-utils.sh
source "$DOTFILES_ROOT/tmux/scripts/ai-utils.sh"

project_dir="$(ai_project_dir "$1")"
command="$(printf '%q ' "$DOTFILES_ROOT/tmux/scripts/resume-ai-tab.sh" --picker "$project_dir")"
tmux new-window -c "$project_dir" -n ai-resume "$command"
