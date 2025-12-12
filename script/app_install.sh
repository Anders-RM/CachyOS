#!/bin/bash

# Define the script directory and log file
SCRIPT_DIR="$(dirname "$(realpath "$0")")"  # Get the directory where the script is located
LOG_FILE="$SCRIPT_DIR/App_install.log"      # Set the log file path in the script directory

# Ensure the log file exists by creating the necessary directories and the log file
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Logging function to output messages with a timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# General function to run commands and log their success or failure
run_command() {
    if eval "$1"; then
        log "$2 succeeded"   # Log success if the command executes successfully
    else
        log "$2 failed"      # Log failure and exit if the command fails
        exit 1
    fi
}

# Define package lists for CachyOS
pacmanId=("vlc" "flatpak" "python-beautifulsoup4" "python-lxml" "fuse2" "axel" "aria2" "kio-admin" "fastfetch" "jq")  # Packages for pacman (removed flameshot)
cloneRepos=()       # No need to clone yay on CachyOS - it comes pre-installed
repoDirs=()         # No repository directories needed
yayId=("1password" "filen-desktop-bin" "floorp-bin" "octopi") # Packages for yay (AUR packages)
flatpakId=()        # Packages for flatpak (empty here but ready for addition)

# Import the GPG key for 1Password for secure package installation
log "Importing 1Password GPG key"
run_command "curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import" "Importing 1Password GPG key"

# Update pacman packages to the latest versions
log "Starting pacman update..."
run_command "sudo pacman -Syu --noconfirm" "Pacman update"

# Install predefined packages using pacman
if [ ${#pacmanId[@]} -gt 0 ]; then
    log "Installing packages with pacman"
    run_command "sudo pacman -S --noconfirm ${pacmanId[*]}" "Pacman package installation"
fi

# Install packages using yay (AUR helper) - yay is pre-installed on CachyOS
if [ ${#yayId[@]} -gt 0 ]; then
    log "Installing packages with yay"
    run_command "yay -S --noconfirm ${yayId[*]}" "yay package installation"
fi

# Install packages using flatpak (if any are specified)
if [ ${#flatpakId[@]} -gt 0 ]; then
    log "Installing packages with flatpak"
    run_command "flatpak install flathub -y ${flatpakId[*]}" "flatpak package installation"
fi

# Set up autostart if not already configured
log "Setting up autostart for Filen"
mkdir -p $HOME/.config/autostart
log "Copying .desktop file to autostart"
cp /usr/share/applications/filen-desktop.desktop $HOME/.config/autostart/filen-desktop.desktop 

# Ensure user directory exists and create shortcut
run_command "mkdir -p \"$HOME/filen\"" "Creating filen directory"
run_command "ln -sf \"$HOME/filen\" \"$HOME/Desktop/Filen\"" "Creating filen desktop shortcut"

run_command "konsole -e bash -c 'gio launch /usr/share/applications/filen-desktop.desktop; exec bash'" "Launching Filen"
wait $!

# Final setup for 1Password (user guidance for SSH agent setup)
echo "Setup 1Password: Enable SSH agent under the developer settings."
run_command "konsole -e bash -c 'gio launch /usr/share/applications/1password.desktop; exec bash'" "Launching 1password"
wait $!

# Exit script
exit 0
