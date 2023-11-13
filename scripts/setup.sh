#!/bin/bash

ROOT_DIR="$HOME/dotfiles" # This just goes up one level to the "dotfiles" repo root
FONT_DIR="/usr/share/fonts"
SUCKLESS_DIR="$HOME./suckless"
ALACRITTY_DIR="$HOME./config/alacritty"
VIM_DIR="$HOME"
RANGER_DIR="$HOME./config/ranger"

DIRECTORIES=("$ROOT_DIR" "$FONT_DIR" "$SUCKLESS_DIR" "$ALACRITTY_DIR" "$VIM_DIR" "$RANGER_DIR")
DIRECTORIES_STR=("fonts" "suckless" "alacritty config" "vim config" "ranger config")
USER_DIRECTORIES=()

# COPY CONFIGS INTO DEFAULT LOCATIONS
for ((i = 0; i <  ${DIRECTORIES[@]}; i++)); do
	dir="${DIRECTORIES[$i]}"
	dir_str="${DIRECTORIES_STR[$i]}"
	read -p "Enter the path to your $dir_str, or leave blank and press enter to continue with the default \"$dir\":" directory_input
	directory_input=$(echo "$directory_input" | tr -d '[:space:]')
	USER_DIRECTORIES+=("$directory_input")
done;

DIRECTORIES=("${USER_DIRECTORIES[@]}")

sudo apt-get update
# Install dependencies for dwm
sudo apt install -y build-essential libx11-dev libxinerama-dev libxft-dev libharfbuzz-dev xorg

mkdir -p "$SUCKLESS_DIR"
git clone https://git.suckless.com/dwm "$SUCKLESS_DIR/dwm"
git clone https://git.suckless.com/dmenu "$SUCKLESS_DIR/dmenu"
cd "$SUCKLESS_DIR/dwm" || exit
sudo make install clean
cd "$SUCKLESS_DIR/dmenu" || exit
sudo make install clean



# Install Vim, Alacritty, Ranger, and zsh
sudo apt-get install -y vim alacritty ranger zsh

# Set Zsh as the default shell
chsh -s "$(which zsh)"

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

echo "Setup Complete!"
