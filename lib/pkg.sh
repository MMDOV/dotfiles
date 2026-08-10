#!/usr/bin/env bash
# Package installation helpers.
#
#   source "$REPO_ROOT/lib/pkg.sh"
#   aur_install waybar-git mako fuzzel

[ -n "${PKG_LIB_LOADED:-}" ] && return 0
PKG_LIB_LOADED=1

# Suffixes that mark a VCS package whose version is computed at build time.
PKG_DEVEL_SUFFIXES="git svn hg bzr cvs darcs fossil always"

pkg_is_devel() {
  local name="$1" s
  for s in $PKG_DEVEL_SUFFIXES; do
    [ "${name%-$s}" != "$name" ] && return 0
  done
  return 1
}

# Exact-name check. `pacman -Qq <name>` resolves through "provides", so a -git
# package that provides its stable name would make the stable name look
# installed, and vice versa.
pkg_installed() {
  pacman -Qq 2>/dev/null | grep -qx "$1"
}

# Install packages, skipping devel packages that are already present.
#
# `paru --needed` does not skip them: it compares the installed version against
# the pkgver declared in the AUR's .SRCINFO, which for a VCS package is only a
# snapshot from whenever the maintainer last regenerated it. A locally built
# tokyonight-gtk-theme-git is r96 while the AUR still declares r70, so --needed
# sees "older" and queues a rebuild every run — displayed as a confusing
# apparent downgrade, and a full recompile each time for no change.
#
# Installing is this script's job; updating devel packages is `paru -Syu`'s,
# which consults paru's devel database and gets it right.
aur_install() {
  local wanted=() skipped=() p
  for p in "$@"; do
    if pkg_is_devel "$p" && pkg_installed "$p"; then
      skipped+=("$p")
    else
      wanted+=("$p")
    fi
  done

  [ ${#skipped[@]} -gt 0 ] &&
    echo "[=] already installed, leaving to 'paru -Syu': ${skipped[*]}"

  [ ${#wanted[@]} -eq 0 ] && return 0
  paru -S --noconfirm --needed "${wanted[@]}"
}
