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

CONFIG_DIR="/home/$username/.config" # The directory where config files are stored
FONT_DIR="/home/$username/.fonts" # The directory where fonts are stored
SUCKLESS_DIR="/home/$username/.suckless" # The directory where suckless programs are stored
XINITRC_DIR="/home/$username/" # The directory where the .xinitrc file is stored
XSESSIONS_DIR="/usr/share/xsessions/" # The directory where the .desktop files are stored
#ALACRITTY_DIR="$HOME/.config/alacritty" # The directory where the Kitty config file is stored
VIM_DIR="/home/$username" # The directory where the Vim config file is stored
RANGER_DIR="/home/$username/.config/ranger" # The directory where the Ranger config files are stored

mkdir -p $CONFIG_DIR
mkdir -p $FONT_DIR
mkdir -p $RANGER_DIR
mkdir -p /home/$username/Pictures
mkdir -p /home/$username/Pictures/backgrounds

# Install basics
apt-get install -y feh picom curl zsh wget firefox-esr pulseaudio unzip flameshot

# Set Zsh as the default shell
chsh -s "$(which zsh)"

install_suckless() {
    cd $REPO_DIR
    # Install dependencies for dwm and dmenu
    apt-get update
    apt-get install -y make build-essential libx11-dev libxft-dev libxinerama-dev libfreetype6-dev libfontconfig1-dev
    
    mkdir -p "$SUCKLESS_DIR" || { echo "Failed to make the suckless directory"; exit 1; }
    cd "$SUCKLESS_DIR" || exit
    git clone https://git.suckless.org/dwm
    git clone https://git.suckless.org/dmenu
    
    # Build and install dwm
    cd /$SUCKLESS_DIR/dwm || { echo "Failed to cd into dwm"; exit 1; }
    make clean install || { echo "Failed to build and install dwm"; exit 1; }
    # Build and install dmenu
    cd /$SUCKLESS_DIR/dmenu || { echo "Failed to cd into dmenu"; exit 1; }
    make clean install || { echo "Failed to build and install dmenu"; exit 1; }
    
    # Copy the config.h files to the dwm and dmenu directories
    cp "$REPO_DIR/config/suckless/dwm/config.h" "$SUCKLESS_DIR/dwm/config.h" || { echo "Failed to copy dwm config.h"; exit 1; }
    #cp "$REPO_DIR/config/suckless/dmenu/config.h" "$SUCKLESS_DIR/dmenu/config.h" || { echo "Failed to copy dmenu config.h"; exit 1; }
    
    # Install dependencies for xorg
    apt-get install -y xorg xserver-xorg xserver-xorg-core xserver-xorg-video-intel xinit x11-xserver-utils
    
    mkdir -p "$XSESSIONS_DIR" || { echo "Failed to make the .desktop directory"; exit 1; }
    
    # Create and init the .xinitrc file in the specified directory
    echo "exec dwm" >> "$XINITRC_DIR/.xinitrc" || { echo "Failed to create and init the .xinitrc file"; exit 1; }
    chmod +x "$XINITRC_DIR/.xinitrc" || { echo "Failed to make the .xinitrc file executable"; exit 1; }
    
    # Create and init the .xsessions file in the specified directory
    #echo "exec /usr/bin/startx" >> "$XINITRC_DIR/.xsession" || { echo "Failed to create and init the .xsession file"; exit 1; } UNCOMMENT THIS LINE WHWEN USING A DISPLAY MANAGER
    
    # Copy the .desktop file to the specified directory
    cp "$REPO_DIR/config/suckless/dwm/dwm.desktop" "$XSESSIONS_DIR" || { echo "Failed to copy the .desktop file"; exit 1; }
    
    # Create and init the .bash_profile to start an xsession on login
    BASH_PROFILE="/home/$username/.bash_profile"
    echo 'if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then' > "$BASH_PROFILE"
    echo '    exec startx' >> "$BASH_PROFILE"
    echo 'fi' >> "$BASH_PROFILE"
    
    echo "Created .bash_profile successfully."
}

install_kitty() {
    # Check if kitty is already installed
    if command -v kitty &>/dev/null; then
        echo "Kitty is already installed."
        exit 0
    fi
    
    # Install kitty
    curl -L https://sw.kovidgoyal.net/kitty/aptk.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kovidgoyal-archive-keyring.gpg
    echo 'deb [signed-by=/usr/share/keyrings/kovidgoyal-archive-keyring.gpg] https://sw.kovidgoyal.net/kitty/nightly/apt buster main' | tee /etc/apt/sources.list.d/kitty.list
    apt update
    apt install kitty -y
    
    # Set kitty as default terminal
    update-alternatives --set x-terminal-emulator "$(which kitty)"
    
    # Remove the repo after installation
    rm -rf /kitty

    # Copy config and themes etc
    cp -r "$REPO_DIR/config/kitty/"* "$CONFIG_DIR/kitty"
    
    # Print installation status and version information to terminal
    echo "Kitty Installation Complete"
    echo -e "\nKitty Version:"
    kitty --version
}

### INSTALL AND CONFIGURE RANGER ###
install_ranger() {
    sudo apt-get install -y ranger w3m-img highlight atool poppler-utils mediainfo
    # Configure Ranger
    sudo mkdir -p "$RANGER_DIR"
    #sudo cp "$REPO_DIR/config/ranger/rc.conf" "$RANGER_DIR/rc.conf"
}

### INSTALL AND CONFIGURE VIM ###
install_vim() {
    # Install Vim
    apt install vim -y
    
    # Setup Vim-Plug and install if not already
    if [ -f "$VIM_DIR/.vim/autoload/plug.vim" ]; then
        echo "Vim-Plug already installed, continuing..."
    else
        echo "Installing Vim-Plug..."
        curl -fLo "$VIM_DIR/.vim/autoload/plug.vim" --create-dirs \
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


install_suckless
install_kitty
install_ranger
install_vim
install_fonts
chown -R $username:$username /home/$username
chown $username:$username $FONTDIR*

cd /home/$username

# Build dwm again
cd /$SUCKLESS_DIR/dwm || { echo "Failed to cd into dwm"; exit 1; }
make clean install || { echo "Failed to build and install dwm"; exit 1; }
# Build dmenu again
cd /$SUCKLESS_DIR/dmenu || { echo "Failed to cd into dmenu"; exit 1; }
make clean install || { echo "Failed to build and install dmenu"; exit 1; }

echo "Setup Complete!"
sudo reboot now
