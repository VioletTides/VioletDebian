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

# Update package lists and install necessary dependencies including OpenSSL
apt update
apt install -y \
    git \
    build-essential \
    cmake \
    libgtk-3-dev \
    libglm-dev \
    libxxf86vm-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    pkg-config \
    libfontconfig1-dev \
    libxkbcommon-x11-dev \
    libwayland-dev \
    libwayland-cursor0 \
    libwayland-egl1 \
    libssl-dev

# Clone the kitty repository from GitHub
git clone https://github.com/kovidgoyal/kitty.git
cd kitty

# Install kitty
make
make install

# Add a symbolic link to use kitty as default terminal
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $(which kitty) 50

# Print installation status and version information to both terminal and log file
{
    echo "Kitty Installation Complete"
    echo -e "\nKitty Version:"
    kitty --version
} | tee -a "$LOG_FILE"

echo "Kitty installation complete. Log saved to $LOG_FILE."
