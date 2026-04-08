# ⏰ STACK 24: ADVANCED SCHEDULING
## Cron vs Systemd Timers

**Building on Stack 13:** You already know cron basics. Now let's level up - learn when to use cron vs systemd timers, handle dependencies between jobs, and avoid scheduling pitfalls.

**Quick Decision Guide:**
- **Use Cron** when: Simple schedules, legacy systems, quick one-liners
- **Use Systemd Timers** when: You need dependencies, logging, or complex timing

---

## 🔰 Why Advanced Scheduling?

Cron is classic, but Systemd timers offer:
- ✅ **Better dependency handling** - "Run this AFTER network is ready"
- ✅ **Precise timing control** - Sub-second accuracy if needed
- ✅ **Built-in logging** - No more guessing if jobs ran
- ✅ **Persistence across reboots** - Never miss a scheduled run
- ✅ **Better resource management** - Control CPU/memory per job

### When to Use What?
```
Simple schedule (daily backup)?          → Cron ✅
Need to run after another service?       → Systemd Timer ✅
Running on an old server without systemd? → Cron ✅
Need detailed logs of every run?         → Systemd Timer ✅
Quick one-off task?                       → at command ✅
```

---

## ⚙️ Cron Deep Dive

### Basic Cron Syntax
```bash
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday=0)
# │ │ │ │ │
# * * * * * command
```

### Common Examples
```bash
# Every minute
* * * * * /path/to/script.sh

# Every hour at minute 30
30 * * * * /path/to/script.sh

# Daily at 3:30 AM
30 3 * * * /path/to/script.sh

# Every Monday at 5 PM
0 17 * * 1 /path/to/script.sh

# First day of every month
0 0 1 * * /path/to/script.sh

# Every 15 minutes
*/15 * * * * /path/to/script.sh

# Multiple times (3 AM and 6 AM)
0 3,6 * * * /path/to/script.sh

# Range (9 AM to 5 PM every hour)
0 9-17 * * * /path/to/script.sh
```

### Cron Environment
```bash
# In crontab, you have minimal environment
# Always use full paths!

# BAD
* * * * * script.sh

# GOOD
* * * * * /home/user/scripts/script.sh

# With PATH
PATH=/usr/local/bin:/usr/bin:/bin
* * * * * mycommand

# Redirect output
* * * * * /path/to/script.sh >> /var/log/script.log 2>&1

# Run as specific user (system crontab)
/etc/crontab format:
* * * * * root /path/to/script.sh
```

### User Crontabs
```bash
# Edit your crontab
crontab -e

# List your crontab
crontab -l

# Remove all crontab entries
crontab -r

# Edit system crontab (as root)
sudo crontab -e

# View system crontab
sudo crontab -l
```

### Cron Directories
```bash
# These run automatically based on naming
/etc/cron.daily/    # Once a day
/etc/cron.hourly/   # Once an hour
/etc/cron.monthly/ # Once a month
/etc/cron.d/        # Custom (system)

# Add script to daily
sudo cp myscript.sh /etc/cron.daily/
sudo chmod +x /etc/cron.daily/myscript.sh
```

---

## 🔧 Systemd Timers

### Timer Unit File
```ini
# /etc/systemd/system/mytimer.timer
[Unit]
Description=My Scheduled Task Timer
Requires=mytimer.service

[Timer]
# Run 5 minutes after boot
OnBootSec=5min

# Run every day at 3 AM
OnCalendar=*-*-* 03:00:00

# Run every hour
OnCalendar=hourly

# Run every Monday at 5 PM
OnCalendar=Mon *-*-* 17:00:00

# Run every 30 minutes
OnCalendar=*:0/30

# Persistent - run missed jobs after reboot
Persistent=true

# Random delay (avoid thundering herd)
RandomizedDelaySec=5min

[Install]
WantedBy=timers.target
```

### Service Unit File
```ini
# /etc/systemd/system/mytimer.service
[Unit]
Description=My Scheduled Task

[Service]
Type=oneshot
ExecStart=/usr/local/bin/myscript.sh
WorkingDirectory=/home/user

# Environment
Environment=VAR=value

# Logging
StandardOutput=journal
StandardError=journal
```

### Managing Timers
```bash
# Start immediately
sudo systemctl start mytimer.timer

# Enable at boot
sudo systemctl enable mytimer.timer

# Check status
systemctl status mytimer.timer

# List all timers
systemctl list-timers

# View logs
journalctl -u mytimer.service
journalctl -u mytimer.timer

# View next run times
systemctl list-timers --all

# Stop timer
sudo systemctl stop mytimer.timer

# Disable timer
sudo systemctl disable mytimer.timer
```

### Calendar Time Formats
```bash
# Specific date and time
OnCalendar=2024-12-25 10:00:00    # Christmas at 10 AM

# Daily at midnight
OnCalendar=daily

# Weekly (Sunday)
OnCalendar=weekly

# Monthly (first day)
OnCalendar=monthly

# Yearly
OnCalendar=yearly

# Complex schedules
OnCalendar=*-*-1,15 09:00:00      # 1st and 15th at 9 AM
OnCalendar=Mon-Fri *-*-* 09:00:00  # Weekdays at 9 AM
OnCalendar=*:*:0/15                 # Every 15 seconds (for testing)
```

### Monotonic Timers
```ini
# Run after specific events
[Timer]
# 10 minutes after boot
OnBootSec=10min

# 1 hour after waking from suspend
OnUnitActiveSec=1h

# Every 24 hours from last activation
OnUnitActiveSec=24h

# Run 5 minutes after login of any user
OnUnitActiveSec=5min
```

---

## ⚖️ Cron vs Systemd Timers

| Feature | Cron | Systemd Timer |
|---------|------|---------------|
| Syntax | Simple | More complex |
| Dependencies | Limited | Full dependency handling |
| Persistence | Needs external tools | Built-in (Persistent=) |
| Random delay | External (anacron) | Built-in (RandomizedDelaySec=) |
| Boot time | Needs hacky solutions | OnBootSec= |
| Resource control | None | cgroups support |
| Logging | Manual setup | Automatic (journal) |
| Status | Limited | Detailed (systemctl) |
| Matrix/Grid | No | Yes (OnCalendar) |

---

## 🎯 Choosing the Right Tool

### Use Cron When:
- Simple, recurring schedules
- System already configured with cron
- Need compatibility across Linux/Unix
- No complex dependencies

### Use Systemd Timers When:
- Need dependency handling (start after another service)
- Need precise control (random delays, boot time)
- Need better logging and debugging
- Need to run on specific system events
- Long-running or resource-intensive tasks

---

## 📝 Practical Examples

### Example 1: Database Backup
```bash
# Systemd Timer - Better for important backups
# /etc/systemd/system/backup.timer
[Unit]
Description=Database Backup Timer

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/backup.service
[Unit]
Description=Database Backup Service
After=mysql.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-db.sh
```

### Example 2: Log Rotation
```bash
# Cron is fine for simple log rotation
# /etc/cron.daily/logrotate
0 0 * * * root /usr/sbin/logrotate /etc/logrotate.conf
```

### Example 3: Health Check
```bash
# Systemd for responsive health checks
# /etc/systemd/system/healthcheck.timer
[Unit]
Description=Health Check Timer

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

---

## 🔍 Troubleshooting

### Cron Issues
```bash
# Check cron is running
sudo systemctl status cron
sudo systemctl status crond

# Check logs
sudo journalctl -u cron
sudo tail /var/log/cron
sudo tail /var/log/syslog | grep CRON

# Test manually first
# Make sure script runs without cron first!

# Check environment
* * * * * env > /tmp/env.txt
# Then check /tmp/env.txt
```

### Systemd Timer Issues
```bash
# Check timer is active
systemctl status mytimer.timer

# Check next run
systemctl list-timers

# View detailed logs
journalctl -u mytimer.service -f

# Check for failures
systemctl list-units --failed

# Verify unit files
systemd-analyze verify mytimer.timer
```

---

## 📋 Best Practices

### For Cron
```bash
# Always redirect output
0 3 * * * /script.sh >> /var/log/script.log 2>&1

# Use locking to prevent overlaps
0 3 * * * /usr/bin/flock -n /var/lock/script.lock /script.sh

# Use full paths
0 3 * * * /usr/local/bin/script.sh

# Add email on error
MAILTO=admin@example.com
0 3 * * * /script.sh
```

### For Systemd Timers
```ini
# Always use Type=oneshot for timers
Type=oneshot

# Add proper dependencies
After=network.target

# Set reasonable timeouts
TimeoutStartSec=60

# Enable only (don't just start)
WantedBy=timers.target
```

---

## ✅ Stack 24 Complete!

You learned:
- ✅ Cron syntax and common patterns
- ✅ Cron environment and best practices
- ✅ Systemd timer unit files
- ✅ Systemd service unit files
- ✅ Calendar and monotonic timers
- ✅ When to use each tool

### Next: Stack 25 - Zsh Essentials →

---

*End of Stack 24*
