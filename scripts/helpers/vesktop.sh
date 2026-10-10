#!/usr/bin/env bash

set -euo pipefail

# vesktop-bin is in the cachyos repo, so plain pacman does it. The binary package, not the
# source one, which builds Electron apps from scratch.
sudo pacman -S --noconfirm --needed vesktop-bin

# Appended only when absent; the previous unconditional >> added a duplicate
# line on every run.
FLAGS="$HOME/.config/vesktop-flags.conf"
touch "$FLAGS"
if ! grep -qxF -- "--disable-gpu-compositing" "$FLAGS"; then
  echo "--disable-gpu-compositing" >>"$FLAGS"
fi

# First-run settings, so there is no setup wizard and no clicking in the app. Quick CSS is
# where `look` writes the colors (dotfiles/config/look/templates/vesktop.css); Vesktop
# reloads it live. Vesktop rewrites its settings when it exits, so these only stick while
# it is closed.
if pgrep -f '^/opt/vesktop/vesktop' >/dev/null; then
  echo "Vesktop is running; close it and run this again to apply its settings." >&2
  exit 0
fi
VESKTOP_DIR="$HOME/.config/vesktop"
mkdir -p "$VESKTOP_DIR/settings"
python3 - "$VESKTOP_DIR" <<'PY'
import json, os, sys
d = sys.argv[1]
def merge(path, updates, defaults=None):
    try:
        with open(path) as f:
            data = json.load(f)
    except (OSError, ValueError):
        data = dict(defaults or {})
    data.update(updates)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
merge(os.path.join(d, "state.json"), {"firstLaunch": False})
merge(os.path.join(d, "settings.json"), {}, {"discordBranch": "stable", "minimizeToTray": True, "arRPC": True})
# disableMinSize is read from this top-level file; Vencord's own settings ignore it.
merge(os.path.join(d, "settings.json"), {"disableMinSize": True})
merge(os.path.join(d, "settings", "settings.json"), {"useQuickCss": True, "transparent": True})
PY
touch "$VESKTOP_DIR/settings/quickCss.css"
[ -x "$HOME/.local/bin/look" ] && "$HOME/.local/bin/look" --no-reload apply || true
