#!/usr/bin/env bash

set -euo pipefail

# Zen Browser: transparent window, colors from `look`, and Twitch made transparent.
#
# Zen keeps its profile in a randomly named folder, so this finds the one Zen actually starts
# with and links two files into its chrome/ folder:
#   userChrome.css   written by `look` (templates/zen.css) into ~/.config/zen/
#   userContent.css  tracked in dotfiles/config/zen/, per-site rules (Twitch)
# It also sets the prefs transparency needs in user.js, which Zen reads at start. Zen only
# reads all of this at start, so restart it afterwards.
#
# The sites themselves are made transparent by the Zen Internet extension (install it from
# addons.mozilla.org); the Twitch rule here covers what its style misses.

ZEN_DIR="$HOME/.zen"
CONFIG_DIR="$HOME/.config/zen"

if [ ! -f "$ZEN_DIR/profiles.ini" ]; then
  echo "Zen has not been started yet (no $ZEN_DIR/profiles.ini); skipping." >&2
  exit 0
fi

# The install's own default (what Zen starts with), else the profile marked Default=1.
profile="$(awk -F= '/^\[Install/{i=1;next} /^\[/{i=0} i&&$1=="Default"{print $2; exit}' "$ZEN_DIR/profiles.ini")"
if [ -z "$profile" ]; then
  profile="$(awk -F= '/^Path=/{p=$2} /^Default=1/{print p; exit}' "$ZEN_DIR/profiles.ini")"
fi
if [ -z "$profile" ] || [ ! -d "$ZEN_DIR/$profile" ]; then
  echo "Could not find Zen's default profile; skipping." >&2
  exit 0
fi
PROFILE_DIR="$ZEN_DIR/$profile"

mkdir -p "$CONFIG_DIR" "$PROFILE_DIR/chrome"

# Generate userChrome.css if `look` has not yet (it needs ~/.config/zen to exist).
if [ ! -f "$CONFIG_DIR/userChrome.css" ] && [ -x "$HOME/.local/bin/look" ]; then
  "$HOME/.local/bin/look" --no-reload apply || true
fi

link() {
  local name="$1"
  [ -f "$CONFIG_DIR/$name" ] || return 0
  ln -sfn "$CONFIG_DIR/$name" "$PROFILE_DIR/chrome/$name"
}
link userChrome.css
link userContent.css

# user.js wins over prefs.js at every start. Replace our lines, leave the rest alone.
USER_JS="$PROFILE_DIR/user.js"
touch "$USER_JS"
set_pref() {
  local key="$1" value="$2"
  sed -i "\|user_pref(\"$key\"|d" "$USER_JS"
  printf 'user_pref("%s", %s);\n' "$key" "$value" >>"$USER_JS"
}
set_pref toolkit.legacyUserProfileCustomizations.stylesheets true
set_pref browser.tabs.allow_transparent_browser true
set_pref zen.widget.linux.transparency true
# Compact mode (sidebar and toolbar hidden until you hover the edge), one toolbar.
set_pref zen.view.compact.enable-at-startup true
set_pref zen.view.compact.hide-toolbar true
set_pref zen.view.use-single-toolbar false

if pgrep -x zen-bin >/dev/null; then
  echo "Zen is running; restart it to load the style."
fi
echo "Zen profile: $PROFILE_DIR"
