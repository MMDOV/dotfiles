#!/usr/bin/env bash

monitors_count=$(hyprctl monitors | grep -Eoc "[0-9]*x[0-9]*@[0-9]*.[0-9]*\s+at\s+[0-9]*x[0-9]*")

if [[ $monitors_count -eq 1 ]]; then
  grim - | swappy -f -
  exit 0
fi

monitors=$(hyprctl monitors | grep -Eo --group-separator=\n "[0-9]*x[0-9]*@[0-9]*.[0-9]*\s+at\s+[0-9]*x[0-9]*")

selected_monitor=$(printf "Both\n$monitors" | fuzzel --dmenu --prompt "Which monitor?")

if [[ $selected_monitor == "Both" ]]; then
  grim - | swappy -f -
  exit 0
fi

sleep .1
resolution=$(printf "$selected_monitor" | grep -Eo "[0-9]*x[0-9]*@" | grep -Eo "[0-9]*x[0-9]*")
positions=$(printf "$selected_monitor" | grep -Eo "\s[0-9]*x[0-9]*" | grep -Eo "[0-9]*x[0-9]*")
positions_1=$(printf "$positions" | grep -Eo "[0-9]*x" | grep -Eo "[0-9]*")
positions_2=$(printf "$positions" | grep -Eo "x[0-9]*" | grep -Eo "[0-9]*")

echo $positions_1,$positions_2

grim -g "$positions_1,$positions_2 $(printf $resolution)" - | swappy -f -
