#!/bin/bash

if hyprctl monitors | grep "HDMI-A-1"; then
  hyprctl keyword monitor "HDMI-A-1, disable"
else
  hyprctl keyword monitor "HDMI-A-1, 1440x900@75, 0x0, 1"
  hyprctl keyword monitor "eDP-1, 1920x1080, 1440x0, 1"
fi
