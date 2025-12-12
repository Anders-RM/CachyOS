# SMB Backup Service - Complete Installation Guide for CachyOS

This guide will help you set up an automated weekly backup to your SMB/CIFS network share on CachyOS.

---

## 📋 Prerequisites

- CachyOS system
- Network access to SMB/NAS server
- Root/sudo access
- Basic terminal knowledge
- SMB share credentials (username and password)

---

## 🚀 Installation Steps

### Step 1: Install Required Packages

```bash
sudo pacman -S rsync cifs-utils
```

---

### Step 2: Create Backup Directory Structure

**Important:** Replace `anders` with your actual username throughout this guide!

```bash
# Create backup configuration directory
mkdir -p ~/.backup

# Create log file
touch ~/.backup/backup.log
```

---

### Step 3: Create SMB Credentials File

For security, store your SMB credentials in a protected file:

```bash
nano ~/.backup/smbcredentials
```

Add these lines (replace with your actual SMB credentials):

```
username=YourSMBUsername
password=YourSMBPassword
domain=WORKGROUP
```

**Important:** If your SMB server doesn't require a domain, you can omit that line.

Secure the credentials file:

```bash
chmod 600 ~/.backup/smbcredentials
```

---

### Step 4: Create the Backup Script

```bash
nano ~/.backup/BackupScript.sh
```

**Copy and paste the entire backup script** from `BackupScript.sh`, then **MODIFY these lines** with your information:

```bash
LOCAL_SOURCE="/home/YOUR_USERNAME/filen/"  # Change to your source directory
SMB_SERVER="192.168.3.2"                   # Change to your NAS IP address
SMB_SHARE="Anders"                          # Change to your SMB share name
CREDENTIALS_FILE="/home/YOUR_USERNAME/.backup/smbcredentials"  # Change username
```

Save and exit (`Ctrl + X`, `Y`, `Enter`).

Make the script executable:

```bash
chmod +x ~/.backup/BackupScript.sh
```

---

### Step 5: Test the Backup Script Manually

Before setting up automation, test the script:

```bash
~/.backup/BackupScript.sh
```

This should:
1. Mount your SMB share
2. Create a timestamped backup folder
3. Copy files using rsync
4. Unmount the share
5. Display a summary

If you see errors, check:
- Network connectivity to SMB server
- SMB credentials in `~/.backup/smbcredentials`
- Source directory exists and has files
- SMB share name is correct

---

### Step 6: Create the Systemd Service File

```bash
sudo nano /etc/systemd/system/smb-backup.service
```

Paste this content (replace `anders` with YOUR username):

```ini
[Unit]
Description=SMB Backup Service
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/anders/.backup/BackupScript.sh
WorkingDirectory=/home/anders

# Environment - CHANGE 'anders' TO YOUR USERNAME
Environment="HOME=/home/anders"
Environment="USER=anders"  
Environment="PATH=/usr/local/bin:/usr/bin:/bin"

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=smb-backup

[Install]
WantedBy=default.target
```

Save and exit (`Ctrl + X`, `Y`, `Enter`).

---

### Step 7: Create the Systemd Timer File

```bash
sudo nano /etc/systemd/system/smb-backup.timer
```

Paste this content:

```ini
[Unit]
Description=Weekly SMB Backup Timer
Requires=smb-backup.service

[Timer]
# Every Sunday at 20:00 (8 PM)
OnCalendar=Sun 20:00:00
# Add randomization to avoid network congestion
RandomizedDelaySec=300
# Ensure it runs even if system was off
Persistent=true
# Run immediately if we missed a scheduled run
AccuracySec=1h

[Install]
WantedBy=timers.target
```

**Note:** This matches your original backup schedule (Sunday at 20:00). To change it, see the Configuration Options section.

Save and exit (`Ctrl + X`, `Y`, `Enter`).

---

### Step 8: Configure Sudo for Mount Operations

The backup script needs to mount SMB shares, which requires sudo access:

```bash
sudo visudo -f /etc/sudoers.d/smb-backup
```

Add this line (replace `anders` with YOUR username):

```
anders ALL=(ALL) NOPASSWD: /usr/bin/mount, /usr/bin/umount
```

Save and exit (`Ctrl + X`, `Y`, `Enter`).

---

### Step 9: Enable and Start the Backup Timer

Reload systemd to recognize the new service:

```bash
sudo systemctl daemon-reload
```

Enable the timer to start automatically on boot:

```bash
sudo systemctl enable smb-backup.timer
```

Start the timer immediately:

```bash
sudo systemctl start smb-backup.timer
```

---

## ✅ Verification

### Check Timer Status

```bash
sudo systemctl status smb-backup.timer
```

You should see: `Active: active (waiting)`

### Check Next Scheduled Run

```bash
sudo systemctl list-timers smb-backup.timer
```

This shows when the next backup will run.

### Test the Service Manually

```bash
sudo systemctl start smb-backup.service
```

Watch it run and check for errors.

### View Logs

```bash
# View systemd logs
sudo journalctl -u smb-backup.service -f

# View custom log file
tail -f ~/.backup/backup.log
```

---

## 🎛️ Configuration Options

### Change Backup Schedule

Edit the timer file:

```bash
sudo nano /etc/systemd/system/smb-backup.timer
```

**Schedule Examples:**

- **Daily at 2 AM:** `OnCalendar=*-*-* 02:00:00`
- **Every Monday at 3 PM:** `OnCalendar=Mon 15:00:00`
- **Every Saturday at 6 PM:** `OnCalendar=Sat 18:00:00`
- **Twice weekly (Wed & Sun):** Use two `OnCalendar=` lines:
  ```
  OnCalendar=Wed 20:00:00
  OnCalendar=Sun 20:00:00
  ```

After making changes:

```bash
sudo systemctl daemon-reload
sudo systemctl restart smb-backup.timer
```

### Change Source Directory

Edit the backup script:

```bash
nano ~/.backup/BackupScript.sh
```

Change the `LOCAL_SOURCE` variable to your desired directory.

### Change Backup Destination

Edit the backup script:

```bash
nano ~/.backup/BackupScript.sh
```

Modify these variables:
- `SMB_SERVER` - Your NAS IP address
- `SMB_SHARE` - Your SMB share name

---

## 🛠️ Management Commands

### Stop the Timer

```bash
sudo systemctl stop smb-backup.timer
```

### Disable Automatic Backups

```bash
sudo systemctl disable smb-backup.timer
```

### Re-enable Automatic Backups

```bash
sudo systemctl enable smb-backup.timer
sudo systemctl start smb-backup.timer
```

### Run Backup Manually (without waiting for timer)

```bash
sudo systemctl start smb-backup.service
```

Or run the script directly:

```bash
~/.backup/BackupScript.sh
```

---

## 📊 How Backups Work

1. **Creates timestamped folder** on SMB share (e.g., `2025_11_09 - 20_00`)
2. **Copies all files** from source directory using rsync
3. **Preserves file attributes** (permissions, timestamps, etc.)
4. **Logs all operations** to backup.log
5. **Sends desktop notifications** (if GUI is running)
6. **Automatically unmounts** SMB share when done

---

## 🔧 Troubleshooting

### Mount Failed

**Problem:** "Failed to mount SMB share"

**Solutions:**
1. Check network connectivity: `ping 192.168.3.2`
2. Verify SMB credentials in `~/.backup/smbcredentials`
3. Test SMB access manually:
   ```bash
   smbclient //192.168.3.2/Anders -U username
   ```
4. Ensure cifs-utils is installed: `sudo pacman -S cifs-utils`

### Permission Denied

**Problem:** Cannot create backup folder or copy files

**Solutions:**
1. Check SMB share permissions
2. Verify your SMB user has write access
3. Check credentials file permissions: `chmod 600 ~/.backup/smbcredentials`

### Source Directory Empty

**Problem:** Backup completes but no files copied

**Solutions:**
1. Verify source directory path: `ls -la /home/anders/filen/`
2. Check if files exist in source directory
3. Review backup log: `cat ~/.backup/backup.log`

### Timer Not Running

**Problem:** Backups don't run automatically

**Solutions:**
```bash
sudo systemctl enable smb-backup.timer
sudo systemctl start smb-backup.timer
sudo systemctl status smb-backup.timer
```

### View Detailed Error Messages

```bash
# Last 50 lines of the service log
sudo journalctl -u smb-backup.service -n 50

# Follow the log in real-time
sudo journalctl -u smb-backup.service -f

# Check the custom log file
cat ~/.backup/backup.log
```

---

## 🔒 Security Best Practices

1. **Never store passwords in plain text** in scripts - always use the credentials file
2. **Protect the credentials file:**
   ```bash
   chmod 600 ~/.backup/smbcredentials
   ```
3. **Use a dedicated backup user** on your NAS with limited permissions
4. **Consider encrypting sensitive data** before backup
5. **Regularly test restores** to ensure backups are working

---

## 📁 File Locations

- **Backup script:** `~/.backup/BackupScript.sh`
- **Credentials:** `~/.backup/smbcredentials`
- **Log file:** `~/.backup/backup.log`
- **Service file:** `/etc/systemd/system/smb-backup.service`
- **Timer file:** `/etc/systemd/system/smb-backup.timer`
- **Sudo config:** `/etc/sudoers.d/smb-backup`

---

## ✨ Features

- ✅ Automatic weekly backups
- ✅ Timestamped backup folders
- ✅ Incremental backup support (rsync)
- ✅ Secure credential storage
- ✅ Comprehensive logging
- ✅ Desktop notifications (when GUI available)
- ✅ Automatic retry if system was off
- ✅ Network connectivity checks
- ✅ Graceful error handling

---

## 📈 Backup Retention

The script creates a new timestamped folder for each backup. To manage old backups:

### Manual Cleanup

Delete old backups from your NAS web interface or:

```bash
# Mount share manually
sudo mount -t cifs //192.168.3.2/Anders /mnt/temp -o credentials=/home/anders/.backup/smbcredentials

# List backups
ls -la /mnt/temp/

# Remove old backups (be careful!)
# rm -rf /mnt/temp/2025_10_*

# Unmount
sudo umount /mnt/temp
```

### Automatic Cleanup (Optional)

Add to the end of `BackupScript.sh` before the final cleanup:

```bash
# Keep only last 4 backups (4 weeks)
cd "$MOUNT_POINT"
ls -t | tail -n +5 | xargs -r rm -rf
```

---

## 🆘 Getting Help

If you encounter issues:

1. Check all logs (systemd journal and backup.log)
2. Verify network connectivity to NAS
3. Test SMB credentials manually with smbclient
4. Ensure all file paths use your actual username
5. Run the backup script manually to see detailed errors

---

## 🎉 You're Done!

Your CachyOS system will now automatically backup your files every Sunday at 20:00 to your SMB/NAS server!

To verify everything is working:

```bash
sudo systemctl list-timers smb-backup.timer
```

Happy backing up! 💾🚀
