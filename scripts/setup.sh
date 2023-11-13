#!/bin/bash

ROOT_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
FONT_DIR="/usr/share/fonts"
SUCKLESS_DIR="$HOME/.suckless"
XINITRC_DIR="$HOME"
XSESSIONS_DIR="/usr/share/xsessions/"
ALACRITTY_DIR="$HOME/.config/alacritty"
VIM_DIR="$HOME"
RANGER_DIR="$HOME/.config/ranger"

mkdir -p "$CONFIG_DIR"

sudo apt-get update
sudo apt-get install -y build-essential libx11-dev libxinerama-dev libxft-dev libharfbuzz-dev git
sudo apt-get install -y xserver-xorg-core xserver-xorg-video-intel xinit x11-xserver-utils

mkdir -p "$SUCKLESS_DIR"
git clone https://git.suckless.org/dwm "$SUCKLESS_DIR/dwm"
git clone https://git.suckless.org/dmenu "$SUCKLESS_DIR/dmenu"

echo "exec dwm" >> "$XINITRC_DIR/.xinitrc"

sudo cp "$ROOT_DIR/config/dwm/dwm.desktop" "/usr/share/xsessions"

# Install Vim, Alacritty, Ranger, zsh, etc
sudo apt-get install -y vim alacritty ranger zsh firefox-esr pipewire amixer

# Set Zsh as the default shell
chsh -s "$(which zsh)"

# Copy Alacritty config file
cp "$ROOT_DIR/config/alacritty/alacritty.yml" "$ALACRITTY_DIR/alacritty.yml"

# Copy Ranger config files
cp -r "$ROOT_DIR/config/ranger" "$RANGER_DIR"

# Setup Vim-Plug and install if not already
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    mkdir -p "$HOME/.vim/autoload"
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Copy Vim config file
cp "$ROOT_DIR/vimrc" "$VIM_DIR/.vimrc"

# Install Vim plugins using Vim-Plug
vim +PlugInstall +qall

# INSTALL FONTS
# Create a fonts directory if it doesn't exist
if [ -d "$FONT_DIR" ]; then
    echo "Font directory already exists, continuing..."
else
    sudo mkdir -p "$FONT_DIR"
fi

# Copy Mononoki font files into the font directory
sudo cp "$ROOT_DIR/fonts/"* "$FONT_DIR/"

# Update the font cache
sudo fc-cache -f -v

cd "$SUCKLESS_DIR/dwm" || exit
sudo make install clean
cd "$SUCKLESS_DIR/dmenu" || exit
sudo make install clean

echo "Setup Complete!"
start
