#!/bin/bash

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Navigate to the brain directory
cd "$REPO_ROOT/brain" || exit 1

# Check for changes (modified, added, deleted)
if [[ -n $(git status --porcelain) ]]; then
    git add .
    git commit -m "Auto-save: $(date '+%Y-%m-%d %H:%M')"
    git push origin main
fi
