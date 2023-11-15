#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
# Set REPO_DIR relative to the script directory
REPO_DIR=$(pwd)
ALACRITTY_DIR="$HOME/.config/alacritty" # The directory where the Alacritty config file is stored

git clone https://github.com/alacritty/alacritty.git
cd alacritty

# Install Rust using rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup override set stable
rustup update stable

# Install Alacritty dependencies
apt install cargo cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    
# Build Alacritty
cargo build --release

# Install Alacritty (you may need to adjust the path if desired)
sudo cp "target/release/alacritty" "/usr/local/bin"

# Remove Alacritty repository
cd "$REPO_DIR" || exit
rm -rf alacritty

# Configure alacritty
sudo mkdir -p "$ALACRITTY_DIR"
sudo cp "$REPO_DIR/config/alacritty/alacritty.yml" "$ALACRITTY_DIR/alacritty.yml"

# Set Alacritty as the default terminal
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 50
sudo update-alternatives --config x-terminal-emulator
