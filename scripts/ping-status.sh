#!/usr/bin/env bash
HISTFILE="/tmp/waybar_ping_history"

PING=$(ping -c 1 8.8.8.8 | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')

if [ -n "$PING" ]; then
    VALUE="${PING}ms"
else
    VALUE="N/A"
fi

echo "$VALUE" >> "$HISTFILE"
tail -n 5 "$HISTFILE" > "$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE"

TOOLTIP=$(tac "$HISTFILE" | paste -sd '\n' - | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

printf '{"text":"%s","tooltip":"%s"}\n' "$VALUE" "$TOOLTIP"

