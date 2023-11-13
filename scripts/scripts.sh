#!/bin/bash

# Change these directories to what you have
ROOT_DIR="../"
FONT_DIR="/usr/share/fonts"
DWM_DIR="$HOME./suckless/dwm"
ALACRITTY_DIR=""
VIM_DIR=""
RANGER_DIR=""

# Create a fonts directory if it doesn't exist
sudo mkdir -p "$FONT_DIR"

# Copy Mononoki font files into the font directory
sudo cp "$ROOT_DIR/fonts/"* "$FONT_DIR/"

# Update the font cache
sudo fc-cache -f -v

# INSTALL PROGRAMS

# Install Vim, Alacritty, Ranger, and Zsh
sudo apt-get update
sudo apt-get install -y vim alacritty ranger zsh

# Set Zsh as the default shell
chsh -s "$(which zsh)"

# COPY CONFIGS INTO DEFAULT LOCATIONS

# Copy Alacritty config file
cp "$ROOT_DIR/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"

# Setup Vim-Plug and install if not already
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    mkdir -p "$HOME/.vim/autoload"
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Copy Vim config file
cp "$ROOT_DIR/vimrc" "$HOME/.vimrc"

# Install Vim plugins using Vim-Plug
vim +PlugInstall +qall

echo "Setup Complete!"
