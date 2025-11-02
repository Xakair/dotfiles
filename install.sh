#!/bin/bash

set -e  # Exit immediately if a command fails
set -u  # Treat unset variables as errors
set -o pipefail  # Prevent errors in a pipeline from being masked

INSTALL_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/xakair/dotfiles.git"
CFG_DIR="$INSTALL_DIR/cfg"
PACKAGES=(
    sway
    swaybg
    autotiling-rs
    ghostty
    nvim
    helium-browser
    yazi
    wofi
    zsh
    kanshi
    stow
    powertop
    wl-clipboard
    cliphist
    tmux
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

echo "Creating symlinks..."
if [ -d "$CFG_DIR" ]; then
    echo "Linking configuration files from $CFG_DIR to $HOME"

    # Link top-level files and directories (excluding .config)
    find "$CFG_DIR" -mindepth 1 -maxdepth 1 ! -name ".config" | while read -r src; do
        rel_path="$(basename "$src")"
        dest="$HOME/$rel_path"

        mkdir -p "$(dirname "$dest")"

        # Backup existing non-symlinks
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            echo "Backing up existing $dest to $dest.bak"
            mv "$dest" "$dest.bak"
        fi

        ln -sfn "$src" "$dest"
        echo "Linked $dest -> $src"
    done

    # Handle contents of .config separately
    if [ -d "$CFG_DIR/.config" ]; then
        echo "Linking contents of .config..."
        mkdir -p "$HOME/.config"
        find "$CFG_DIR/.config" -mindepth 1 -maxdepth 1 | while read -r src; do
            rel_path="$(basename "$src")"
            dest="$HOME/.config/$rel_path"

            # Backup existing non-symlinks
            if [ -e "$dest" ] && [ ! -L "$dest" ]; then
                echo "Backing up existing $dest to $dest.bak"
                mv "$dest" "$dest.bak"
            fi

            ln -sfn "$src" "$dest"
            echo "Linked $dest -> $src"
        done
    fi

    echo "✅ Symlink setup complete."
else
    echo "⚠️  Config directory $CFG_DIR not found. Skipping symlinks."
fi

if command_exists zsh; then
    echo "Installing zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi


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


