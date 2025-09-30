#!/usr/bin/env bash
# Usage:
#   yazi-clipboard.sh yank <files...>
#   yazi-clipboard.sh paste <destination>
CLIP_FILE="$HOME/.cache/yazi-clipboard"

case "$1" in
  yank)
    shift
    # overwrite clipboard with new selection
    printf "%s\n" "$@" > "$CLIP_FILE"
    ;;

  paste)
    shift
    dst="$1"
    if [ ! -f "$CLIP_FILE" ]; then
      echo "No files yanked!"
      exit 1
    fi
    mapfile -t files < "$CLIP_FILE"

    # run rsync in place
    rsync -ah -P "${files[@]}" "$dst"
    ;;
esac

