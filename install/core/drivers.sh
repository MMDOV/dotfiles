#!/usr/bin/env bash
# GPU drivers and CPU microcode, selected from detected hardware.
#
# Previously this hardcoded one laptop: Intel iGPU + a Pascal NVIDIA card on the
# 580xx legacy branch, plus nvidia-prime. None of that transfers to another
# machine, and picking an NVIDIA driver branch by hand means getting Maxwell /
# Pascal / Turing+ right every time.
#
# So when the CachyOS repos are available we install chwd and let it choose:
# it matches PCI IDs against maintained driver profiles and handles the legacy
# branches. That works on plain Arch too, since chwd ships in the [cachyos]
# repo. The manual dispatch below is only the fallback.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/facts.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'
print_msg() { echo -e "${GREEN}[*] $1${NC}"; }
print_skip() { echo -e "${BLUE}[=] $1${NC}"; }
print_warn() { echo -e "${YELLOW}[!] $1${NC}"; }

pac() { sudo pacman -S --noconfirm --needed "$@"; }

# --- CPU microcode ----------------------------------------------------------

case "$FACT_CPU_VENDOR" in
intel) print_msg "microcode: intel" && pac intel-ucode ;;
amd) print_msg "microcode: amd" && pac amd-ucode ;;
*) print_warn "microcode: unknown CPU vendor, skipping" ;;
esac

# --- Vulkan loaders ---------------------------------------------------------
# Vendor-independent, and needed by every 32-bit game regardless of GPU.
# These moved here from the old lutris helper, where they did not belong.

print_msg "vulkan loaders"
pac vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools

# --- GPU drivers ------------------------------------------------------------

if [ "$FACT_HAS_CHWD" = true ]; then
  print_msg "gpu: delegating to chwd (detected: $FACT_GPU_VENDORS)"
  sudo chwd -a
  exit 0
fi

if [ "$FACT_CACHY_REPOS" = true ]; then
  print_msg "gpu: installing chwd to handle driver selection"
  pac chwd
  sudo chwd -a
  exit 0
fi

print_warn "chwd unavailable — falling back to manual driver selection"

for vendor in $FACT_GPU_VENDORS; do
  case "$vendor" in
  amd)
    # VA-API comes from mesa itself now; the separate libva-mesa-driver
    # packages were folded in and no longer exist.
    print_msg "gpu: amd (mesa / RADV)"
    pac mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
    ;;
  intel)
    print_msg "gpu: intel (mesa / ANV)"
    pac mesa lib32-mesa vulkan-intel lib32-vulkan-intel libva-utils
    # intel-media-driver covers Broadwell and newer; libva-intel-driver is the
    # legacy path. Installing both is harmless and lets libva pick.
    pac intel-media-driver libva-intel-driver
    ;;
  nvidia)
    # Deliberately not automated. The correct package depends on GPU
    # generation — nvidia-open-dkms for Turing and newer, a legacy branch such
    # as nvidia-580xx-dkms for Maxwell/Pascal/Volta — and installing the wrong
    # one leaves a machine without a working display. chwd exists precisely to
    # make this decision; guessing here would be worse than asking.
    print_warn "gpu: nvidia detected but no chwd available"
    print_warn "  install chwd (needs the CachyOS repos) or pick a branch manually:"
    lspci -nn 2>/dev/null | grep -Ei 'vga|3d controller' | sed 's/^/    /' || true
    print_warn "  Turing+ : nvidia-open-dkms lib32-nvidia-utils"
    print_warn "  Pascal  : nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils"
    ;;
  *)
    print_warn "gpu: unrecognised vendor '$vendor', skipping"
    ;;
  esac
done

# Hybrid-graphics offloading only makes sense on a laptop with two GPUs.
# The old script installed it unconditionally, which is wrong on a desktop.
if [ "$FACT_CHASSIS" = "laptop" ] && [ "$FACT_GPU_COUNT" -gt 1 ] &&
  [[ $FACT_GPU_VENDORS == *nvidia* ]]; then
  print_msg "hybrid graphics: installing nvidia-prime"
  pac nvidia-prime
else
  print_skip "hybrid graphics: not applicable"
fi
