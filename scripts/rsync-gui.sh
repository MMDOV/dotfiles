#!/bin/bash

DEST=$(zenity --file-selection --directory --title="Select Destination")
if [ -z "$DEST" ]; then
  exit 0
fi

DEST_NAME=$(basename "$DEST")

FIFO=$(mktemp -u)
mkfifo "$FIFO"
trap "rm -f '$FIFO'; kill 0" EXIT

stdbuf -oL rsync -a --info=progress2 --no-inc-recursive "$@" "$DEST/" >"$FIFO" &
RSYNC_PID=$!

(
  while IFS= read -r -d $'\r' line; do

    PERCENT=$(echo "$line" | grep -oE '[0-9]+%' | head -1 | tr -d '%')

    SPEED=$(echo "$line" | grep -oE '[0-9.]+[A-Za-z]+/s' | head -1)

    if [[ -n "$PERCENT" ]]; then
      echo "# Copying to: $DEST_NAME\nSpeed: $SPEED ($PERCENT%)"
      echo "$PERCENT"
    fi
  done <"$FIFO"
) | zenity --progress \
  --title="File Transfer" \
  --text="Initializing..." \
  --percentage=0 \
  --auto-close \
  --width=400 \
  --window-icon=folder-download

kill $RSYNC_PID 2>/dev/null
wait $RSYNC_PID 2>/dev/null

notify-send "Rsync Finished" "Transfer to $DEST_NAME complete." -i folder-download
