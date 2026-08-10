#!/usr/bin/env bash
# Report where the live system has diverged from what this repo tracks.
#
# Drift is normally invisible: update-config.sh copies repo -> system and
# silently discards local edits, and the old pacman.sh did the same to
# /etc/pacman.conf. This makes the divergence visible so it can be resolved
# deliberately, in whichever direction is actually correct.
#
#   check-drift.sh            report everything
#   check-drift.sh --system   only /etc files
#   check-drift.sh --config   only the ~/.config tree
#
# Exits 1 when drift is found, 0 when clean, so it can gate other scripts.
# Read-only: this script never modifies anything.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

drift_found=0
scope="${1:---all}"

report_diff() {
  local label="$1" live="$2" tracked="$3"
  if [ ! -e "$live" ]; then
    echo -e "${YELLOW}[?] $label: not present on this system${NC}"
    return
  fi
  if [ ! -e "$tracked" ]; then
    echo -e "${YELLOW}[?] $label: not tracked in the repo${NC}"
    return
  fi
  if diff -q "$live" "$tracked" >/dev/null 2>&1; then
    echo -e "${GREEN}[=] $label: in sync${NC}"
  else
    echo -e "${YELLOW}[!] $label: DIVERGED${NC}"
    diff -u "$tracked" "$live" | sed 's/^/    /'
    drift_found=1
  fi
}

# --- system files -----------------------------------------------------------

check_system() {
  echo -e "${BLUE}system files${NC}"

  # pacman.conf is intentionally reference-only: it is owned by the system and
  # carries repositories this repo must never overwrite. Shown so repo changes
  # are noticed, never to be deployed.
  local ref="$REPO_ROOT/dotfiles/system/pacman.conf.reference"
  if [ -f "$ref" ]; then
    # The reference carries an explanatory header above the sentinel; only the
    # snapshot below it is comparable to the live file.
    local snapshot
    snapshot="$(mktemp)"
    sed '1,/^# --- snapshot begins ---$/d' "$ref" >"$snapshot"
    if diff -q /etc/pacman.conf "$snapshot" >/dev/null 2>&1; then
      echo -e "${GREEN}[=] /etc/pacman.conf: matches reference snapshot${NC}"
    else
      echo -e "${YELLOW}[i] /etc/pacman.conf: differs from the reference snapshot${NC}"
      echo "    (informational — this file is never deployed from the repo)"
      diff -u "$snapshot" /etc/pacman.conf | sed 's/^/    /'
    fi
    rm -f "$snapshot"
  fi

  report_diff "/etc/makepkg.conf.d/10-dlagents.conf" \
    /etc/makepkg.conf.d/10-dlagents.conf \
    "$REPO_ROOT/dotfiles/system/makepkg.conf.d/10-dlagents.conf"
}

# --- user config tree -------------------------------------------------------

# Three outcomes, only one of which is a problem:
#   conflict  — a tracked file whose content differs. Deploying overwrites it.
#   local     — a file present only on the system. Usually generated state
#               (plugin locks, caches, editor backups); harmless.
#   undeployed— a tracked file not on the system yet.
# Only conflicts set the failure exit code; the rest are informational, since
# treating generated state as drift makes the report useless to read.
check_config() {
  echo -e "${BLUE}~/.config tree${NC}"
  local entry name live out conflicts local_only undeployed
  for entry in "$REPO_ROOT"/dotfiles/config/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    live="$HOME/.config/$name"
    if [ ! -e "$live" ]; then
      echo -e "${YELLOW}[?] $name: not deployed${NC}"
      continue
    fi

    out="$(diff -rq "$entry" "$live" 2>/dev/null)"
    if [ -z "$out" ]; then
      echo -e "${GREEN}[=] $name: in sync${NC}"
      continue
    fi

    conflicts="$(echo "$out" | grep ' differ$' || true)"
    local_only="$(echo "$out" | grep -c "^Only in $live" || true)"
    undeployed="$(echo "$out" | grep -c "^Only in $entry" || true)"

    if [ -n "$conflicts" ]; then
      echo -e "${YELLOW}[!] $name: CONFLICT — tracked files differ${NC}"
      echo "$conflicts" | sed 's/^/    /'
      drift_found=1
    else
      echo -e "${GREEN}[=] $name: tracked files in sync${NC}"
    fi
    [ "$local_only" -gt 0 ] &&
      echo -e "    ${BLUE}${local_only} local-only file(s) (generated state, not tracked)${NC}"
    [ "$undeployed" -gt 0 ] &&
      echo -e "    ${YELLOW}${undeployed} tracked file(s) not deployed${NC}"
  done
}

case "$scope" in
--system) check_system ;;
--config) check_config ;;
--all)
  check_system
  echo
  check_config
  ;;
*)
  echo "usage: $(basename "$0") [--all|--system|--config]" >&2
  exit 2
  ;;
esac

echo
if [ "$drift_found" -eq 1 ]; then
  echo -e "${YELLOW}drift detected — resolve before deploying over it${NC}"
  exit 1
fi
echo -e "${GREEN}no drift${NC}"
