#!/bin/bash
# Get the directory where the script resides
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
# Set REPO_DIR relative to the script directory
REPO_DIR="$SCRIPT_DIR/.."

CONFIG_DIR="$HOME/.config" # The directory where config files are stored
FONT_DIR="/usr/share/fonts" # The directory where fonts are stored
SUCKLESS_DIR="$HOME/.suckless" # The directory where suckless programs are stored
XINITRC_DIR="$HOME" # The directory where the .xinitrc file is stored
XSESSIONS_DIR="/usr/share/xsessions/" # The directory where the .desktop files are stored
ALACRITTY_DIR="$HOME/.config/alacritty" # The directory where the Alacritty config file is stored
VIM_DIR="$HOME" # The directory where the Vim config file is stored
RANGER_DIR="$HOME/.config/ranger" # The directory where the Ranger config files are stored


# Install Rust using rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add Rust to PATH (this might be needed to use Rust immediately in the script)
source $HOME/.cargo/env

# Install Alacritty dependencies
sudo apt-get install -y cmake cargo pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3

# Clone Alacritty repository
cd "$REPO_DIR" || exit
git clone https://github.com/alacritty/alacritty.git

# Build and install Alacritty
cd alacritty || exit
    
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
