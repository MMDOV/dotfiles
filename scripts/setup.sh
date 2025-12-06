#!/usr/bin/env bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_msg() {
  echo -e "${GREEN}[*] $1${NC}"
}

print_action() {
  echo -e "${BLUE}[DRY] $1${NC}"
}

print_error() {
  echo -e "${RED}[!] $1${NC}"
  exit 1
}

DRY_RUN=false
skip_list=()
only_list=()

# Determine default scripts directory (same folder as this script)
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
scripts="$BASE_DIR"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run | -n)
    DRY_RUN=true
    shift
    ;;
  --skip)
    IFS=',' read -ra skip_list <<<"$2"
    shift 2
    ;;
  --only)
    IFS=',' read -ra only_list <<<"$2"
    shift 2
    ;;
  --scripts)
    scripts="$2"
    shift 2
    ;;
  *)
    print_error "Unknown argument: $1"
    ;;
  esac
done

[[ -d "$scripts" ]] || print_error "Scripts directory not found: $scripts"

should_run() {
  local mod="$1"

  if [[ ${#only_list[@]} -gt 0 ]]; then
    for o in "${only_list[@]}"; do
      [[ "$o" == "$mod" ]] && return 0
    done
    return 1
  fi

  for s in "${skip_list[@]}"; do
    [[ "$s" == "$mod" ]] && return 1
  done

  return 0
}

run_script() {
  local name="$1"
  shift
  local path="$scripts/$name.sh"

  print_msg "Running: $name"
  [[ -f "$path" ]] || print_error "Script not found: $path"

  if $DRY_RUN; then
    print_action "Would chmod +x $path"
    print_action "Would run: $path $*"
    return
  fi

  chmod +x "$path"
  "$path" "$@" || print_error "$name failed"
}

# List of modules
declare -a modules=(
  "pacman"
  "paru"
  "rustup"
  "networkmanager"
  "pipewire"
  "bluetooth"
  "drivers"
  "hyprland"
  "sddm"
  "browsers"
  "nvim"
  "tmux"
  "yazi"
  "thunar"
  "virt-manager"
  "extras"
  "zshsetup"
)

# Main loop
for mod in "${modules[@]}"; do
  if ! should_run "$mod"; then
    print_msg "Skipping: $mod"
    continue
  fi

  # These two require scripts path
  if [[ "$mod" == "hyprland" || "$mod" == "sddm" ]]; then
    run_script "$mod" "$scripts"
  else
    run_script "$mod"
  fi
done

# Post tasks
if $DRY_RUN; then
  print_action "Would enable sddm"
  print_action "Would enable NetworkManager"
  print_action "Would create directory: $HOME/dev/"
else
  print_msg "Enabling services"
  sudo systemctl enable sddm
  sudo systemctl enable NetworkManager
  mkdir -p "$HOME/dev/"
fi

print_msg "Done."
