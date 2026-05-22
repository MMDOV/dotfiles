#!/usr/bin/env bash

set -e

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_msg() {
    echo -e "${GREEN}[*] $1${NC}"
}

print_error() {
    echo -e "${RED}[!] $1${NC}"
    exit 1
}

if ! command -v paru &>/dev/null; then
    chmod +x "$REPO_ROOT/install/core/paru.sh"
    "$REPO_ROOT/install/core/paru.sh"
fi

print_msg "Installing $1"
paru -S --noconfirm --needed "$1" || print_error "Failed to install $1"

chmod +x "$REPO_ROOT/scripts/utils/update-config.sh"
"$REPO_ROOT/scripts/utils/update-config.sh" config "$1"
