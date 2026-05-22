#!/bin/bash

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# --- CONFIGURATION ---
BRAIN_DIR="$REPO_ROOT/brain"
SYNC_SCRIPT="$REPO_ROOT/scripts/utils/sync_brain.sh"
SYSTEMD_DIR="$HOME/.config/systemd/user"

echo ">> Setting up Obsidian Brain Auto-Sync..."

# 1. Ensure directories exist
mkdir -p "$SYSTEMD_DIR"

# 2. Ensure sync script is executable
chmod +x "$SYNC_SCRIPT"
echo "   [+] Sync script at: $SYNC_SCRIPT"

# 3. Create the Systemd Service Unit
cat <<SERVICEEOF >"$SYSTEMD_DIR/brain-sync.service"
[Unit]
Description=Sync Brain with Git

[Service]
Type=oneshot
ExecStart=$SYNC_SCRIPT
SERVICEEOF

# 4. Create the Systemd Timer Unit (Runs every 30 mins)
cat <<TIMEREOF >"$SYSTEMD_DIR/brain-sync.timer"
[Unit]
Description=Run Brain Sync every 30 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=30min

[Install]
WantedBy=timers.target
TIMEREOF

echo "   [+] Systemd units created."

# 5. Enable and Start
systemctl --user daemon-reload
systemctl --user enable --now brain-sync.timer

echo ">> Brain Auto-Sync is ACTIVE."
