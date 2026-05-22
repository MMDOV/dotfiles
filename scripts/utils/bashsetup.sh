#!/usr/bin/env bash

BASHRC="$HOME/.bashrc"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [ ! -d "$HOME/.oh-my-bash" ]; then
  echo "Installing Oh My Bash..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
else
  echo "Oh My Bash already installed, skipping..."
fi

# Set the theme
theme="robbyrussell"
if grep -q "^OSH_THEME=" "$BASHRC"; then
  sed -i "s/^OSH_THEME=\".*\"/OSH_THEME=\"$theme\"/" "$BASHRC"
else
  echo "OSH_THEME=\"$theme\"" >>"$BASHRC"
fi

CUSTOM_CONFIG=$(
  cat <<EOF
alias vim='nvim'
# im dumb dont judge me
alias claer='clear'
alias ls='eza -lh --group-directories-first --icons=auto'
alias umirrors='sudo reflector \
  --protocol https \
  --latest 100 \
  --sort rate \
  --fastest 15 \
  --delay 2 \
  --save "/etc/pacman.d/mirrorlist" \
  --threads 5'
# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'


alias dotmmd='$REPO_ROOT/scripts/utils/update-config.sh'
pdot() {
    $REPO_ROOT/scripts/utils/commitpush.sh "\$@"
}

export TERMINAL=foot
export SUDO_EDITOR=nvim
export EDITOR=nvim

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

bindkey -v
EOF
)

if grep -Fx "$CUSTOM_CONFIG" "$BASHRC" >/dev/null; then
  echo "Custom configurations already present in .bashrc, skipping..."
  exit 0
fi

echo "Adding custom configurations to .bashrc..."
echo "" >>"$BASHRC"
echo "$CUSTOM_CONFIG" >>"$BASHRC"

echo "Setup complete! Please run 'source ~/.bashrc' to apply changes."
