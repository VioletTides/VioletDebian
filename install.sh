#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
# Set REPO_DIR relative to the script directory
REPO_DIR=$(pwd)

apt update
apt upgrade -y

CONFIG_DIR="$HOME/.config" # The directory where config files are stored
FONT_DIR="$HOME/$username/.fonts" # The directory where fonts are stored
SUCKLESS_DIR="$HOME/.suckless" # The directory where suckless programs are stored
XINITRC_DIR="$HOME" # The directory where the .xinitrc file is stored
XSESSIONS_DIR="/usr/share/xsessions/" # The directory where the .desktop files are stored
#ALACRITTY_DIR="$HOME/.config/alacritty" # The directory where the Kitty config file is stored
VIM_DIR="$HOME" # The directory where the Vim config file is stored
RANGER_DIR="$HOME/.config/ranger" # The directory where the Ranger config files are stored

mkdir -p $CONFIG_DIR
mkdir -p $FONT_DIR
mkdir -p $SUCKLESS_DIR
mkdir -p $RANGER_DIR
mkdir -p /home/$username/Pictures   
mkdir -p /home/$username/Pictures/backgrounds

chown -R $username:$username /home/$username

# Install basics
apt-get install -y feh picom curl zsh wget firefox-esr pulseaudio unzip

# Set Zsh as the default shell
chsh -s "$(which zsh)"

install_suckless() {
    # Install dependencies for dwm and dmenu
    apt-get update
    apt-get install -y make build-essential libx11-dev libxft-dev libxinerama-dev libfreetype6-dev libfontconfig1-dev

    mkdir -p "$SUCKLESS_DIR"
    cd "$SUCKLESS_DIR" || exit
    git clone https://git.suckless.org/dwm
    git clone https://git.suckless.org/dmenu

    # Build and install dwm
    cd dwm || exit
    make clean install
    # Build and install dmenu
    cd ../dmenu || exit
    make clean install

    # Copy the config.h files to the dwm and dmenu directories
    cp "$REPO_DIR/config/suckless/dwm/config.h" "$SUCKLESS_DIR/dwm/config.h"
    cp "$REPO_DIR/config/suckless/dmenu/config.h" "$SUCKLESS_DIR/dmenu/config.h"

    # Install dependencies for xorg
    apt-get install -y xorg xserver-xorg xserver-xorg-core xserver-xorg-video-intel xinit x11-xserver-utils

    mkdir -p "$XINITRC_DIR"
    mkdir -p "$XSESSIONS_DIR"
    # Create and init the .xinitrc file in the specified directory
    echo "exec dwm" >> "$XINITRC_DIR/.xinitrc"
    # Copy the .desktop file to the specified directory
    cp "$REPO_DIR/config/suckless/dwm/dwm.desktop" "$XSESSIONS_DIR"
}

install_kitty() {
    bash scripts/kitty.sh
}

### INSTALL AND CONFIGURE RANGER ###
install_ranger() {
    sudo apt-get install -y ranger w3m-img highlight atool poppler-utils mediainfo
    # Configure Ranger
    sudo mkdir -p "$RANGER_DIR"
    sudo cp "$REPO_DIR/config/ranger/rc.conf" "$RANGER_DIR/rc.conf"
}

### INSTALL AND CONFIGURE VIM ###
install_vim() { 
    # Setup Vim-Plug and install if not already
    if [ -f "$HOME/.vim/autoload/plug.vim" ]; then
        echo "Vim-Plug already installed, continuing..."
    else
        echo "Installing Vim-Plug..."
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    # Configure Vim
    sudo cp "$REPO_DIR/config/vim/.vimrc" "$VIM_DIR/.vimrc"

    # Install Vim plugins using Vim-Plug
    vim +PlugInstall +qall
}

### INSTALL AND CONFIGURE FONTS ###
install_fonts() {
    # Go into the repo directory
    cd $REPO_DIR

    # Install the Mononoki font
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Mononoki.zip
    unzip Mononoki.zip -d $FONT_DIR

    # Update the font cache
    fc-cache -f -v

    # Clean up the Mononoki zip from the current directory
    rm ./Mononoki.zip
}

install_fonts
#install_suckless
#install_kitty
#install_ranger
#install_vim
chown $username:$username $FONTDIR*

echo "Setup Complete!"
startx
