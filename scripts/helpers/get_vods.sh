#!/bin/bash

# Configuration
OUTPUT_DIR="$HOME/dev/twitch_data" # Defines the unified path (default: twitch_data folder next to this script)
VOD_COUNT=10
PROXY_SETTINGS="--proxy socks5h://127.0.0.1:1080"
# To disable proxy, comment the line above and uncomment the one below:
# PROXY_SETTINGS=""

# 1. Get Channel Name (Arguments or Prompt)
CHANNEL="$1"
if [ -z "$CHANNEL" ]; then
  read -p "Enter Twitch channel name: " CHANNEL
fi

if [ -z "$CHANNEL" ]; then
  echo "Error: Channel name cannot be empty."
  exit 1
fi

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Set file paths using the unified directory
OUTPUT_FILE="${OUTPUT_DIR}/_vods_${CHANNEL}.json"
CACHE_FILE="${OUTPUT_DIR}/_last_id_${CHANNEL}.txt"
TWITCH_URL="https://www.twitch.tv/${CHANNEL}/videos"

# 2. Setup yt-dlp arguments
YT_DLP_ARGS=(--no-check-certificate -s)
if [ -n "$PROXY_SETTINGS" ]; then
  YT_DLP_ARGS+=($PROXY_SETTINGS)
fi

# 3. Cache Check
if [[ -f "$OUTPUT_FILE" && -f "$CACHE_FILE" ]]; then
  echo "Checking for new VODs for $CHANNEL..."
  LATEST_ID_ONLINE=$(yt-dlp "${YT_DLP_ARGS[@]}" --playlist-items 1 --print "%(id)s" "$TWITCH_URL" 2>/dev/null)
  LATEST_ID_LOCAL=$(cat "$CACHE_FILE" 2>/dev/null)

  if [[ "$LATEST_ID_ONLINE" == "$LATEST_ID_LOCAL" && -n "$LATEST_ID_ONLINE" ]]; then
    echo "No new VODs found. Using cached data:"
    cat "$OUTPUT_FILE"
    exit 0
  fi
fi

# 4. Fetch New Data
echo "Please wait, contacting Twitch to fetch the latest $VOD_COUNT VODs..."
PRINT_FORMAT="%(id)s|%(upload_date)s|%(view_count)s|%(title)s"

# Fetch all VOD data at once
VOD_DATA=$(yt-dlp "${YT_DLP_ARGS[@]}" --playlist-items "1-${VOD_COUNT}" --print "$PRINT_FORMAT" "$TWITCH_URL" 2>/dev/null)

if [ -z "$VOD_DATA" ]; then
  echo "Error: Failed to fetch VODs or channel has no VODs."
  exit 1
fi

# 5. Process Data and Build JSON
FIRST_ITEM=true
JSON_ARRAY="[]"

# Read line by line. IFS="|" splits the line into variables.
while IFS="|" read -r RAW_ID VOD_DATE VOD_VIEWS VOD_TITLE; do
  # Skip empty lines
  [ -z "$RAW_ID" ] && continue

  # Strip the leading 'v' from the ID if it exists
  CLEAN_ID="${RAW_ID#v}"

  # Cache the first ID
  if [ "$FIRST_ITEM" = true ]; then
    echo "$RAW_ID" >"$CACHE_FILE"
    FIRST_ITEM=false
  fi

  # Ensure views is treated as an integer (default to 0 if empty/NA)
  [[ ! "$VOD_VIEWS" =~ ^[0-9]+$ ]] && VOD_VIEWS=0

  LINK="https://player.twitch.tv/?video=${CLEAN_ID}&parent=localhost&autoplay=false"

  # Use jq to safely append objects to the JSON array
  JSON_ARRAY=$(echo "$JSON_ARRAY" | jq --arg title "$VOD_TITLE" \
    --arg date "$VOD_DATE" \
    --argjson views "$VOD_VIEWS" \
    --arg link "$LINK" \
    '. += [{"title": $title, "date": $date, "views": $views, "link": $link}]')
done <<<"$VOD_DATA"

# 6. Save Output
echo "$JSON_ARRAY" >"$OUTPUT_FILE"
echo "Successfully generated files in $OUTPUT_DIR:"
cat "$OUTPUT_FILE"
