#!/usr/bin/env bash

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [ $# -eq 1 ]; then
  commitmsg=$1
elif [ $# -eq 0 ]; then
  commitmsg="Automated Commit - $(date '+%Y-%m-%d %H:%M:%S')"
else
  echo "invalid format"
  exit 1
fi

git -C "$REPO_ROOT" add .
git -C "$REPO_ROOT" commit -m "$commitmsg"
git -C "$REPO_ROOT" push origin main
