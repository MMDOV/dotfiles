#!/usr/bin/env bash
set -euo pipefail

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

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
  *)
    print_error "Unknown argument: $1"
    ;;
  esac
done

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
  local category="$2"
  local path="$REPO_ROOT/install/$category/$name.sh"

  print_msg "Running: $name"
  [[ -f "$path" ]] || print_error "Script not found: $path"

  if $DRY_RUN; then
    print_action "Would chmod +x $path"
    print_action "Would run: $path"
    return
  fi

  chmod +x "$path"
  "$path" || print_error "$name failed"
}

# List of modules with their categories
declare -A modules=(
  ["pacman"]="core"
  ["paru"]="core"
  ["networkmanager"]="core"
  ["pipewire"]="core"
  ["bluetooth"]="core"
  ["drivers"]="core"
  ["base"]="core"
  ["hyprland"]="core"
  ["nvim"]="core"
  ["tmux"]="core"
  ["gaming"]="core"
  ["extras"]="core"
  ["sddm"]="desktop"
  ["theme"]="desktop"
)

# Define execution order
module_order=(
  "pacman"
  "paru"
  "base"
  "networkmanager"
  "pipewire"
  "bluetooth"
  "drivers"
  "hyprland"
  "sddm"
  "theme"
  "nvim"
  "tmux"
  "gaming"
  "extras"
)

# Main loop
for mod in "${module_order[@]}"; do
  if ! should_run "$mod"; then
    print_msg "Skipping: $mod"
    continue
  fi

  run_script "$mod" "${modules[$mod]}"
done

# Post tasks
if $DRY_RUN; then
  print_action "Would enable sddm"
  print_action "Would enable NetworkManager"
  print_action "Would create directory: $HOME/Projects/"
else
  print_msg "Enabling services"
  sudo systemctl enable sddm
  sudo systemctl enable NetworkManager
  mkdir -p "$HOME/Projects/"
fi

print_msg "Done."
