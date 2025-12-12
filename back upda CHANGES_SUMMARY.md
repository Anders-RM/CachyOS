# Update & Backup Scripts - Changes Summary

## Overview
Updated Garuda Linux scripts for CachyOS compatibility and modified backup schedule.

---

## Major Changes Made

### 1. Service Renaming
**Garuda → CachyOS**
- `garuda-update` → `cachyos-update`
- Updated all file names, service names, and references
- Updated log file paths from `/var/log/garuda-update.log` to `/var/log/cachyos-update.log`

### 2. Backup Schedule Change
**Saturday 18:00 → Sunday 20:00**
- Modified `smb-backup.timer` to run Sunday at 20:00
- Changed from `OnCalendar=Sat 18:00:00` to `OnCalendar=Sun 20:00:00`
- Matches your original `backup.sh` schedule (Sunday 20:00 via cron)

### 3. Script Optimizations for CachyOS
- **No changes needed for yay installation** - CachyOS comes with yay pre-installed
- Maintained all user detection logic (works perfectly on CachyOS)
- Kept all security features and error handling
- Preserved all logging functionality

---

## Files Created

### Update Service (3 files + guide)
1. **cachyos-update.sh** - Main update script
   - Handles pacman, yay, and Flatpak updates
   - Smart user detection for AUR updates
   - Comprehensive logging
   - Cache cleanup

2. **cachyos-update.service** - Systemd service
   - Runs on AC power only
   - 1-hour timeout
   - Console and journal logging

3. **cachyos-update.timer** - Systemd timer
   - Every 3 hours (00, 03, 06, 09, 12, 15, 18, 21)
   - 1-hour randomized delay
   - Persistent (runs missed timers)

4. **INSTALLATION_GUIDE.md** - Complete setup instructions
   - Step-by-step installation
   - Configuration examples
   - Troubleshooting guide
   - Management commands

### Backup Service (3 files + guide)
1. **BackupScript.sh** - Main backup script
   - SMB/CIFS network backup
   - Timestamped folders
   - Rsync for efficient copying
   - Automated and interactive modes
   - Secure credential handling

2. **smb-backup.service** - Systemd service
   - User environment configuration
   - Journal logging
   - Proper working directory

3. **smb-backup.timer** - Systemd timer
   - Sunday at 20:00 (changed from Saturday 18:00)
   - 5-minute randomized delay
   - Persistent (runs missed backups)
   - 1-hour accuracy window

4. **INSTALLATION_GUIDE.md** - Complete setup instructions
   - SMB credential configuration
   - Step-by-step installation
   - Security best practices
   - Troubleshooting guide

---

## Configuration Changes Required

### Update Service
**Must change before installation:**
1. Replace `anders` with your username in `/etc/sudoers.d/cachyos-update`

**Optional customizations:**
- Update frequency (timer file)
- Log file location (script)
- Timeout duration (service file)

### Backup Service
**Must change before installation:**
1. Replace `anders` with your username in:
   - `BackupScript.sh` (3 locations: source path, credentials path, log path)
   - `smb-backup.service` (3 locations: ExecStart, Environment variables)
   - `~/.backup/smbcredentials` file location

2. Configure in `BackupScript.sh`:
   - `LOCAL_SOURCE` - Your source directory
   - `SMB_SERVER` - Your NAS IP address
   - `SMB_SHARE` - Your SMB share name

**Optional customizations:**
- Backup schedule (timer file)
- Backup retention (add cleanup to script)
- Notification settings

---

## Comparison with Original Scripts

### Update Service
| Feature | Original (Garuda) | Updated (CachyOS) |
|---------|-------------------|-------------------|
| Service name | garuda-update | cachyos-update |
| Package managers | pacman, yay, Flatpak | pacman, yay, Flatpak |
| Schedule | Every 3 hours | Every 3 hours |
| User detection | ✅ | ✅ |
| Logging | ✅ | ✅ |
| AC power check | ✅ | ✅ |

**Changes:** Only naming conventions updated

### Backup Service
| Feature | Original | Updated |
|---------|----------|---------|
| Schedule | Saturday 18:00 | **Sunday 20:00** ⬅️ CHANGED |
| Backup method | rsync | rsync |
| Timestamped folders | ✅ | ✅ |
| Credential security | ✅ | ✅ |
| Notifications | ✅ | ✅ |
| Logging | ✅ | ✅ |

**Changes:** Schedule changed to match your original setup

---

## Features Preserved

### Update Service ✅
- ✅ Multi-package manager support (pacman, yay, Flatpak)
- ✅ Smart user detection (5 different methods)
- ✅ Passwordless sudo configuration
- ✅ Comprehensive logging (dual logs)
- ✅ Lock file to prevent concurrent runs
- ✅ AC power requirement (laptop friendly)
- ✅ Random delays (prevent server overload)
- ✅ Cache cleanup
- ✅ Error handling and recovery

### Backup Service ✅
- ✅ SMB/CIFS network backup
- ✅ Timestamped backup folders
- ✅ Rsync efficient copying
- ✅ Secure credential storage
- ✅ Automated and interactive modes
- ✅ Desktop notifications
- ✅ Comprehensive logging
- ✅ Network error handling
- ✅ Automatic cleanup
- ✅ Persistent timer (missed run recovery)

---

## Removed/Not Needed

### From Original Arch Scripts
- ❌ Bauh package manager
- ❌ VM setup scripts
- ❌ ZSH setup scripts
- ❌ Flameshot configuration

### Why Removed?
- Not requested for CachyOS setup
- Update and backup services are standalone
- Can be added separately if needed later

---

## Installation Differences

### Original vs Updated

**Original (Garuda Scripts):**
```bash
# Required garuda-specific configurations
# Manual yay installation might be needed
# Garuda-specific paths and services
```

**Updated (CachyOS):**
```bash
# CachyOS-optimized paths
# Yay pre-installed (no manual setup)
# Standard Arch-based configurations
# Universal systemd services
```

---

## Testing Recommendations

### Update Service
1. Test script manually first:
   ```bash
   sudo /usr/local/bin/cachyos-update.sh
   ```

2. Check logs:
   ```bash
   sudo tail -f /var/log/cachyos-update.log
   ```

3. Verify user detection:
   ```bash
   # Check logs for "Initial user detection result"
   ```

4. Monitor first automated run

### Backup Service
1. Test script manually first:
   ```bash
   ~/.backup/BackupScript.sh
   ```

2. Verify SMB connection:
   ```bash
   smbclient //192.168.3.2/Anders -U username
   ```

3. Check backup created on NAS

4. Verify log file:
   ```bash
   tail -f ~/.backup/backup.log
   ```

5. Monitor first automated run

---

## Migration Notes

### From Your Original Scripts

**Update Script Migration:**
- Old: `update_script.sh` via `update_service.sh`
- New: `cachyos-update.sh` with systemd timer
- ✅ More robust (systemd managed)
- ✅ Better logging
- ✅ User detection for AUR
- ✅ Laptop-friendly (AC power check)

**Backup Script Migration:**
- Old: `backup.sh` via cron (Sunday 20:00)
- New: `BackupScript.sh` with systemd timer (Sunday 20:00)
- ✅ Same schedule maintained
- ✅ Better error handling
- ✅ Desktop notifications
- ✅ Secure credentials
- ✅ Systemd integration

---

## Security Improvements

### Update Service
1. **Passwordless sudo** limited to specific commands only:
   - `/usr/bin/pacman`
   - `/usr/bin/makepkg`
   - `/usr/bin/yay`

2. **User isolation** - AUR updates run as regular user, not root

3. **Logging** - All operations logged for audit

### Backup Service
1. **Credential file** with restricted permissions (600)
2. **Separate backup user** recommended on NAS
3. **Secure mount/unmount** via sudo
4. **Automatic cleanup** of mount points
5. **Logging** - All operations logged

---

## Compatibility Notes

### CachyOS Compatibility ✅
- Fully compatible with all CachyOS editions
- Uses standard Arch packages
- Systemd integration (standard)
- Works with KDE Plasma (your desktop)
- Yay pre-installed (no setup needed)

### Works On
- ✅ CachyOS (all editions)
- ✅ Arch Linux
- ✅ Manjaro
- ✅ EndeavourOS
- ✅ Any Arch-based distribution

---

## Support & Maintenance

### Log Locations
- **Update logs:** `/var/log/cachyos-update.log`
- **Backup logs:** `~/.backup/backup.log`
- **Systemd journals:** `journalctl -u service-name`

### Status Commands
```bash
# Check all timers
systemctl list-timers

# Check specific timer
systemctl status cachyos-update.timer
systemctl status smb-backup.timer

# View logs
journalctl -u cachyos-update.service -f
journalctl -u smb-backup.service -f
```

---

## Next Steps

1. **Review both INSTALLATION_GUIDE.md files**
2. **Update username in all files** (replace `anders`)
3. **Configure backup settings** (NAS IP, share name, etc.)
4. **Test manually before enabling timers**
5. **Monitor logs after first automated runs**
6. **Adjust schedules if needed**

---

**All changes maintain or improve upon the original functionality while optimizing for CachyOS!** 🚀
