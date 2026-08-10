#!/usr/bin/env bash

set -euo pipefail

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/pkg.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
print_msg() { echo -e "${GREEN}[*] $1${NC}"; }
print_skip() { echo -e "${BLUE}[=] $1${NC}"; }

# Make sure paru is installed
if ! command -v paru &>/dev/null; then
  echo "Installing Paru"
  "$REPO_ROOT/install/core/paru.sh"
fi

# `neovim`, not `nvim`: the latter is only a provides entry, which leaves the
# choice of provider up to whatever paru resolves first under --noconfirm.
aur_install neovim go python python-pip pyenv npm luarocks ripgrep lua51 lazygit fd

# LazyVim starter is a one-time bootstrap. git clone refuses to write into a
# non-empty directory, so re-running used to abort the whole module with
# "destination path already exists". An existing config is the normal state on
# every run after the first — say so and move on, since the tracked config is
# layered over the starter below anyway.
NVIM_DIR="$HOME/.config/nvim"
if [ -d "$NVIM_DIR" ] && [ -n "$(ls -A "$NVIM_DIR" 2>/dev/null)" ]; then
  print_skip "nvim config already present at $NVIM_DIR, skipping LazyVim starter"
else
  print_msg "bootstrapping LazyVim starter"
  git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_DIR"
  # Drop the upstream history so this config tracks in our repo, not theirs.
  rm -rf "$NVIM_DIR/.git"
fi

# Brain auto-sync systemd units. Takes no arguments; the "config nvim" that
# used to be passed here was copied from update-config.sh's signature and
# silently ignored.
"$REPO_ROOT/scripts/utils/obsidian_git.sh"

"$REPO_ROOT/scripts/utils/update-config.sh" config nvim
