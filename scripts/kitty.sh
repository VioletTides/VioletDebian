#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
    exit 1
fi

# Define the log file path and name
LOG_FILE="kitty_installation.log"

# Check if kitty is already installed
if command -v kitty &>/dev/null; then
    echo "Kitty is already installed." | tee -a "$LOG_FILE"
    exit 0
fi

curl -L https://sw.kovidgoyal.net/kitty/aptk.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kovidgoyal-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/kovidgoyal-archive-keyring.gpg] https://sw.kovidgoyal.net/kitty/nightly/apt buster main' | tee /etc/apt/sources.list.d/kitty.list
apt update
apt install kitty -y


# Add a symbolic link to use kitty as default terminal
update-alternatives --set x-terminal-emulator "$(which kitty)"

# Print installation status and version information to both terminal and log file
{
    echo "Kitty Installation Complete"
    echo -e "\nKitty Version:"
    kitty --version
} | tee -a "$LOG_FILE"

echo "Kitty installation complete. Log saved to $LOG_FILE."
