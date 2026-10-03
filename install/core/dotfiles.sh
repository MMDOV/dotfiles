#!/usr/bin/env bash
# Deploy tracked configs for --no-wm mode.
#
# Full mode deploys through hyprland.sh, install.sh and the dotmmd alias. In
# no-wm there is no hyprland module, so this is the one step that lays down the
# configs for the terminals, nvim, yazi, fcitx5 and friends, plus the Konsole
# profile that konsole.sh points DefaultProfile at. What is excluded (WM
# configs, and theming unless --with-theme) is defined once in lib/scope.sh.
#
#   dotfiles.sh [--with-theme]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

args=(--no-wm)
for a in "$@"; do
  case "$a" in
  --with-theme) args+=(--with-theme) ;;
  *) echo "unknown argument: $a" >&2 && exit 1 ;;
  esac
done

"$REPO_ROOT/scripts/utils/update-config.sh" "${args[@]}"
