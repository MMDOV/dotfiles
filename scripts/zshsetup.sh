#!/usr/bin/env bash

set -e

sudo pacman -S --noconfirm --needed zsh eza

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
# im dumb dont judge me
alias claer='clear'
alias ls='eza -lh --group-directories-first --icons=auto'
alias umirrors='sudo reflector \
  --protocol https \
  --age 5 \
  --delay 0.25 \
  --sort rate \
  --fastest 10 \
  --save /etc/pacman.d/mirrorlist \
  --threads 5'
# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'


alias dotmmd='~/personal/scripts/update-config.sh'
pdot() {
    ~/personal/scripts/commitpush.sh "$@"
}
# Pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


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
