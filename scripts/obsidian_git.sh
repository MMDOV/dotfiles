#!/bin/bash

# --- CONFIGURATION ---
BRAIN_DIR="$HOME/personal/brain"
SCRIPTS_DIR="$HOME/personal/scripts"
SYNC_SCRIPT="$SCRIPTS_DIR/sync_brain.sh"
SYSTEMD_DIR="$HOME/.config/systemd/user"

echo ">> Setting up Obsidian Brain Auto-Sync..."

# 1. Ensure directories exist
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$SYSTEMD_DIR"

# 2. Create the Sync Script in your scripts folder
cat <<EOF >"$SYNC_SCRIPT"
#!/bin/bash
# Navigate to the brain directory
cd "$BRAIN_DIR" || exit 1

# Check for changes (modified, added, deleted)
if [[ -n \$(git status --porcelain) ]]; then
    git add .
    git commit -m "Auto-save: \$(date '+%Y-%m-%d %H:%M')"
    git push origin main
fi
EOF

chmod +x "$SYNC_SCRIPT"
echo "   [+] Sync script created at: $SYNC_SCRIPT"

# 3. Create the Systemd Service Unit
cat <<EOF >"$SYSTEMD_DIR/brain-sync.service"
[Unit]
Description=Sync Brain with Git

[Service]
Type=oneshot
ExecStart=$SYNC_SCRIPT
EOF

# 4. Create the Systemd Timer Unit (Runs every 30 mins)
cat <<EOF >"$SYSTEMD_DIR/brain-sync.timer"
[Unit]
Description=Run Brain Sync every 30 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=30min

[Install]
WantedBy=timers.target
EOF

echo "   [+] Systemd units created."

# 5. Enable and Start
systemctl --user daemon-reload
systemctl --user enable --now brain-sync.timer

echo ">> Brain Auto-Sync is ACTIVE."
