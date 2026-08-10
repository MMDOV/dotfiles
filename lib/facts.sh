#!/usr/bin/env bash
# Machine and distro detection. Source this, then read the FACT_* variables.
#
#   source "$REPO_ROOT/lib/facts.sh"
#   if [ "$FACT_CACHY_REPOS" = true ]; then ...
#
# Everything here is read-only probing and safe to call repeatedly. Detection
# runs once per shell; re-sourcing is a no-op unless FACTS_REFRESH=1 is set.
#
# Gate on capability, not distro name. "Are the CachyOS repos available?" is a
# truer question than "is this CachyOS?", because both machines run vanilla Arch
# with the CachyOS repos layered on top.

[ -n "${FACTS_LOADED:-}" ] && [ "${FACTS_REFRESH:-0}" != "1" ] && return 0

# --- distro -----------------------------------------------------------------

FACT_DISTRO="unknown"
if [ -r /etc/os-release ]; then
  FACT_DISTRO="$(. /etc/os-release 2>/dev/null && echo "${ID:-unknown}")"
fi

FACT_HOSTNAME="$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo unknown)"

# --- CachyOS repositories ---------------------------------------------------
# pacman-conf reads the live config, so this stays correct no matter how the
# repos got there (their installer, cachyos-repo.sh, or by hand).

FACT_CACHY_REPOS=false
FACT_CACHY_TIER="none"
if command -v pacman-conf &>/dev/null; then
  _repos="$(pacman-conf --repo-list 2>/dev/null || true)"
  if echo "$_repos" | grep -q '^cachyos'; then
    FACT_CACHY_REPOS=true
    # Most specific tier wins; znver4 and v4 share a mirrorlist but are distinct repos.
    if echo "$_repos" | grep -q '^cachyos-znver4'; then
      FACT_CACHY_TIER="znver4"
    elif echo "$_repos" | grep -q '^cachyos-v4'; then
      FACT_CACHY_TIER="v4"
    elif echo "$_repos" | grep -q '^cachyos-v3'; then
      FACT_CACHY_TIER="v3"
    else
      FACT_CACHY_TIER="base"
    fi
  fi
  unset _repos
fi

# --- CPU --------------------------------------------------------------------

FACT_CPU_VENDOR="unknown"
case "$(grep -m1 '^vendor_id' /proc/cpuinfo 2>/dev/null | awk '{print $3}')" in
  GenuineIntel) FACT_CPU_VENDOR="intel" ;;
  AuthenticAMD) FACT_CPU_VENDOR="amd" ;;
esac

FACT_THREADS="$(nproc 2>/dev/null || echo 1)"

# Highest microarchitecture level the dynamic linker reports as supported.
# This is what decides which CachyOS repo tier a machine qualifies for.
FACT_ISA="x86-64"
if [ -x /lib/ld-linux-x86-64.so.2 ]; then
  for _lvl in v4 v3 v2; do
    if /lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q "x86-64-$_lvl (supported"; then
      FACT_ISA="x86-64-$_lvl"
      break
    fi
  done
  unset _lvl
fi

# AMD Zen 4/5 get their own repo tier above v4.
FACT_ZEN_ARCH="none"
if [ "$FACT_CPU_VENDOR" = "amd" ] && command -v gcc &>/dev/null; then
  FACT_ZEN_ARCH="$(gcc -march=native -Q --help=target 2>/dev/null |
    grep -Po '^\s+-march=\s+\K(\w+)$' | head -1 || true)"
  [ -z "$FACT_ZEN_ARCH" ] && FACT_ZEN_ARCH="none"
fi

# --- GPU --------------------------------------------------------------------
# PCI vendor IDs off the DRM devices. A hybrid laptop reports several; the new
# desktop will report one. Order is card enumeration order, not preference.

FACT_GPU_VENDORS=""
# card:vendor pairs in enumeration order, e.g. "card0:nvidia card1:intel".
# Needed to build AQ_DRM_DEVICES, which is per-machine: card numbering depends
# on probe order and does not transfer between systems.
FACT_GPU_CARDS=""
for _v in /sys/class/drm/card[0-9]*/device/vendor; do
  [ -r "$_v" ] || continue
  _card="$(basename "$(dirname "$(dirname "$_v")")")"
  case "$(cat "$_v" 2>/dev/null)" in
    0x10de) _name="nvidia" ;;
    0x1002 | 0x1022) _name="amd" ;;
    0x8086) _name="intel" ;;
    *) continue ;;
  esac
  FACT_GPU_CARDS="${FACT_GPU_CARDS:+$FACT_GPU_CARDS }$_card:$_name"
  case " $FACT_GPU_VENDORS " in
    *" $_name "*) ;;
    *) FACT_GPU_VENDORS="${FACT_GPU_VENDORS:+$FACT_GPU_VENDORS }$_name" ;;
  esac
done
unset _v _name _card
[ -z "$FACT_GPU_VENDORS" ] && FACT_GPU_VENDORS="unknown"

FACT_GPU_COUNT="$(echo "$FACT_GPU_VENDORS" | wc -w)"

# --- chassis and power ------------------------------------------------------

FACT_CHASSIS="unknown"
if command -v hostnamectl &>/dev/null; then
  FACT_CHASSIS="$(hostnamectl chassis 2>/dev/null || echo unknown)"
fi
if [ "$FACT_CHASSIS" = "unknown" ] && [ -r /sys/class/dmi/id/chassis_type ]; then
  case "$(cat /sys/class/dmi/id/chassis_type)" in
    3 | 4 | 6 | 7) FACT_CHASSIS="desktop" ;;
    9 | 10 | 14) FACT_CHASSIS="laptop" ;;
  esac
fi

# Deliberately separate from chassis. The brightness keybinds and
# switch_backlight.sh need a backlight device, not a laptop — a desktop with a
# DDC-capable monitor is a different case, and some laptops expose neither.
FACT_HAS_BACKLIGHT=false
compgen -G "/sys/class/backlight/*" >/dev/null 2>&1 && FACT_HAS_BACKLIGHT=true

FACT_HAS_BATTERY=false
compgen -G "/sys/class/power_supply/BAT*" >/dev/null 2>&1 && FACT_HAS_BATTERY=true

# --- installed CachyOS tooling ----------------------------------------------

FACT_HAS_CHWD=false
command -v chwd &>/dev/null && FACT_HAS_CHWD=true

FACT_HAS_GAME_PERF=false
command -v game-performance &>/dev/null && FACT_HAS_GAME_PERF=true

FACT_HAS_CACHY_SETTINGS=false
pacman -Qq cachyos-settings &>/dev/null && FACT_HAS_CACHY_SETTINGS=true

# The CachyOS wiki puts the floor for game-performance at roughly 6c/12t —
# below that it gives no benefit and can actively hurt. This laptop (8 threads)
# is under it; any AM5 part clears it.
FACT_GAME_PERF_USEFUL=false
if [ "$FACT_HAS_GAME_PERF" = true ] && [ "$FACT_THREADS" -ge 12 ]; then
  FACT_GAME_PERF_USEFUL=true
fi

FACTS_LOADED=1

# --- output helpers ---------------------------------------------------------

facts_report() {
  local g='\033[0;32m' b='\033[0;34m' n='\033[0m'
  printf "${b}%s${n}\n" "detected system"
  printf "  %-22s %s\n" "hostname" "$FACT_HOSTNAME"
  printf "  %-22s %s\n" "distro" "$FACT_DISTRO"
  printf "  %-22s %s\n" "chassis" "$FACT_CHASSIS"
  printf "  %-22s %s\n" "cpu vendor" "$FACT_CPU_VENDOR"
  printf "  %-22s %s\n" "threads" "$FACT_THREADS"
  printf "  %-22s %s\n" "isa level" "$FACT_ISA"
  [ "$FACT_ZEN_ARCH" != "none" ] &&
    printf "  %-22s %s\n" "zen arch" "$FACT_ZEN_ARCH"
  printf "  %-22s %s\n" "gpu" "$FACT_GPU_VENDORS"
  printf "  %-22s %s\n" "drm cards" "$FACT_GPU_CARDS"
  printf "  %-22s %s\n" "backlight" "$FACT_HAS_BACKLIGHT"
  printf "  %-22s %s\n" "battery" "$FACT_HAS_BATTERY"
  printf "${b}%s${n}\n" "package tier"
  printf "  %-22s %s\n" "cachyos repos" "$FACT_CACHY_REPOS"
  printf "  %-22s %s\n" "cachyos tier" "$FACT_CACHY_TIER"
  printf "  %-22s %s\n" "cachyos-settings" "$FACT_HAS_CACHY_SETTINGS"
  printf "  %-22s %s\n" "chwd" "$FACT_HAS_CHWD"
  printf "  %-22s %s\n" "game-performance" "$FACT_HAS_GAME_PERF"
  printf "  %-22s %s\n" "  worth using" "$FACT_GAME_PERF_USEFUL"
  printf "${g}%s${n}\n" "→ gaming wrapper: $(facts_game_wrapper)"
}

# The single place that decides which wrapper games get launched through.
# game-performance and gamemode both exist to do the same job; ananicy-cpp
# fights gamemode over process niceness, so only one may ever be active.
facts_game_wrapper() {
  if [ "$FACT_GAME_PERF_USEFUL" = true ]; then
    echo "game-performance"
  else
    echo "gamemoderun"
  fi
}

facts_json() {
  cat <<EOF
{
  "hostname": "$FACT_HOSTNAME",
  "distro": "$FACT_DISTRO",
  "chassis": "$FACT_CHASSIS",
  "cpu_vendor": "$FACT_CPU_VENDOR",
  "threads": $FACT_THREADS,
  "isa": "$FACT_ISA",
  "zen_arch": "$FACT_ZEN_ARCH",
  "gpu_vendors": "$FACT_GPU_VENDORS",
  "gpu_cards": "$FACT_GPU_CARDS",
  "gpu_count": $FACT_GPU_COUNT,
  "has_backlight": $FACT_HAS_BACKLIGHT,
  "has_battery": $FACT_HAS_BATTERY,
  "cachy_repos": $FACT_CACHY_REPOS,
  "cachy_tier": "$FACT_CACHY_TIER",
  "has_cachy_settings": $FACT_HAS_CACHY_SETTINGS,
  "has_chwd": $FACT_HAS_CHWD,
  "has_game_performance": $FACT_HAS_GAME_PERF,
  "game_perf_useful": $FACT_GAME_PERF_USEFUL,
  "game_wrapper": "$(facts_game_wrapper)"
}
EOF
}

# Consumed by Hyprland's Lua config, which cannot probe hardware itself —
# EDID under /sys/class/drm/*/edid is unreadable unprivileged, and relying on
# Lua stdlib availability inside the compositor is not a bet worth taking.
facts_lua() {
  cat <<EOF
-- Generated by scripts/utils/facts.sh --lua. Do not edit; regenerate instead.
return {
	hostname = "$FACT_HOSTNAME",
	distro = "$FACT_DISTRO",
	chassis = "$FACT_CHASSIS",
	gpu_vendors = "$FACT_GPU_VENDORS",
	has_backlight = $FACT_HAS_BACKLIGHT,
	has_battery = $FACT_HAS_BATTERY,
	cachy_repos = $FACT_CACHY_REPOS,
	game_wrapper = "$(facts_game_wrapper)",
}
EOF
}
