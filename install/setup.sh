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
WITH_CACHYOS=false
skip_list=()
only_list=()
declare -a ran_list=()
declare -a skipped_list=()

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run | -n)
    DRY_RUN=true
    shift
    ;;
  --with-cachyos)
    WITH_CACHYOS=true
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

# What this machine is, before anything acts on it. Auto-detection is only
# trustworthy if it says what it decided — the failure mode worth guarding
# against is silently landing on a degraded tier and never noticing.
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/facts.sh"
facts_report
echo

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
  shift 2

  print_msg "Running: $name"
  [[ -f "$path" ]] || print_error "Script not found: $path"

  if $DRY_RUN; then
    print_action "Would chmod +x $path"
    print_action "Would run: $path $*"
    ran_list+=("$name")
    return
  fi

  chmod +x "$path"
  "$path" "$@" || print_error "$name failed"
  ran_list+=("$name")
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
  ["env"]="core"
  ["hyprland"]="core"
  ["nvim"]="core"
  ["tmux"]="core"
  ["gaming"]="core"
  ["extras"]="core"
  ["sddm"]="desktop"
  ["theme"]="desktop"
  ["blackbox"]="desktop"
)

# Execution order.
#
# `base` is deliberately absent: it is the from-ISO pacstrap step, takes a
# mountpoint argument, and exited 1 without one — which aborted the entire run
# at the third module. It is still reachable with `--only base`.
module_order=(
  "pacman"
  "paru"
  "networkmanager"
  "pipewire"
  "bluetooth"
  "drivers"
  "env"
  "hyprland"
  "sddm"
  "theme"
  "blackbox"
  "nvim"
  "tmux"
  "gaming"
  "extras"
)

# Main loop
for mod in "${module_order[@]}"; do
  if ! should_run "$mod"; then
    print_msg "Skipping: $mod"
    skipped_list+=("$mod")
    continue
  fi

  case "$mod" in
  pacman)
    if $WITH_CACHYOS; then
      run_script "$mod" "${modules[$mod]}" --with-cachyos
    else
      run_script "$mod" "${modules[$mod]}"
    fi
    ;;
  *)
    run_script "$mod" "${modules[$mod]}"
    ;;
  esac
done

# Post tasks
if $DRY_RUN; then
  print_action "Would enable sddm"
  print_action "Would enable NetworkManager"
  print_action "Would create directory: $HOME/Projects/"
else
  print_msg "Enabling services"

  # sddm.service carries Alias=display-manager.service, so enabling it creates
  # /etc/systemd/system/display-manager.service. If another display manager
  # already owns that symlink — which is the normal state on any distro
  # installed with a desktop, CachyOS included — systemctl refuses with
  # "File exists" and, under set -e, kills the run at the final step after
  # everything else succeeded. Take over the symlink deliberately instead.
  current_dm=""
  if [ -L /etc/systemd/system/display-manager.service ]; then
    current_dm="$(basename "$(readlink -f /etc/systemd/system/display-manager.service)")"
  fi
  if [ -z "$current_dm" ]; then
    sudo systemctl enable sddm
  elif [ "$current_dm" = "sddm.service" ]; then
    print_msg "sddm already the display manager"
  else
    print_msg "Replacing display manager: $current_dm -> sddm.service"
    sudo systemctl disable display-manager.service
    sudo systemctl enable sddm
  fi

  sudo systemctl enable NetworkManager
  mkdir -p "$HOME/Projects/"
fi

# Summary. Says what tier this run landed on and which choices followed from
# it, so a degraded result is visible rather than something you discover
# months later.
echo
print_msg "Summary"
FACTS_REFRESH=1 source "$REPO_ROOT/lib/facts.sh"
echo "  modules run:     ${ran_list[*]:-none}"
echo "  modules skipped: ${skipped_list[*]:-none}"
echo "  package tier:    $([ "$FACT_CACHY_REPOS" = true ] &&
  echo "cachyos ($FACT_CACHY_TIER)" || echo "vanilla arch")"
echo "  gpu:             $FACT_GPU_VENDORS"
echo "  driver source:   $([ "$FACT_HAS_CHWD" = true ] && echo "chwd" || echo "manual dispatch")"
echo "  game wrapper:    $(facts_game_wrapper)"
echo "  backlight binds: $FACT_HAS_BACKLIGHT"
if [ "$FACT_CACHY_REPOS" != true ]; then
  echo
  print_action "CachyOS repos absent — re-run with --with-cachyos for the optimized tier"
fi

print_msg "Done."
