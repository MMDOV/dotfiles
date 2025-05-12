#!/usr/bin/env bash

set -e

sudo pacman -S --noconfirm --needed zsh

chsh -s $(which zsh)

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
else
    echo "Oh My Zsh already installed, skipping..."
fi

ZSHRC="$HOME/.zshrc"

CUSTOM_CONFIG=$(
    cat <<'EOF'
# Custom aliases and functions
alias vim='nvim'
alias update='paru -Syu --noconfirm'
alias btc='~/personal/scripts/pair_connect.sh 9C:19:C2:1B:CD:0D'
mkenv() {
	~/personal/scripts/mkenv.sh "$@"
}
alias dotmamad='~/personal/scripts/update-config.sh'
pdot() {
    ~/personal/scripts/commitpush.sh "$@"
}
EOF
)

if grep -Fx "$CUSTOM_CONFIG" "$ZSHRC" >/dev/null; then
    echo "Custom configurations already present in .bashrc, skipping..."
    exit 0
fi

echo "Adding custom configurations to .bashrc..."
echo "" >>"$ZSHRC"
echo "$CUSTOM_CONFIG" >>"$ZSHRC"
