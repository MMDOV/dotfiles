#!/usr/bin/env bash
# Install a package and deploy its tracked config.
#
#   install.sh <package> [config-dir]
#
# config-dir defaults to the package name. They differ when the package is a
# VCS build: waybar-git ships the config that lives under dotfiles/config/waybar.

set -euo pipefail

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

print_msg() {
    echo -e "${GREEN}[*] $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}[!] $1${NC}"
}

print_error() {
    echo -e "${RED}[!] $1${NC}"
    exit 1
}

pkg="${1:?usage: install.sh <package> [config-dir]}"
confdir="${2:-$pkg}"

if ! command -v paru &>/dev/null; then
    "$REPO_ROOT/install/core/paru.sh"
fi

# A -git package and its stable counterpart conflict. pacman asks whether to
# remove the other one, --noconfirm answers no, and the transaction aborts with
# "unresolvable package conflicts". Clear the conflicting package first so the
# install is a decision made here rather than a prompt nobody sees.
if [[ $pkg == *-git ]]; then
    stable="${pkg%-git}"
    # Exact-name match, not `pacman -Qq "$stable"`. A -git package normally
    # *provides* its stable name, so that query resolves right back to the
    # package being installed — and removing it would uninstall the thing we
    # are here to install.
    if pacman -Qq | grep -qx "$stable"; then
        print_warn "$stable conflicts with $pkg; removing it first"
        sudo pacman -Rdd --noconfirm "$stable"
    fi
fi

print_msg "Installing $pkg"
paru -S --noconfirm --needed "$pkg" || print_error "Failed to install $pkg"

if [ -d "$REPO_ROOT/dotfiles/config/$confdir" ]; then
    "$REPO_ROOT/scripts/utils/update-config.sh" config "$confdir"
else
    print_warn "no tracked config at dotfiles/config/$confdir, skipping config sync"
fi
