#!/bin/bash

set -e  # Exit immediately if a command fails
set -u  # Treat unset variables as errors
set -o pipefail  # Prevent errors in a pipeline from being masked

INSTALL_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/xakair/dotfiles.git"
PACKAGES=(
    sway
    swaybg
    ghostty
    nvim
    helium-browser
    yazi
    wofi
    zsh
    kanshi
    stow
    powertop
)

command_exists () {
  # command -v returns 0 if the command exists, non-zero otherwise.
  command -v "$1" &>/dev/null
}

# Prevent running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root."
    exit 1
fi

sudo pacman -S --needed base-devel git --noconfirm

aur_helper="paru"

if command_exists paru; then
    echo "paru is already installed"
elif command_exists yay; then
    aur_helper="yay"
else
    echo "Installing Paru"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
    echo "paru installation complete"
fi

if [ -d "$INSTALL_DIR" ]; then
    echo "Updating dotfiles..."
    git -C "$INSTALL_DIR" pull
else
    echo "Cloning Dotfiles..."
    git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
fi

echo "Installing required packages..."
$aur_helper -Syy --needed --devel --noconfirm "${PACKAGES[@]}" || true


echo "Stowing!..."
STOW_ROOT_DIR="$INSTALL_DIR/cfg"
cd "$STOW_ROOT_DIR"
for package in */; do
    package_name="${package%/}"
    echo "   -Stowing $package_name..."
    stow -t "$HOME" -Rv --adopt "$package_name"
done


echo "Installing zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"



# Network services handling
echo "Configuring network services..."

# Disable iwd if enabled/active
if systemctl is-enabled --quiet iwd 2>/dev/null || systemctl is-active --quiet iwd 2>/dev/null; then
    echo "Disabling iwd..."
    sudo systemctl disable --now iwd
else
    echo "iwd is already disabled."
fi

# Enable NetworkManager if not enabled
if ! systemctl is-enabled --quiet NetworkManager 2>/dev/null; then
    echo "Enabling NetworkManager..."
    sudo systemctl enable NetworkManager
else
    echo "NetworkManager is already enabled."
fi

# Start NetworkManager if not running
if ! systemctl is-active --quiet NetworkManager 2>/dev/null; then
    echo "Starting NetworkManager..."
    sudo systemctl start NetworkManager
else
    echo "NetworkManager is already running."
fi


