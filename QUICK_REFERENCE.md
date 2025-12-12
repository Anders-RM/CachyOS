# Quick Reference Card - CachyOS Update & Backup Services

## 🎯 Before You Start

### Critical: Replace These Values!
Throughout all files, replace `anders` with **YOUR** username:
- ✏️ Update service: sudoers file
- ✏️ Backup service: BackupScript.sh (3 places), smb-backup.service (3 places)

### Backup Configuration Required
In `BackupScript.sh`, set:
- `LOCAL_SOURCE="/home/YOUR_USERNAME/YOUR_DIRECTORY/"`
- `SMB_SERVER="YOUR_NAS_IP"`
- `SMB_SHARE="YOUR_SHARE_NAME"`

---

## ⚡ Quick Install - Update Service

```bash
# 1. Copy script
sudo cp update/cachyos-update.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/cachyos-update.sh

# 2. Configure sudo (replace 'anders' with YOUR username!)
sudo visudo -f /etc/sudoers.d/cachyos-update
# Add these lines:
# anders ALL=(ALL) NOPASSWD: /usr/bin/pacman
# anders ALL=(ALL) NOPASSWD: /usr/bin/makepkg  
# anders ALL=(ALL) NOPASSWD: /usr/bin/yay

# 3. Install systemd files
sudo cp update/cachyos-update.service /etc/systemd/system/
sudo cp update/cachyos-update.timer /etc/systemd/system/

# 4. Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now cachyos-update.timer

# 5. Verify
sudo systemctl status cachyos-update.timer
```

---

## ⚡ Quick Install - Backup Service

```bash
# 1. Install dependencies
sudo pacman -S rsync cifs-utils

# 2. Create directories
mkdir -p ~/.backup

# 3. Create credentials file (replace with YOUR credentials!)
nano ~/.backup/smbcredentials
# Add:
# username=YOUR_SMB_USERNAME
# password=YOUR_SMB_PASSWORD
# domain=WORKGROUP

chmod 600 ~/.backup/smbcredentials

# 4. Copy and edit backup script
cp backup/BackupScript.sh ~/.backup/
nano ~/.backup/BackupScript.sh
# Edit: LOCAL_SOURCE, SMB_SERVER, SMB_SHARE, username paths
chmod +x ~/.backup/BackupScript.sh

# 5. Configure sudo for mount (replace 'anders' with YOUR username!)
sudo visudo -f /etc/sudoers.d/smb-backup
# Add:
# anders ALL=(ALL) NOPASSWD: /usr/bin/mount, /usr/bin/umount

# 6. Install systemd files (edit username first!)
nano backup/smb-backup.service  # Replace 'anders' with YOUR username
sudo cp backup/smb-backup.service /etc/systemd/system/
sudo cp backup/smb-backup.timer /etc/systemd/system/

# 7. Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now smb-backup.timer

# 8. Verify
sudo systemctl status smb-backup.timer
```

---

## 📋 Essential Commands

### Update Service
```bash
# Status check
sudo systemctl status cachyos-update.timer

# Next scheduled run
sudo systemctl list-timers cachyos-update.timer

# Run now
sudo systemctl start cachyos-update.service

# View logs
sudo journalctl -u cachyos-update.service -f
sudo tail -f /var/log/cachyos-update.log

# Stop/disable
sudo systemctl stop cachyos-update.timer
sudo systemctl disable cachyos-update.timer
```

### Backup Service
```bash
# Status check
sudo systemctl status smb-backup.timer

# Next scheduled run
sudo systemctl list-timers smb-backup.timer

# Run now
sudo systemctl start smb-backup.service

# View logs
sudo journalctl -u smb-backup.service -f
tail -f ~/.backup/backup.log

# Stop/disable
sudo systemctl stop smb-backup.timer
sudo systemctl disable smb-backup.timer
```

---

## ⏰ Default Schedules

- **Update Service:** Every 3 hours (00:00, 03:00, 06:00, 09:00, 12:00, 15:00, 18:00, 21:00)
- **Backup Service:** Sunday at 20:00 (8 PM)

---

## 🔍 Quick Troubleshooting

### Update Service Not Working?
```bash
# Check user detection
sudo /usr/local/bin/cachyos-update.sh
# Look for "Initial user detection result" in output

# Verify sudo config
sudo -u YOUR_USERNAME -n sudo pacman --version
# Should show version without password prompt
```

### Backup Not Working?
```bash
# Test SMB connection
smbclient //YOUR_NAS_IP/YOUR_SHARE -U YOUR_USERNAME

# Check credentials file
cat ~/.backup/smbcredentials
ls -l ~/.backup/smbcredentials  # Should show: -rw-------

# Test script manually
~/.backup/BackupScript.sh
```

---

## 📂 File Locations

### Update Service
- Script: `/usr/local/bin/cachyos-update.sh`
- Service: `/etc/systemd/system/cachyos-update.service`
- Timer: `/etc/systemd/system/cachyos-update.timer`
- Sudo config: `/etc/sudoers.d/cachyos-update`
- Log: `/var/log/cachyos-update.log`

### Backup Service
- Script: `~/.backup/BackupScript.sh`
- Service: `/etc/systemd/system/smb-backup.service`
- Timer: `/etc/systemd/system/smb-backup.timer`
- Credentials: `~/.backup/smbcredentials`
- Sudo config: `/etc/sudoers.d/smb-backup`
- Log: `~/.backup/backup.log`

---

## ⚙️ Change Schedules

### Update Service - Every 6 Hours
```bash
sudo nano /etc/systemd/system/cachyos-update.timer
# Change: OnCalendar=*-*-* 00,06,12,18:00:00
sudo systemctl daemon-reload
sudo systemctl restart cachyos-update.timer
```

### Backup Service - Daily at 2 AM
```bash
sudo nano /etc/systemd/system/smb-backup.timer
# Change: OnCalendar=*-*-* 02:00:00
sudo systemctl daemon-reload
sudo systemctl restart smb-backup.timer
```

---

## ✅ Post-Installation Checklist

### Update Service
- [ ] Script copied to /usr/local/bin/
- [ ] Script is executable
- [ ] Sudo configured with YOUR username
- [ ] Service and timer files installed
- [ ] Timer enabled and started
- [ ] Manual test successful
- [ ] Logs showing correct user detection

### Backup Service
- [ ] rsync and cifs-utils installed
- [ ] Credentials file created and secured (600)
- [ ] Backup script edited with YOUR settings
- [ ] Script is executable
- [ ] Sudo configured for mount/umount
- [ ] Service file edited with YOUR username
- [ ] Service and timer files installed
- [ ] Timer enabled and started
- [ ] Manual test successful
- [ ] Backup appears on NAS

---

## 🚨 Common Mistakes

1. **Forgetting to replace 'anders' with your username**
   - Check all files before installing!

2. **Wrong permissions on credentials file**
   - Must be 600: `chmod 600 ~/.backup/smbcredentials`

3. **Not editing BackupScript.sh settings**
   - Must set: LOCAL_SOURCE, SMB_SERVER, SMB_SHARE

4. **Sudo not configured correctly**
   - Test with: `sudo -u YOUR_USERNAME -n sudo pacman --version`

5. **Timers not started**
   - Use: `sudo systemctl start timer-name.timer`

---

## 📞 Need Help?

Read the detailed guides:
- `update/INSTALLATION_GUIDE.md` - Complete update service setup
- `backup/INSTALLATION_GUIDE.md` - Complete backup service setup
- `CHANGES_SUMMARY.md` - All changes explained
- `README.md` - Overview and features

---

**Remember: Test manually before relying on automated schedules!** 🔒
