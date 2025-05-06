#!/usr/bin/env bash

commitmsg=$1

git -C "$HOME/personal" add .
git -C "$HOME/personal" commit -m "$commitmsg"
git -C "$HOME/personal" push origin main
