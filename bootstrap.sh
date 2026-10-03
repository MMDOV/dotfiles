#!/usr/bin/env bash
# One-line entry point: clone the repo, then hand off to install/setup.sh.
#
#   curl -fsSL https://raw.githubusercontent.com/MMDOV/dotfiles/main/bootstrap.sh | bash -s -- --no-wm
#
# Every argument is passed through to setup.sh, so `--no-wm --with-cachyos`,
# `--dry-run` and the rest work the same here.
#
#   DOTFILES_DIR   where to clone (default: ~/personal)
#   DOTFILES_REPO  what to clone  (default: the HTTPS URL below, so no SSH key
#                  is needed on a fresh machine)
#
# Everything lives in main() and is called on the last line. A script piped
# into bash is read as it executes; without that, a child that reads stdin
# (sudo, update-config.sh's overwrite prompt) would swallow the rest of this
# file instead of the keyboard.

set -euo pipefail

main() {
  local repo_url="${DOTFILES_REPO:-https://github.com/MMDOV/dotfiles.git}"
  local dest="${DOTFILES_DIR:-$HOME/personal}"
  local missing=()

  command -v pacman &>/dev/null || {
    echo "[!] pacman not found: this setup targets Arch and Arch-based distros" >&2
    exit 1
  }
  [ "$EUID" -ne 0 ] || {
    echo "[!] do not run as root; the setup calls sudo where it needs it" >&2
    exit 1
  }

  command -v git &>/dev/null || missing+=(git)
  command -v sudo &>/dev/null || missing+=(sudo)
  pacman -Q base-devel &>/dev/null || missing+=(base-devel)
  if [ ${#missing[@]} -gt 0 ]; then
    echo "[!] missing prerequisites: ${missing[*]}" >&2
    echo "    install them first:  sudo pacman -S --needed ${missing[*]}" >&2
    exit 1
  fi

  if [ -d "$dest/.git" ]; then
    echo "[*] updating $dest"
    git -C "$dest" pull --ff-only
  elif [ -e "$dest" ]; then
    echo "[!] $dest exists and is not a git checkout; set DOTFILES_DIR to another path" >&2
    exit 1
  else
    echo "[*] cloning $repo_url -> $dest"
    git clone "$repo_url" "$dest"
  fi

  exec "$dest/install/setup.sh" "$@"
}

# When piped, stdin is the script itself. Point it at the terminal so prompts
# work; with no terminal at all (CI), leave it alone and let prompts fail loudly.
if [ ! -t 0 ] && { : </dev/tty; } 2>/dev/null; then
  main "$@" </dev/tty
else
  main "$@"
fi
