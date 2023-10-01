#!/bin/bash

# Step 1: Check the architecture
if [[ $(uname -m) != "aarch64" ]]; then
    echo "This script is designed for an aarch64 architecture. Aborting."
    exit 1
fi

# Step 2: Check for apt
if ! command -v apt &> /dev/null; then
    echo "This script requires a Debian-based system with apt. Aborting."
    exit 1
fi

# If both checks pass, proceed to create the directory and install the packages
mkdir -p "$HOME/alt-server"

sudo apt update

# Install the packages
sudo apt install -y \
  libavahi-compat-libdnssd-dev \
  usbmuxd \
  ninja-build \
  ldc \
  libplist-dev \
  libimobiledevice-dev \
  libgtk-3-0 \
  dub \
  openssl \
  build-essential \
  pkg-config \
  checkinstall \
  git \
  autoconf \
  automake \
  libtool-bin \
  libusbmuxd-dev \
  libimobiledevice-glue-dev \
  libssl-dev \
  usbmuxd \
  curl

# Installing after making libplist
echo "Installing libplist..."
echo "This process requires sudo access."
git clone https://github.com/libimobiledevice/libplist.git
cd libplist
./autogen.sh
make
sudo make install
cd ..

# Installing after making libimobiledevice-glue
echo "Installing libimobiledevice-glue..."
echo "This process requires sudo access."
git clone https://github.com/libimobiledevice/libimobiledevice-glue.git
cd libimobiledevice-glue
./autogen.sh
make
sudo make install
cd ..

# Check for rustup and install if not present
if ! command -v rustup &> /dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# Setup rust stable toolchain
rustup toolchain install stable
rustup default stable

# Edit the usbmuxd.service file
echo "Editing usbmuxd.service..."
echo -e "\n# Taken from https://bugs.archlinux.org/task/31056\n[Install]\nWantedBy=multi-user.target" | sudo tee -a /lib/systemd/system/usbmuxd.service

# Enable and start the required services
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now usbmuxd

# Rest TODO
