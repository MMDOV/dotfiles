#!/usr/bin/env bash

BASHRC="$HOME/.bashrc"

if [ ! -d "$HOME/.oh-my-bash" ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
else
    echo "Oh My Bash already installed, skipping..."
fi

theme="robbyrussell"
sed -i "s/^OSH_THEME=\".*\"/OSH_THEME=\"$theme\"/" "$HOME/.bashrc"

CUSTOM_CONFIG=$(
    cat <<'EOF'
# Custom aliases and functions
alias vim='nvim'
alias update='sudo pacman -Syu'
alias btc='~/personal/scripts/pair_connect.sh 9C:19:C2:1B:CD:0D'
mkenv() {
	~/personal/scripts/mkdir.sh "$@"
}
alias dotmamad='~/personal/scripts/update-config.sh'
alias y='yazi'
alias yl='yazi .'
alias commitdot='~/personal/scripts/commitpush.sh "fixes"'
EOF
)

if grep -Fx "$CUSTOM_CONFIG" "$BASHRC" >/dev/null; then
    echo "Custom configurations already present in .bashrc, skipping..."
    exit 0
fi

echo "Adding custom configurations to .bashrc..."
echo "" >>"$BASHRC"
echo "$CUSTOM_CONFIG" >>"$BASHRC"
