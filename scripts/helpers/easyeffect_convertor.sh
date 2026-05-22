#!/usr/bin/env bash

# Replace with 'input' if you want to convert input preset
section='output'

# Convert boolean and numeric strings + replace invalid empty blocklist
perl -i -pe 's/"(true|false|[\d\.-]+)"/$1/g; s/(?<="blocklist": )""/[]/g' "$@"

# Fix plugins order using v5 state field (your set up plugin order is preserved)
for f in "$@"; do

  # Extract active plugins in right order
  po_src=$(jq ".$section"' | . as $out | .plugins_order | .[] | . as $pn | select($out | to_entries | .[] | .key as $key | select(["blocklist", "plugins_order"] | any(. == $key) | not) | select(.value.state != false) | .key == $pn)' "$f" -r)

  # Replace order array in config with new one
  jq --arg po "$po_src" '($po | split("\n")) as $poa | '".$section.plugins_order"' = $poa' "$f" >tmp
  mv tmp "$f"
done
