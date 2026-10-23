#!/usr/bin/env bash

set -euo pipefail

# Morning gate: after login, the desktop stays behind a lock screen that wants a one-time code
# from the phone's authenticator app. The phone lives out of the bedroom, so getting the code
# means getting up first.
#
#   setup   make the secret, show a QR code for the phone, install the PAM service (sudo)
#   lock    what the session start runs; locks once per boot, does nothing if not set up
#   status  show what is installed
#   remove  take it all away (sudo)
#
# hyprlock runs as the user, so pam_oath does too: the secret has to be readable by the user
# (and pam_oath saves its last-used code next to it). This is a speed bump, not a vault.
# The way out when the phone is gone: Ctrl+Alt+F3, log in, `pkill -USR1 hyprlock`.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOCK_CONF="$REPO_ROOT/dotfiles/config/hypr/hyprlock-morning.conf"
DATA_DIR="$HOME/.local/share/morning-gate"
OATH_FILE="$DATA_DIR/users.oath"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/morning-gate-boot"
PAM_FILE="/etc/pam.d/hyprlock-morning"
ISSUER="Morning gate"

installed() { [ -f "$PAM_FILE" ] && [ -s "$OATH_FILE" ]; }

setup() {
  if installed && [ "${1:-}" != "--reset" ]; then
    echo "Already set up. Use '$0 setup --reset' for a new secret (you must re-scan the QR code)." >&2
    exit 1
  fi

  command -v qrencode >/dev/null || sudo pacman -S --needed --noconfirm qrencode
  command -v oathtool >/dev/null || sudo pacman -S --needed --noconfirm oath-toolkit

  local secret b32 uri uid
  secret="$(openssl rand -hex 20)"
  b32="$(python3 -I -c 'import base64,sys; print(base64.b32encode(bytes.fromhex(sys.argv[1])).decode())' "$secret")"
  uri="otpauth://totp/${ISSUER// /%20}:$USER?secret=$b32&issuer=${ISSUER// /%20}&algorithm=SHA1&digits=6&period=30"
  uid="$(id -u)"

  install -d -m 700 "$DATA_DIR"
  install -m 600 /dev/null "$OATH_FILE"
  printf 'HOTP/T30/6 %s - %s\n' "$USER" "$secret" > "$OATH_FILE"

  # The tally lives in the user's runtime dir, so wrong codes here never lock the real password.
  sudo tee "$PAM_FILE" >/dev/null <<PAM
#%PAM-1.0
auth     required  pam_faillock.so preauth dir=/run/user/$uid deny=5 unlock_time=30
auth     [success=1 default=bad]  pam_oath.so usersfile=$OATH_FILE window=1
auth     [default=die]  pam_faillock.so authfail dir=/run/user/$uid deny=5 unlock_time=30
auth     sufficient  pam_faillock.so authsucc dir=/run/user/$uid
auth     required  pam_deny.so
account  required  pam_permit.so
PAM

  rm -f "$STATE_FILE"
  echo
  qrencode -t ANSIUTF8 "$uri"
  echo
  echo "Scan the code above with the authenticator app (time-based, 6 digits)."
  echo "If the camera will not scan it, add it by hand with this key: $b32"
}

lock() {
  installed || exit 0
  local boot
  boot="$(cat /proc/sys/kernel/random/boot_id)"
  [ "$(cat "$STATE_FILE" 2>/dev/null || true)" = "$boot" ] && exit 0
  if hyprlock -c "$LOCK_CONF"; then
    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$boot" > "$STATE_FILE"
  fi
}

status() {
  [ -f "$PAM_FILE" ] && echo "PAM service: $PAM_FILE" || echo "PAM service: missing"
  [ -s "$OATH_FILE" ] && echo "secret:      $OATH_FILE" || echo "secret:      missing"
  [ -f "$LOCK_CONF" ] && echo "lock config: $LOCK_CONF" || echo "lock config: missing"
  if [ "$(cat "$STATE_FILE" 2>/dev/null || true)" = "$(cat /proc/sys/kernel/random/boot_id)" ]; then
    echo "this boot:   already unlocked"
  else
    echo "this boot:   will ask for the code at the next session start"
  fi
}

remove() {
  sudo rm -f "$PAM_FILE"
  rm -rf "$DATA_DIR" "$STATE_FILE"
  echo "Removed. Delete the account from the authenticator app too."
}

case "${1:-}" in
  setup) shift; setup "$@" ;;
  lock) lock ;;
  status) status ;;
  remove) remove ;;
  *) echo "usage: $0 setup [--reset] | lock | status | remove" >&2; exit 2 ;;
esac
