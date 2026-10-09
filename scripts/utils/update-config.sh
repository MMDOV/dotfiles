#!/usr/bin/env bash

# Detect repository root
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

debug=false
configonly=false
force=false
nowm=false
with_theme=false
subconf=""

# Flags may come in any order; `config [name]` consumes the argument after it.
while [ $# -gt 0 ]; do
  case "$1" in
  --debug) debug=true ;;
  --force) force=true ;;
  --no-wm) nowm=true ;;
  --with-theme) with_theme=true ;;
  config)
    configonly=true
    if [ $# -gt 1 ]; then
      subconf=$2
      shift
    fi
    ;;
  esac
  shift
done

# no-wm mode leaves the session layer alone: see lib/scope.sh for what that
# excludes. With --no-wm off, scope_skips never matches and nothing changes.
SCOPE_NO_WM=$nowm
SCOPE_WITH_THEME=$with_theme
# shellcheck source=/dev/null
source "$REPO_ROOT/lib/scope.sh"
drift_args=(--config)
$nowm && drift_args+=(--no-wm)
$with_theme && drift_args+=(--with-theme)

# This copies repo -> system with cp -f, so any local edit under ~/.config is
# overwritten without trace. Surface that first. Only content conflicts on
# tracked files count; generated state living alongside them is ignored.
if ! $debug && ! $force && [ -z "$subconf" ]; then
  if ! "$REPO_ROOT/scripts/utils/check-drift.sh" "${drift_args[@]}" >/dev/null 2>&1; then
    echo "Local changes would be overwritten:"
    "$REPO_ROOT/scripts/utils/check-drift.sh" "${drift_args[@]}" | grep -A3 CONFLICT || true
    echo
    read -rp "Overwrite them? [y/N] " reply
    case "$reply" in
    [yY]*) ;;
    *)
      echo "Aborted. Re-run with --force to skip this check."
      exit 1
      ;;
    esac
  fi
fi

copyandreplace_one() {
  local item="$1" destpath="$2"
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
}

copyandreplace() {
  local item
  shopt -s dotglob
  for item in "$1"/*; do
    copyandreplace_one "$item" "$2"
  done
}

# Like copyandreplace, but one top-level entry at a time so scope_skips can
# drop the ones this mode does not deploy.
copyconfigscoped() {
  local item name
  shopt -s dotglob
  for item in "$1"/*; do
    name="$(basename "$item")"
    if scope_skips "$name"; then
      echo "skipping $name (not deployed in no-wm mode)"
      continue
    fi
    copyandreplace_one "$item" "$2"
  done
}

# Claude Code settings are merged into the live file instead of replaced, so
# keys that only exist locally (e.g. work-specific autoMode) survive. Tracked
# keys win; keys removed from the repo copy are not removed locally.
mergeclaudesettings() {
  local src="$REPO_ROOT/dotfiles/home/.claude/settings.json"
  local dest="$HOME/.claude/settings.json"
  [ -f "$src" ] || return 0
  if $debug; then
    echo "merging $src into $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if [ ! -f "$dest" ]; then
    cp -fvp "$src" "$dest"
    return 0
  fi
  local merged
  if merged="$(jq -s '.[0] * .[1]' "$dest" "$src")"; then
    printf '%s\n' "$merged" >"$dest"
    echo "merged '$src' -> '$dest'"
  else
    echo "failed to merge $src, left $dest untouched" >&2
  fi
}

copyhome() {
  local item rel
  while IFS= read -r -d '' item; do
    rel="${item#"$REPO_ROOT/dotfiles/home/"}"
    [ "$rel" = ".claude/settings.json" ] && continue
    if $debug; then
      echo "copying $item to $HOME/$rel"
    else
      mkdir -p "$(dirname "$HOME/$rel")"
      cp -fvp "$item" "$HOME/$rel"
    fi
  done < <(find "$REPO_ROOT/dotfiles/home" -type f -print0)
  mergeclaudesettings
}

if [ -z "$subconf" ]; then
  if $nowm; then
    copyconfigscoped "$REPO_ROOT/dotfiles/config" "$HOME/.config"
  else
    copyandreplace "$REPO_ROOT/dotfiles/config" "$HOME/.config"
    hyprctl reload
    command -v hyprshade >/dev/null 2>&1 && hyprshade auto
  fi

else
  mkdir -p "$HOME/.config/$subconf"
  copyandreplace "$REPO_ROOT/dotfiles/config/$subconf" "$HOME/.config/$subconf"
fi

if ! $configonly; then
  copyandreplace "$REPO_ROOT/dotfiles/local/bin" "$HOME/.local/bin"
  copyandreplace "$REPO_ROOT/dotfiles/local/share" "$HOME/.local/share"
  copyhome
  # Copy tmux stuff
  cp -f "$REPO_ROOT/tmux/sessionizer" "$HOME/.local/bin/tmux-sessionizer"
  cp -f "$REPO_ROOT/tmux/.tmux.conf" "$HOME"
  chmod +x "$HOME/.local/bin/tmux-sessionizer"
fi

# The session is not ours in no-wm mode; there is nothing to reload.
if ! $nowm; then
  # Tracked configs include colors that `look` generates (they are not in the
  # repo), so render them now: first run applies the default look, later runs
  # re-apply the current one.
  if [ -x "$HOME/.local/bin/look" ] && ! $debug; then
    "$HOME/.local/bin/look" apply || echo "look apply failed; run it by hand" >&2
  fi
  hyprctl reload 2>/dev/null || true
  command -v hyprshade >/dev/null 2>&1 && hyprshade auto
fi
