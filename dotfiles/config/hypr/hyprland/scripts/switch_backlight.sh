#!/usr/bin/env bash

current=$(brightnessctl get)
max=$(brightnessctl max)

if [ $current -eq $max ]; then
    brightnessctl set 5%
else
    brightnessctl set 100%
fi
