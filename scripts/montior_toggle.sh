#!/bin/bash

if hyprctl monitors | grep "HDMI-A-1"; then
  hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
else
  hyprctl reload
fi
