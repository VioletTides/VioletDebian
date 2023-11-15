#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
# Set REPO_DIR relative to the script directory
REPO_DIR=$(PWD)

apt update
apt upgrade -y

cd $REPO_DIR

CONFIG_DIR="$HOME/.config" # The directory where config files are stored
FONT_DIR="/usr/share/fonts" # The directory where fonts are stored
SUCKLESS_DIR="$HOME/.suckless" # The directory where suckless programs are stored
XINITRC_DIR="$HOME" # The directory where the .xinitrc file is stored
XSESSIONS_DIR="/usr/share/xsessions/" # The directory where the .desktop files are stored
ALACRITTY_DIR="$HOME/.config/alacritty" # The directory where the Alacritty config file is stored
VIM_DIR="$HOME" # The directory where the Vim config file is stored
RANGER_DIR="$HOME/.config/ranger" # The directory where the Ranger config files are stored

# Install basics
sudo apt-get install -y curl zsh wget firefox-esr amixer pulseaudio

# Set Zsh as the default shell
chsh -s "$(which zsh)"

install_suckless() {
    # Install dependencies for dwm and dmenu
    sudo apt-get update
    sudo apt-get install -y make build-essential libx11-dev libxft-dev libxinerama-dev libfreetype6-dev libfontconfig1-dev

    mkdir -p "$SUCKLESS_DIR"
    cd "$SUCKLESS_DIR" || exit
    git clone https://git.suckless.org/dwm
    git clone https://git.suckless.org/dmenu

    # Build and install dwm
    cd dwm || exit
    sudo make clean install
    # Build and install dmenu
    cd ../dmenu || exit
    sudo make clean install

    # Copy the config.h files to the dwm and dmenu directories
    sudo cp "$REPO_DIR/config/suckless/dwm/config.h" "$SUCKLESS_DIR/dwm/config.h"
    sudo cp "$REPO_DIR/config/suckless/dmenu/config.h" "$SUCKLESS_DIR/dmenu/config.h"

    # Install dependencies for xorg
    sudo apt-get install -y xorg xserver-xorg xserver-xorg-core xserver-xorg-video-intel xinit x11-xserver-utils

    mkdir -p "$XINITRC_DIR"
    mkdir -p "$XSESSIONS_DIR"
    # Create and init the .xinitrc file in the specified directory
    echo "exec dwm" >> "$XINITRC_DIR/.xinitrc"
    # Copy the .desktop file to the specified directory
    sudo cp "$REPO_DIR/config/suckless/dwm/dwm.desktop" "$XSESSIONS_DIR"
}

install_alacritty() {
    # Install Alacritty dependencies
    sudo apt-get install -y cmake rust cargo pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3

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
    # Create a fonts directory if it doesn't exist
    if [ -d "$FONT_DIR" ]; then
        echo "Font directory already exists, continuing..."
    else
        sudo mkdir -p "$FONT_DIR"
    fi

    # Copy Mononoki font files into the font directory
    sudo cp "$REPO_DIR/fonts/" "$FONT_DIR/"

    # Update the font cache
    sudo fc-cache -f -v
}

install_suckless
install_alacritty
install_ranger
install_vim
install_fonts

echo "Setup Complete!"
startx
