#!/usr/bin/env bash

if ! command -v rustup &>/dev/null; then
  echo "rustup not found, installing..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  if [ $? -eq 0 ]; then
    echo "rustup installed successfully"
    source "$HOME/.cargo/env"
  else
    echo "Failed to install rustup"
    exit 1
  fi
else
  echo "rustup is already installed"
fi

if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

echo "Ensuring essential Rust components are installed..."
rustup component add rust-analyzer rust-src clippy rustfmt

echo "Rust setup complete."
