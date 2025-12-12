# CachyOS Update & Backup Services

Complete automated system update and backup solution for CachyOS.

---

## 📦 What's Included

This package contains two separate automated services:

### 1. 🔄 Update Service
- **Location:** `update/`
- **Purpose:** Automatically updates pacman, yay (AUR), and Flatpak packages
- **Schedule:** Every 3 hours (customizable)
- **Features:**
  - Updates all package managers
  - Cleans package caches
  - Comprehensive logging
  - Only runs on AC power (laptops)
  - Smart user detection for AUR updates

### 2. 💾 Backup Service
- **Location:** `backup/`
- **Purpose:** Automatically backs up files to SMB/CIFS network share
- **Schedule:** Weekly on Sunday at 20:00 (customizable)
- **Features:**
  - Timestamped backup folders
  - Rsync for efficient copying
  - Secure credential storage
  - Desktop notifications
  - Comprehensive logging

---

## 🚀 Quick Start

### Update Service

1. Navigate to the `update/` directory
2. Follow the `INSTALLATION_GUIDE.md`
3. Key steps:
   - Install the script to `/usr/local/bin/`
   - Configure passwordless sudo
   - Enable systemd timer

### Backup Service

1. Navigate to the `backup/` directory
2. Follow the `INSTALLATION_GUIDE.md`
3. Key steps:
   - Install required packages (rsync, cifs-utils)
   - Create SMB credentials file
   - Configure backup script with your settings
   - Enable systemd timer

---

## 📋 Files Overview

### Update Service (`update/`)
- `cachyos-update.sh` - Main update script
- `cachyos-update.service` - Systemd service file
- `cachyos-update.timer` - Systemd timer file
- `INSTALLATION_GUIDE.md` - Complete installation instructions

### Backup Service (`backup/`)
- `BackupScript.sh` - Main backup script
- `smb-backup.service` - Systemd service file
- `smb-backup.timer` - Systemd timer file
- `INSTALLATION_GUIDE.md` - Complete installation instructions

---

## ⚙️ Configuration Requirements

### Update Service
- **Username:** Replace `anders` in sudoers configuration
- **Schedule:** Modify timer file if needed (default: every 3 hours)

### Backup Service
- **Username:** Replace `anders` throughout all files
- **Source Directory:** Set in `BackupScript.sh`
- **NAS/SMB Server:** Configure IP address in `BackupScript.sh`
- **SMB Share Name:** Configure in `BackupScript.sh`
- **SMB Credentials:** Create `~/.backup/smbcredentials` file
- **Schedule:** Modify timer file if needed (default: Sunday 20:00)

---

## 🔧 Key Differences from Original Scripts

### Changes Made for CachyOS:

1. **Updated Service Names:**
   - `garuda-update` → `cachyos-update`
   - All references updated throughout

2. **Optimized for CachyOS:**
   - Yay is pre-installed on CachyOS (no installation needed)
   - Uses CachyOS-optimized repositories

3. **Backup Schedule:**
   - Changed from Saturday 18:00 to Sunday 20:00 to match your original `backup.sh`

4. **Enhanced User Detection:**
   - Better detection for automated service runs
   - Multiple fallback methods

5. **Improved Logging:**
   - Detailed user detection logging
   - Better error messages

---

## 📊 System Requirements

- **OS:** CachyOS (any edition)
- **Packages:** 
  - rsync (for backup)
  - cifs-utils (for SMB backup)
  - yay (pre-installed on CachyOS)
  - flatpak (if using Flatpak apps)
- **Network:** Internet connection for updates, LAN access for backup
- **Permissions:** Root/sudo access for installation

---

## 🛠️ Management Commands

### Update Service

```bash
# Check status
sudo systemctl status cachyos-update.timer

# View next scheduled run
sudo systemctl list-timers cachyos-update.timer

# Run manually
sudo systemctl start cachyos-update.service

# View logs
sudo journalctl -u cachyos-update.service -f
sudo tail -f /var/log/cachyos-update.log

# Stop timer
sudo systemctl stop cachyos-update.timer

# Disable
sudo systemctl disable cachyos-update.timer
```

### Backup Service

```bash
# Check status
sudo systemctl status smb-backup.timer

# View next scheduled run
sudo systemctl list-timers smb-backup.timer

# Run manually
sudo systemctl start smb-backup.service

# View logs
sudo journalctl -u smb-backup.service -f
tail -f ~/.backup/backup.log

# Stop timer
sudo systemctl stop smb-backup.timer

# Disable
sudo systemctl disable smb-backup.timer
```

---

## 🔒 Security Notes

### Update Service
- Passwordless sudo is limited to specific package management commands
- Service only runs on AC power (laptops)
- All operations logged
- Updates run as appropriate users

### Backup Service
- Credentials stored in protected file (`chmod 600`)
- Separate backup user recommended on NAS
- All operations logged
- Network mount points cleaned up automatically

---

## 📝 Important Notes

1. **Replace Username:** Throughout both services, replace `anders` with your actual username
2. **Test First:** Always test services manually before relying on automated schedules
3. **Check Logs:** Regularly review logs to ensure services are working correctly
4. **Network Required:** Both services require network connectivity
5. **Backup Space:** Ensure your NAS has sufficient space for backups

---

## 🆘 Troubleshooting

### Update Service Issues
- Check passwordless sudo configuration
- Verify user detection in logs
- Ensure yay is installed and configured
- Check network connectivity

### Backup Service Issues
- Test SMB connection manually
- Verify credentials file
- Check source directory exists
- Ensure NAS is accessible on network
- Verify mount/umount sudo permissions

See individual `INSTALLATION_GUIDE.md` files for detailed troubleshooting.

---

## 📚 Additional Resources

- **CachyOS:** https://cachyos.org
- **Arch Wiki (Updates):** https://wiki.archlinux.org/title/System_maintenance
- **Arch Wiki (Backup):** https://wiki.archlinux.org/title/Rsync
- **Systemd Timers:** https://wiki.archlinux.org/title/Systemd/Timers

---

## ✨ Features Summary

### Update Service ✅
- Automatic system updates
- Multi-package manager support (pacman, yay, Flatpak)
- Smart user detection
- Cache cleanup
- Detailed logging
- Laptop-friendly (AC power only)
- Random delays to prevent server overload

### Backup Service ✅
- Automatic weekly backups
- Timestamped folders
- Efficient rsync copying
- Secure credential handling
- Desktop notifications
- Comprehensive logging
- Network error handling
- Automatic cleanup and unmounting

---

## 📄 License

These scripts are provided as-is for personal use on CachyOS systems.

---

## 🎉 Installation Order

**Recommended installation order:**

1. **Update Service First** - Ensures your system is up-to-date before configuring backups
2. **Backup Service Second** - Set up backups once system is stable

Both services are independent and can be installed/used separately.

---

## 💡 Tips

- Start with default schedules, adjust after monitoring
- Keep an eye on logs during first few automated runs
- Test backup restores periodically
- Monitor disk space on NAS
- Consider backup retention policies
- Update credentials if NAS password changes

---

**Happy automating!** 🚀
