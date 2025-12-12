# CachyOS Installation Scripts

Automated setup scripts for CachyOS with KDE Plasma desktop environment.

## What This Does

These scripts will automatically configure your CachyOS installation with:
- Essential applications (VLC, Floorp browser, 1Password, Filen, etc.)
- KDE Plasma customizations (dark theme, shortcuts, desktop icons)
- System update automation
- Mirror optimization with Reflector

## Prerequisites

- Fresh CachyOS installation with KDE Plasma
- Internet connection
- User account with sudo privileges

## Installation

1. Download or clone these scripts to your home directory
2. Make the main script executable:
   ```bash
   chmod +x start.sh
   ```
3. Run the installation:
   ```bash
   ./start.sh
   ```

## What Gets Installed

### System Packages (via pacman)
- **vlc** - Media player
- **flatpak** - Universal package manager
- **python-beautifulsoup4** & **python-lxml** - Python libraries
- **fuse2** - Filesystem in userspace
- **axel** & **aria2** - Download accelerators
- **kio-admin** - KDE admin tools
- **fastfetch** - System information tool
- **jq** - JSON processor

### AUR Packages (via yay)
- **1password** - Password manager
- **filen-desktop-bin** - Encrypted cloud storage
- **floorp-bin** - Privacy-focused browser
- **octopi** - Package manager GUI

### System Configurations
- **SDDM** - Login manager configured with Breeze theme
- **KDE Plasma** - Dark theme (Breeze Dark)
- **Locale** - Set to English (Denmark)
- **NumLock** - Disabled on startup
- **Dolphin** - File manager home directory set
- **Desktop** - Trash icon added
- **Autostart** - Filen configured

## Script Details

### start.sh
Main orchestration script that runs all setup scripts in sequence.

### script/app_install.sh
Installs applications using pacman and yay. Configures Filen and 1Password.

### script/kdm_sddm_Config.sh
Configures KDE Plasma, SDDM, and desktop environment settings.

### script/update_service.sh
Sets up a systemd service that runs updates before system shutdown/reboot.

### script/reflector.sh
Configures Reflector to automatically optimize Pacman mirrors daily at 18:00, prioritizing Germany, Sweden, and Denmark.

### script/backup.sh
Sets up automated weekly backup to NAS (requires configuration).

### script/update_script.sh
Script that performs system updates (pacman, yay, flatpak).

## Logs

Each script creates its own log file in the script directory:
- `start.log` - Main execution log
- `App_install.log` - Application installation log
- `kdm_sddm_Config.log` - KDE configuration log
- `update_service.log` - Update service setup log
- `reflector.log` - Reflector setup log

## Customization

### Adding More Packages

Edit `script/app_install.sh`:

```bash
# Add pacman packages
pacmanId=("vlc" "flatpak" "YOUR_PACKAGE_HERE")

# Add AUR packages
yayId=("1password" "YOUR_AUR_PACKAGE_HERE")

# Add Flatpak packages
flatpakId=("YOUR_FLATPAK_ID_HERE")
```

### Changing Mirror Countries

Edit `script/reflector.sh`:

```bash
update_config_file "$REFLECTOR_CONF" "--country" "YOUR,COUNTRY,CODES"
```

### Modifying Backup Settings

Edit `script/backup.sh` and update:
- NAS IP address
- Username and password
- Source directory
- Backup schedule

## Troubleshooting

### Script Fails
1. Check the relevant log file for error messages
2. Ensure you have an internet connection
3. Verify you have sudo privileges
4. Try running the failed script individually

### Package Installation Fails
- Check if the package name is correct
- Verify the package exists in repositories
- Try updating package databases: `sudo pacman -Syy`

### Permission Errors
- Ensure scripts are executable: `chmod +x script/*.sh`
- Check sudo access: `sudo -v`

## Post-Installation

After running the scripts and rebooting:

1. **1Password**: Open and enable SSH agent in developer settings
2. **Filen**: Log into your account (will launch automatically)
3. **Backup**: Edit `/usr/local/bin/BackupScript.sh` with your NAS credentials

## CachyOS-Specific Notes

- **yay is pre-installed** on CachyOS, so no manual installation needed
- CachyOS optimized repositories provide better performance
- The scripts are optimized for CachyOS but work on any Arch-based distro

## Removed Components

Compared to the original Arch Linux scripts, these remove:
- VM setup (vm.sh)
- ZSH setup (zsh.sh)
- Flameshot screenshot tool
- Bauh package manager
- Snap package manager support

## Support

For issues specific to:
- **CachyOS**: Visit https://cachyos.org
- **KDE Plasma**: Visit https://kde.org
- **Arch Linux packages**: Visit https://wiki.archlinux.org

## License

These scripts are provided as-is for personal use.
