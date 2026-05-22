#!/usr/bin/env bash

set -e

sudo pacman -S --noconfirm --needed zsh eza zsh-autosuggestions zsh-syntax-highlighting

chsh -s $(which zsh)

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
  echo "Oh My Zsh already installed, skipping..."
fi

ZSHRC="$HOME/.zshrc"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

CUSTOM_CONFIG=$(
  cat <<EOF
plugins=(git zsh-autosuggestions)
# Custom aliases and functions
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

if grep -Fx "$CUSTOM_CONFIG" "$ZSHRC" >/dev/null; then
  echo "Custom configurations already present in .bashrc, skipping..."
  exit 0
fi

echo "Adding custom configurations to .bashrc..."
echo "" >>"$ZSHRC"
echo "$CUSTOM_CONFIG" >>"$ZSHRC"
