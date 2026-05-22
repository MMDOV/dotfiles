#!/usr/bin/env bash

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

debug=false
configonly=false

if [ $# -ge 1 ]; then
  if [ $1 == "--debug" ]; then
    debug=true
  elif [ $1 == "config" ]; then
    configonly=true
    if [ $# -gt 1 ]; then
      subconf=$2
    fi
  fi
fi

copyandreplace() {
  shopt -s dotglob
  for item in "$1"/*; do
    itemname=$(basename "$item")
    destpath="$2"
    mkdir -p "$(dirname "$destpath")"
    if ! $debug; then
      if [ -d "$item" ]; then
        cp -rfvp "$item" "$destpath"
      else
        cp -fvp "$item" "$destpath"
      fi
    else
      echo "copying $item to $destpath"
    fi
  done
}

if [ -z "$subconf" ]; then
  copyandreplace "$REPO_ROOT/dotfiles/config" "$HOME/.config"
  hyprctl reload

else
  mkdir -p "$HOME/.config/$subconf"
  copyandreplace "$REPO_ROOT/dotfiles/config/$subconf" "$HOME/.config/$subconf"
fi

if ! $configonly; then
  copyandreplace "$REPO_ROOT/dotfiles/local/bin" "$HOME/.local/bin"
  copyandreplace "$REPO_ROOT/dotfiles/local/share" "$HOME/.local/share/applications/"
  copyandreplace "$REPO_ROOT/dotfiles/home" "$HOME"
  # Copy tmux sessionizer
  cp -f "$REPO_ROOT/tmux/sessionizer" "$HOME/.local/bin/tmux-sessionizer"
  chmod +x "$HOME/.local/bin/tmux-sessionizer"
fi

hyprctl reload 2>/dev/null || true
