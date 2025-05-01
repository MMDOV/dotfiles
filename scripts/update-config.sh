#!/usr/bin/env bash

debug=false
if [ $# -eq 1 ] && [ $1 == "--debug" ]; then
    debug=true
fi

copyandreplace() {
    shopt -s dotglob
    for item in "$1"/*; do
        itemname=$(basename "$item")
        destpath="$2/$itemname"
        if [ -e "$destpath" ]; then
            if ! $debug; then
                if [ -d "$destpath" ]; then
                    rm -rfv "$destpath"
                else
                    rm -fv "$destpath"
                fi
            else
                echo "removing $destpath"
            fi
        fi
        if ! $debug; then
            if [ -d "$item" ]; then
                cp -rfv "$item" "$destpath"
            else
                cp -fv "$item" "$destpath"
            fi
        else
            echo "copying $item to $destpath"
        fi
    done
}

copyandreplace "$HOME/personal/.config" "$HOME/.config"
copyandreplace "$HOME/personal/.local/bin" "$HOME/.local/bin"
copyandreplace "$HOME/personal/dev" "$HOME/dev"

git -C "$HOME/personal" push origin main
