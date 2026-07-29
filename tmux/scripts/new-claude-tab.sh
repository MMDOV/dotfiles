#!/usr/bin/env bash

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
exec "$DOTFILES_ROOT/tmux/scripts/new-ai-tab.sh" claude
