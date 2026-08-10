#!/usr/bin/env bash

set -euo pipefail

# Self-locating, same as walker.sh. The previous $1-based scripts directory
# was never passed by any caller, so the paru fallback path would have been
# empty had it ever been reached.
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  "$REPO_ROOT/install/core/paru.sh"
fi

paru -S --noconfirm --needed vesktop

# Appended only when absent; the previous unconditional >> added a duplicate
# line on every run.
FLAGS="$HOME/.config/vesktop-flags.conf"
touch "$FLAGS"
if ! grep -qxF -- "--disable-gpu-compositing" "$FLAGS"; then
  echo "--disable-gpu-compositing" >>"$FLAGS"
fi
