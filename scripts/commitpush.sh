#!/usr/bin/env bash

if [ $# -eq 1 ]; then
    commitmsg=$1
elif [ $# -eq 0 ]; then
    commitmsg="fixes"
else
    echo "invalid format"
    exit 1
fi

git -C "$HOME/personal" add .
git -C "$HOME/personal" commit -m "$commitmsg"
git -C "$HOME/personal" push origin main
