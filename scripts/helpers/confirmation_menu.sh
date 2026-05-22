#!/usr/bin/env bash

result=$(printf "No\nYes" | fuzzel --dmenu --lines 2 --prompt "$1 ")

if [ "$result" == "Yes" ]; then
  $2
fi
