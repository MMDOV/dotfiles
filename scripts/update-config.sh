#!/usr/bin/env bash

debug=false
configonly=false

if [ $# -ge 1 ]; then
  if [ $1 == "--debug" ]; then
    debug=true
  elif [ $1 == "config" ]; then
    configonly=true
    if [ $# -gt 1 ]; then
      subconf=$2
    fi
  fi
fi

copyandreplace() {
  shopt -s dotglob
  for item in "$1"/*; do
    itemname=$(basename "$item")
    destpath="$2/$itemname"
    mkdir -p "$(dirname "$destpath")"
    if ! $debug; then
      if [ -d "$item" ]; then
        cp -rfvp "$item" "$destpath"
      else
        cp -fvp "$item" "$destpath"
      fi
    else
      echo "copying $item to $destpath"
    fi
  done
}

function add_yazi_pkg() {
  local pkg=$1
  if ! ya pkg list | grep -i "$pkg"; then
    ya pkg add "$pkg"
  else
    echo "Package $pkg already installed. Skipping..."
  fi
}

if [ -z "$subconf" ]; then
  copyandreplace "$HOME/personal/config" "$HOME/.config"
  hyprctl reload
  add_yazi_pkg boydaihungst/gvfs
  add_yazi_pkg boydaihungst/mediainfo
  add_yazi_pkg pirafrank/what-size
  add_yazi_pkg dedukun/bookmarks

else
  mkdir -p "$HOME/config/$subconf"
  copyandreplace "$HOME/personal/config/$subconf" "$HOME/.config/$subconf"
fi
if ! $configonly; then
  copyandreplace "$HOME/personal/local/bin" "$HOME/.local/bin"
  copyandreplace "$HOME/personal/dev" "$HOME/dev"
  copyandreplace "$HOME/personal/home" "$HOME"
fi
hyprctl reload
