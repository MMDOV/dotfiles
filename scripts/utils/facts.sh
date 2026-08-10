#!/usr/bin/env bash
# CLI over lib/facts.sh. Standalone so detection can be inspected without
# running a full install.
#
#   facts.sh              human-readable report (default)
#   facts.sh --json       machine-readable
#   facts.sh --lua        Lua table for the Hyprland config
#   facts.sh --write-lua  write that table to ~/.config/hypr/hyprland/facts.lua
#   facts.sh <name>       print one fact, e.g. `facts.sh cachy_repos`

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/facts.sh"

case "${1:---report}" in
--report)
  facts_report
  ;;
--json)
  facts_json
  ;;
--lua)
  facts_lua
  ;;
--write-lua)
  dest="$HOME/.config/hypr/hyprland/facts.lua"
  mkdir -p "$(dirname "$dest")"
  facts_lua >"$dest"
  echo "wrote $dest"
  ;;
--help | -h)
  sed -n '2,10p' "$0" | sed 's/^# \?//'
  ;;
*)
  # Single fact lookup: accepts either `cachy_repos` or `FACT_CACHY_REPOS`.
  name="$1"
  [[ $name == FACT_* ]] || name="FACT_$(echo "$name" | tr '[:lower:]' '[:upper:]')"
  if [ -z "${!name+x}" ]; then
    echo "unknown fact: $1" >&2
    exit 1
  fi
  echo "${!name}"
  ;;
esac
