#!/bin/bash

# Change these directories to what you have
ROOT_DIR="../"
FONT_DIR="/usr/share/fonts"
SUCKLESS_DIR="$HOME./suckless"
ALACRITTY_DIR="$HOME./config/alacritty"
VIM_DIR="$HOME"
RANGER_DIR="$HOME./config/ranger"

DIRECTORIES=("$ROOT_DIR" "$FONT_DIR" "$SUCKLESS_DIR" "$ALACRITTY_DIR" "$VIM_DIR" "$RANGER_DIR")
DIRECTORIES_STR=("fonts" "suckless" "alacritty config" "vim config" "ranger config")
USER_DIRECTORIES=()

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

# INSTALL PROGRAMS

# Install Vim, Alacritty, Ranger, and Zsh
sudo apt-get update
sudo apt-get install -y vim alacritty ranger zsh

# Set Zsh as the default shell
chsh -s "$(which zsh)"

# COPY CONFIGS INTO DEFAULT LOCATIONS


for dir in ${DIRECTORIES[@]}; do
	read -p "Enter the path to your $DIRECTORIES_STR, or leave blank and press enter to continue with the default \"$DIRECTORIES\":" directory_input
	directory_input=$(echo "$directory_input" | tr -d '[:space:]')
	if [ -z "$directory_input" ]; then
		$USER_DIRECTORIES+=("$dir")
	else
		$USER_DIRECTORIES+=("$directory_input")
	fi
done;

$DIRECTORIES=("${USER_DIRECTORIES[@]}")




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
