#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user to run this script, please run sudo ./kitty" 2>&1
    exit 1
fi

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

# Print installation status and version information to terminal
echo "Kitty Installation Complete"
echo -e "\nKitty Version:"
kitty --version
