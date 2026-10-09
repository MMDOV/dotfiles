#!/usr/bin/env bash
# Usage: confirmation_menu.sh "Question?" command...
# "No" is listed first so a stray Enter cancels.

question=$1
shift

result=$(printf 'No\nYes' | rofi -dmenu -i -no-custom -mesg "$question" \
  -theme-str 'window { width: 360px; } mainbox { children: [message, listview]; } message { padding: 8px 12px; border: 0; } listview { border: 0; } textbox { text-color: @fg; } listview { lines: 2; }')

if [ "$result" = "Yes" ]; then
  "$@"
fi
