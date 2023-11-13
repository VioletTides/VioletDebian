#!/bin/bash

DOTFILES_DIR="$HOME/path"
FONT_DIR="/usr/share/fonts"

# Create a fonts directory if it doesn't exist
sudo mkdir -p "$FONT_DIR"

#Copy Mononoki font ifles into the font directory
sudo cp $DOTFILES_DIR/fonts/"* "$FONT_DIR/"

# Update the font cache
sudo fc-cache -f -v

# Install Vim
sudo apt-get update
sudo apt-get install -y vim

# Install Alacritty
sudo apt-get install -y alacritty
echo "Setup Complete!"
