#!/usr/bin/env bash

############ Variables ############
enable_lang=false

activeLayout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')
if [[ $activeLayout ]]; then
  enable_lang=true
fi

if [[ $enable_lang == true ]]; then
  echo $activeLayout
else
  echo ''
fi
