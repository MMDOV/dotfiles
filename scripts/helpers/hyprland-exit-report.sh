#!/usr/bin/env bash
# Show what the audit rules recorded about Hyprland exiting.
# Usage: sudo hyprland-exit-report.sh [START [END]]
#   START/END are ausearch times, e.g. 19:30:00 or "11/01/2026 19:30:00".
#   Default: everything since today 00:00.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "run with sudo" >&2
    exit 1
fi

start="${1:-today}"
args=(--start "$start")
[[ -n "${2:-}" ]] && args+=(--end "$2")

echo "== Hyprland exit_group (a0 = exit status) =="
ausearch -i "${args[@]}" -k hypr-exit 2>/dev/null | grep -E '^type=(SYSCALL)' || echo "none"

echo
echo "== Fatal signals the kernel delivered to a process (ANOM_ABEND) =="
ausearch -i "${args[@]}" -m ANOM_ABEND 2>/dev/null | grep -i -E 'hyprland|start-hyprland' || echo "none"

echo
echo "== Signals sent by anyone (a0 = target pid for kill/tkill; compare with Hyprland's pid) =="
out=$(ausearch -i "${args[@]}" -k hypr-sig 2>/dev/null |
    grep -E '^type=SYSCALL' |
    sed -E 's/.*msg=audit\(([^)]*)\).*syscall=([^ ]+).*a0=([^ ]+) a1=([^ ]+) a2=([^ ]+).*pid=([0-9]+).*comm=("[^"]*"|[^ ]*) exe=("[^"]*"|[^ ]*).*/\1 \2 a0=\3 a1=\4 a2=\5 sender_pid=\6 comm=\7 exe=\8/' |
    tail -n 200 || true)
echo "${out:-none}"
