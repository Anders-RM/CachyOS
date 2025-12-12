# CachyOS Update Service - Complete Installation Guide

This guide will help you set up an automated update service for CachyOS that handles **pacman**, **yay (AUR)**, and **Flatpak** updates every 3 hours.

---

## 📋 Prerequisites

- CachyOS (any edition)
- Root/sudo access
- Basic terminal knowledge

---

## 🚀 Installation Steps

### Step 1: Create the Update Script

Open a terminal and create the main update script:

```bash
sudo nano /usr/local/bin/cachyos-update.sh
```

**Copy and paste the entire update script** from `cachyos-update.sh` into this file, then save it:
- Press `Ctrl + X` to exit
- Press `Y` to confirm saving
- Press `Enter` to confirm the filename

Make the script executable:

```bash
sudo chmod +x /usr/local/bin/cachyos-update.sh
```

---

### Step 2: Configure Passwordless Sudo

For AUR updates to work automatically, you need to configure passwordless sudo for package management commands.

**Important:** Replace `anders` with your actual username in the commands below!

```bash
# Open the sudo configuration editor
sudo visudo -f /etc/sudoers.d/cachyos-update
```

Add these lines (replace `anders` with YOUR username):

```
anders ALL=(ALL) NOPASSWD: /usr/bin/pacman
anders ALL=(ALL) NOPASSWD: /usr/bin/makepkg
anders ALL=(ALL) NOPASSWD: /usr/bin/yay
```

Save and exit:
- Press `Ctrl + X`
- Press `Y`
- Press `Enter`

**Verify the configuration:**

```bash
# Replace 'anders' with your username
sudo -u anders -n sudo pacman --version
```

If this shows the pacman version without asking for a password, it's working correctly! ✅

---

### Step 3: Create the Systemd Service File

Create the service file:

```bash
sudo nano /etc/systemd/system/cachyos-update.service
```

Paste this content:

```ini
[Unit]
Description=CachyOS System Update Service
After=network-online.target
Wants=network-online.target
ConditionACPower=true

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cachyos-update.sh
User=root
StandardOutput=journal+console
StandardError=journal+console
TimeoutSec=3600
KillMode=control-group

[Install]
WantedBy=multi-user.target
```

Save and exit (`Ctrl + X`, `Y`, `Enter`).

---

### Step 4: Create the Systemd Timer File

Create the timer file:

```bash
sudo nano /etc/systemd/system/cachyos-update.timer
```

Paste this content:

```ini
[Unit]
Description=Run CachyOS System Update Service
Requires=cachyos-update.service

[Timer]
# Run every 3 hours
OnCalendar=*-*-* 00,03,06,09,12,15,18,21:00:00
# Add randomized delay of up to 1 hour
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
```

Save and exit (`Ctrl + X`, `Y`, `Enter`).

---

### Step 5: Enable and Start the Service

Reload systemd to recognize the new service:

```bash
sudo systemctl daemon-reload
```

Enable the timer to start automatically on boot:

```bash
sudo systemctl enable cachyos-update.timer
```

Start the timer immediately:

```bash
sudo systemctl start cachyos-update.timer
```

---

## ✅ Verification

### Check Timer Status

```bash
sudo systemctl status cachyos-update.timer
```

You should see: `Active: active (waiting)`

### Check Next Scheduled Run

```bash
sudo systemctl list-timers cachyos-update.timer
```

This shows when the update will run next.

### Test the Service Manually

```bash
sudo systemctl start cachyos-update.service
```

Watch it run and check for any errors.

### View Logs

```bash
# View systemd logs
sudo journalctl -u cachyos-update.service -f

# View custom log file
sudo tail -f /var/log/cachyos-update.log
```

---

## 🎛️ Configuration Options

### Change Update Frequency

Edit the timer file to change how often updates run:

```bash
sudo nano /etc/systemd/system/cachyos-update.timer
```

**Examples:**

- **Every 2 hours:** `OnCalendar=*-*-* 00,02,04,06,08,10,12,14,16,18,20,22:00:00`
- **Every 4 hours:** `OnCalendar=*-*-* 00,04,08,12,16,20:00:00`
- **Every 6 hours:** `OnCalendar=*-*-* 00,06,12,18:00:00`
- **Once daily at 2 AM:** `OnCalendar=*-*-* 02:00:00`
- **Once daily at 5 PM:** `OnCalendar=*-*-* 17:00:00`

After making changes:

```bash
sudo systemctl daemon-reload
sudo systemctl restart cachyos-update.timer
```

---

## 🛠️ Management Commands

### Stop the Timer

```bash
sudo systemctl stop cachyos-update.timer
```

### Disable Automatic Updates

```bash
sudo systemctl disable cachyos-update.timer
```

### Re-enable Automatic Updates

```bash
sudo systemctl enable cachyos-update.timer
sudo systemctl start cachyos-update.timer
```

### Run Updates Manually (without waiting for timer)

```bash
sudo systemctl start cachyos-update.service
```

Or run the script directly:

```bash
sudo /usr/local/bin/cachyos-update.sh
```

---

## 📊 What Gets Updated

The service updates three package managers in this order:

1. **Pacman** - Official Arch/CachyOS repositories
2. **Yay** - AUR (Arch User Repository) packages (pre-installed on CachyOS)
3. **Flatpak** - Flatpak applications (both user and system)

After updates, it cleans up old package caches to save disk space.

---

## 🔧 Troubleshooting

### AUR Updates Failing

**Problem:** Logs show "cannot determine user" or "sudo password required"

**Solution:** Make sure you configured passwordless sudo (Step 2) with your correct username.

### Flatpak Updates Not Working

**Problem:** Flatpak updates fail or skip

**Solution:** Check if you have Flatpak packages installed:

```bash
flatpak list --user
flatpak list --system
```

### Service Not Running

**Problem:** Timer shows as inactive

**Solution:**

```bash
sudo systemctl enable cachyos-update.timer
sudo systemctl start cachyos-update.timer
sudo systemctl status cachyos-update.timer
```

### View Detailed Error Messages

```bash
# Last 50 lines of the service log
sudo journalctl -u cachyos-update.service -n 50

# Follow the log in real-time
sudo journalctl -u cachyos-update.service -f

# Check the custom log file
sudo cat /var/log/cachyos-update.log
```

---

## 🔒 Security Notes

- The service only runs when on AC power (laptops won't update on battery)
- Passwordless sudo is limited to specific package management commands only
- All activities are logged for audit purposes
- Updates run as appropriate users (not everything as root)

---

## 📁 Log Files

Two log locations:

1. **System journal:** `sudo journalctl -u cachyos-update.service`
2. **Custom log:** `/var/log/cachyos-update.log`

---

## ✨ Features

- ✅ Automatic updates every 3 hours
- ✅ Updates all package managers (pacman, yay, Flatpak)
- ✅ Runs updates as appropriate users (not always root)
- ✅ Automatic cache cleanup
- ✅ Comprehensive logging
- ✅ Prevents duplicate runs
- ✅ Only runs on AC power (laptops)
- ✅ Random delay to prevent server overload
- ✅ Compatible with CachyOS (yay pre-installed)

---

## 🆘 Getting Help

If you encounter issues:

1. Check the logs (see Troubleshooting section)
2. Verify each step was completed correctly
3. Ensure your username was correctly substituted in Step 2
4. Test running the script manually: `sudo /usr/local/bin/cachyos-update.sh`

---

## 🎉 You're Done!

Your CachyOS system will now automatically update itself every 3 hours, keeping your system secure and up-to-date with minimal intervention!

To verify everything is working, check the timer status:

```bash
sudo systemctl list-timers cachyos-update.timer
```

Happy updating! 🚀
