#!/usr/bin/env bash
# Pacman configuration.
#
# This module EDITS /etc/pacman.conf in place. It never templates the file.
# The previous version installed a tracked copy over it, which deletes whatever
# repositories the machine actually has — including the CachyOS repos this
# setup depends on. /etc/pacman.conf is owned by the system, not by this repo.
#
#   pacman.sh                 apply options, sync, update
#   pacman.sh --with-cachyos  additionally add the CachyOS repos if missing
#   pacman.sh --mirrors       additionally refresh the Arch mirrorlist
#   pacman.sh --no-update     skip the -Syu at the end

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

PACMAN_CONF=/etc/pacman.conf
systemupdate=true
with_cachyos=false
refresh_mirrors=false

while [[ $# -gt 0 ]]; do
  case "$1" in
  --with-cachyos) with_cachyos=true ;;
  --mirrors) refresh_mirrors=true ;;
  --no-update) systemupdate=false ;;
  # Backwards compatibility with the old `pacman.sh <true|false>` signature.
  true) systemupdate=true ;;
  false) systemupdate=false ;;
  *) echo "unknown argument: $1" >&2 && exit 1 ;;
  esac
  shift
done

# Desired [options] settings. Flags are bare keys; kv entries take a value.
# Anything not listed here is left exactly as found.
WANT_FLAGS="Color ILoveCandy VerbosePkgLists"
WANT_KV="ParallelDownloads=5"

# Rewrite only the [options] section: normalise the keys we care about,
# append any that are absent, and pass every other line through untouched.
# Repository blocks are never entered.
render_options() {
  awk -v want_flags="$WANT_FLAGS" -v want_kv="$WANT_KV" '
    BEGIN {
      n = split(want_flags, F, " ")
      for (i = 1; i <= n; i++) flag[F[i]] = 1
      m = split(want_kv, K, " ")
      for (i = 1; i <= m; i++) { split(K[i], p, "="); kv[p[1]] = p[2] }
    }
    function flush_missing(   k) {
      for (k in flag) if (!seen[k]) print k
      for (k in kv) if (!seen[k]) print k " = " kv[k]
    }
    /^\[/ {
      if (in_opts && $0 != "[options]") { flush_missing(); in_opts = 0 }
      if ($0 == "[options]") in_opts = 1
      print; next
    }
    in_opts {
      probe = $0
      sub(/^[#[:space:]]+/, "", probe)
      split(probe, parts, /[[:space:]]*=[[:space:]]*/)
      key = parts[1]
      sub(/[[:space:]]+$/, "", key)
      if (key in flag) { print key; seen[key] = 1; next }
      if (key in kv) { print key " = " kv[key]; seen[key] = 1; next }
      print; next
    }
    { print }
    END { if (in_opts) flush_missing() }
  ' "$1"
}

# Uncomment [multilib] and the Include line that follows it. Only touches the
# multilib block, and only when pacman does not already report it as active.
render_multilib() {
  awk '
    /^#\[multilib\][[:space:]]*$/ { print "[multilib]"; pending = 1; next }
    pending && /^#Include[[:space:]]*=/ { sub(/^#/, "", $0); print; pending = 0; next }
    { pending = 0; print }
  ' "$1"
}

apply_conf() {
  local desc="$1" tmp
  tmp="$(mktemp)"
  cat >"$tmp"
  if cmp -s "$tmp" "$PACMAN_CONF"; then
    print_skip "$desc: already correct"
    rm -f "$tmp"
    return 0
  fi
  print_msg "$desc: applying"
  diff -u "$PACMAN_CONF" "$tmp" | sed 's/^/    /' || true
  sudo install -Dm644 "$tmp" "$PACMAN_CONF"
  rm -f "$tmp"
}

# --- options ---------------------------------------------------------------

render_options "$PACMAN_CONF" | apply_conf "pacman options"

# --- multilib --------------------------------------------------------------

if pacman-conf --repo-list 2>/dev/null | grep -qx multilib; then
  print_skip "multilib: already enabled"
else
  render_multilib "$PACMAN_CONF" | apply_conf "multilib"
fi

# --- CachyOS repositories ---------------------------------------------------
# Added with CachyOS's own installer, which detects the CPU's instruction-set
# level and picks the matching repo tier (v3 / v4 / znver4). Never implicit:
# adding a third-party repository, and the forked pacman that comes with the
# [cachyos] repo, stays a deliberate act.

FACTS_REFRESH=1 source "$REPO_ROOT/lib/facts.sh"

if [ "$FACT_CACHY_REPOS" = true ]; then
  print_skip "cachyos repos: present (tier: $FACT_CACHY_TIER)"
elif [ "$with_cachyos" = true ]; then
  print_msg "cachyos repos: installing via cachyos-repo.sh (isa: $FACT_ISA)"
  workdir="$(mktemp -d)"
  trap 'rm -rf "$workdir"' EXIT
  curl -fsSL https://mirror.cachyos.org/cachyos-repo.tar.xz \
    -o "$workdir/cachyos-repo.tar.xz"
  tar xf "$workdir/cachyos-repo.tar.xz" -C "$workdir"
  (cd "$workdir/cachyos-repo" && sudo ./cachyos-repo.sh)
else
  print_warn "cachyos repos: absent — re-run with --with-cachyos to add them"
fi

# --- mirrors ----------------------------------------------------------------
# Opt-in. reflector rewrites the Arch mirrorlist and is slow; CachyOS manages
# its own mirrors separately via cachyos-*-mirrorlist.

if [ "$refresh_mirrors" = true ]; then
  print_msg "refreshing Arch mirrorlist"
  sudo pacman -S --noconfirm --needed reflector
  sudo reflector \
    --protocol https \
    --age 5 \
    --delay 0.25 \
    --sort rate \
    --fastest 10 \
    --save /etc/pacman.d/mirrorlist \
    --threads 5
else
  print_skip "mirrors: unchanged (pass --mirrors to refresh)"
fi

# --- update -----------------------------------------------------------------

if [ "$systemupdate" = true ]; then
  print_msg "syncing and updating"
  sudo pacman -Syu --noconfirm --needed
fi
