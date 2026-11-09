#!/usr/bin/env bash
# Installs Aether into ~/.local/share/aether, or updates it. Asks GitHub for the newest release:
# missing or older -> download it, same -> do nothing, GitHub unreachable -> keep what is there.
# Run it again by hand to check for a new version. Stop the VPN window first so the binary is free.
set -euo pipefail

AETHER_DIR="${AETHER_DIR:-$HOME/.local/share/aether}"
REPO="CluvexStudio/Aether"
ASSET="aether-linux-x86_64.tar.gz"

latest() { # newest release tag, empty when GitHub is unreachable
  curl -fsS --max-time 5 "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null |
    grep -m1 '"tag_name"' | cut -d'"' -f4 || true
}

download() { # download <tag>
  local url tmp
  tmp="$(mktemp -d)"
  url="https://github.com/$REPO/releases/download/$1/$ASSET"
  echo "Downloading Aether $1"
  curl -fsSL -o "$tmp/$ASSET" "$url"
  curl -fsSL -o "$tmp/$ASSET.sha256" "$url.sha256"
  (cd "$tmp" && sha256sum -c "$ASSET.sha256") || { rm -rf "$tmp"; exit 1; }
  mkdir -p "$AETHER_DIR"
  tar -xzf "$tmp/$ASSET" -C "$AETHER_DIR"
  rm -rf "$tmp"
}

new="$(latest)"
have=""
[ -x "$AETHER_DIR/aether" ] && have="v$("$AETHER_DIR/aether" --version | awk '{print $2}')"

if [ -z "$new" ]; then
  if [ -x "$AETHER_DIR/aether" ]; then
    echo "Can't reach GitHub, keeping Aether ${have:-?}"
    exit 0
  fi
  echo "Aether is not installed and GitHub is unreachable" >&2
  exit 1
fi

if [ "$new" != "$have" ] || [ ! -x "$AETHER_DIR/aether" ]; then
  download "$new"
else
  echo "Aether $have is up to date"
fi
