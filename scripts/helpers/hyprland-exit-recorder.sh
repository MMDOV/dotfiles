#!/usr/bin/env bash
# Install (or remove) the auditd rules that record how Hyprland exits.
# Usage: sudo hyprland-exit-recorder.sh [install|remove]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$REPO_ROOT/dotfiles/system/audit/rules.d/hyprland-exit.rules"
DEST="/etc/audit/rules.d/hyprland-exit.rules"

if [[ $EUID -ne 0 ]]; then
    echo "run with sudo" >&2
    exit 1
fi

case "${1:-install}" in
install)
    install -Dm640 "$SRC" "$DEST"
    # augenrules merges rules.d/ into audit.rules; auditd loads it and logs to
    # /var/log/audit/audit.log on disk (not the tmpfs under /run).
    augenrules --load
    systemctl enable --now auditd
    auditctl -l | grep -c hypr- | xargs echo "hypr rules loaded:"
    ;;
remove)
    rm -f "$DEST"
    augenrules --load
    systemctl disable --now auditd || true
    ;;
*)
    echo "usage: $0 [install|remove]" >&2
    exit 2
    ;;
esac
