# ⏰ STACK 13: CRON & SCHEDULING
## Automate Your Scripts with Cron

---

## 🔰 What is Cron?

**Cron** = Greek word for "time"

- A time-based job scheduler in Unix-like systems
- Runs scripts automatically at specified times
- Perfect for backups, monitoring, cleanup tasks

### Cron Daemon
```bash
# Check if cron is running
sudo systemctl status cron    # Debian/Ubuntu
sudo systemctl status crond    # RedHat/CentOS

# Start cron
sudo systemctl start cron

# Enable cron on boot
sudo systemctl enable cron
```

---

## ⏱ Cron Syntax

```
┌───────────── minute (0 - 59)
│ ┌─────────── hour (0 - 23)
│ │ ┌───────── day of month (1 - 31)
│ │ │ ┌─────── month (1 - 12)
│ │ │ │ ┌───── day of week (0 - 6) (Sunday = 0)
│ │ │ │ │
* * * * * command
```

### Special Characters

| Character | Meaning | Example |
|-----------|---------|---------|
| `*` | Any value | `* * * * *` = every minute |
| `,` | List separator | `1,15 * * * *` = at 1 and 15 min |
| `-` | Range | `0 9-17 * * *` = every hour 9am-5pm |
| `/` | Step | `*/5 * * * *` = every 5 minutes |

---

## 📋 Common Cron Examples

### Every minute
```cron
* * * * * /path/to/script.sh
```

### Every hour
```cron
0 * * * * /path/to/script.sh
```

### Every day at midnight
```cron
0 0 * * * /path/to/script.sh
```

### Every day at 3:30 AM
```cron
30 3 * * * /path/to/script.sh
```

### Every Monday at 9 AM
```cron
0 9 * * 1 /path/to/script.sh
```

### First day of every month
```cron
0 0 1 * * /path/to/script.sh
```

### Every 15 minutes
```cron
*/15 * * * * /path/to/script.sh
```

### Every weekday (Mon-Fri) at 6 PM
```cron
0 18 * * 1-5 /path/to/script.sh
```

### Twice daily (9 AM and 6 PM)
```cron
0 9,18 * * * /path/to/script.sh
```

---

## 🛠 Managing Cron Jobs

### View Current User's Crontab
```bash
crontab -l
```

### Edit Crontab
```bash
crontab -e
```

### Remove All Crontabs
```bash
crontab -r
```

### View Other User's Crontab
```bash
crontab -u username -l
```

### System Crontab (System-wide)
```bash
# Edit system crontab
sudo crontab -e

# View system crontab
sudo crontab -l -u root
```

### Cron Directories (Easier Way)
```bash
# These run automatically
/etc/cron.daily/    # Once a day
/etc/cron.hourly/   # Once an hour
/etc/cron.weekly/   # Once a week
/etc/cron.monthly/  # Once a month
```

---

## 📝 Cron Job Best Practices

### Use Full Paths
```cron
# ✅ Good - Full path
0 0 * * * /home/user/scripts/backup.sh

# ❌ Bad - Relative path will fail
0 0 * * * ./backup.sh
```

### Redirect Output
```cron
# Log output
0 0 * * * /path/to/script.sh >> /var/log/script.log 2>&1

# Suppress output
0 0 * * * /path/to/script.sh > /dev/null 2>&1
```

### Set Environment Variables
```cron
PATH=/usr/local/bin:/usr/bin:/bin
0 0 * * * /path/to/script.sh
```

---

## 🔧 Anacron - For Systems Not Running 24/7

### Install Anacron
```bash
sudo apt install anacron    # Debian/Ubuntu
sudo yum install anacron   # RedHat/CentOS
```

### Anacron Configuration
```bash
# /etc/anacrontab
# format: delay delay job-identifier command
# delay = minutes to wait after boot
# job-identifier = unique name for the job

1       5       backup  /home/user/scripts/backup.sh
@weekly 10      cleanup /home/user/scripts/cleanup.sh
```

---

## ⏰ Using `at` Command (One-Time Scheduling)

### Schedule a One-Time Job
```bash
# Run in 1 hour
at now + 1 hour
/path/to/script.sh
# Press Ctrl+D to save

# Run at specific time
at 3:30 PM
/path/to/script.sh
# Press Ctrl+D to save

# Run tomorrow at 9 AM
at 9am tomorrow
/path/to/script.sh
# Press Ctrl+D to save
```

### View Scheduled Jobs
```bash
atq
# or
at -l
```

### Remove a Job
```bash
atrm job_number
```

---

## 📊 Practical Examples

### Example 1: Daily Backup Script
```bash
# crontab -e
# Run backup every night at 2 AM

0 2 * * * /home/user/scripts/daily_backup.sh >> /var/log/backup.log 2>&1
```

### Example 2: Log Rotation
```bash
# Run every week on Sunday at 3 AM
0 3 * * 0 /home/user/scripts/rotate_logs.sh
```

### Example 3: Disk Space Check
```bash
# Check every hour
0 * * * * /home/user/scripts/check_disk.sh | mail -s "Disk Alert" admin@example.com
```

### Example 4: Database Cleanup
```bash
# Run at 4 AM on the 1st of each month
0 4 1 * * /home/user/scripts/cleanup_database.sh
```

### Example 5: Health Check
```bash
# Every 5 minutes
*/5 * * * * /home/user/scripts/health_check.sh
```

---

## 🔔 Systemd Timers (Modern Alternative)

### Create a Timer Service
```bash
# /etc/systemd/system/myscript.service
[Unit]
Description=My Scheduled Script

[Service]
Type=oneshot
ExecStart=/home/user/scripts/myscript.sh

[Install]
WantedBy=multi-user.target
```

### Create a Timer
```bash
# /etc/systemd/system/myscript.timer
[Unit]
Description=Run myscript every hour

[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
Unit=myscript.service

[Install]
WantedBy=timers.target
```

### Enable Timer
```bash
sudo systemctl daemon-reload
sudo systemctl enable myscript.timer
sudo systemctl start myscript.timer
```

### Check Timer Status
```bash
systemctl list-timers
systemctl status myscript.timer
```

---

## 🏆 Practice Exercises

### Exercise 1: Create a Simple Cron Job
```bash
# 1. Create a script that logs the date
cat > ~/scripts/log_time.sh << 'EOF'
#!/bin/bash
echo "$(date): Script ran" >> /tmp/cron_test.log
EOF

# 2. Make it executable
chmod +x ~/scripts/log_time.sh

# 3. Add to crontab (every minute for testing)
crontab -e
# Add: */1 * * * * /home/user/scripts/log_time.sh

# 4. Check after a minute
tail /tmp/cron_test.log
```

### Exercise 2: Schedule a System Report
```bash
# Create a system report script
cat > ~/scripts/sys_report.sh << 'EOF'
#!/bin/bash
REPORT="/tmp/sys_report_$(date +%Y%m%d).txt"
{
    echo "=== System Report ==="
    echo "Date: $(date)"
    echo "Uptime: $(uptime)"
    echo "Disk Usage:"
    df -h
    echo "Top Processes:"
    ps aux --sort=-%mem | head -5
} > "$REPORT"
EOF

chmod +x ~/scripts/sys_report.sh

# Schedule to run daily at 7 AM
crontab -e
# Add: 0 7 * * * /home/user/scripts/sys_report.sh
```

### Exercise 3: Cleanup Old Files
```bash
# Create cleanup script
cat > ~/scripts/cleanup.sh << 'EOF'
#!/bin/bash
# Delete files older than 7 days in /tmp
find /tmp -type f -mtime +7 -delete
# Delete old logs
find /var/log -name "*.log" -mtime +30 -delete
EOF

chmod +x ~/scripts/cleanup.sh

# Schedule to run daily at 3 AM
crontab -e
# Add: 0 3 * * * /home/user/scripts/cleanup.sh
```

---

## 📋 Cron Cheat Sheet

| Schedule | Cron Expression |
|----------|-----------------|
| Every minute | `* * * * *` |
| Every hour | `0 * * * *` |
| Every day at midnight | `0 0 * * *` |
| Every day at noon | `0 12 * * *` |
| Every Monday | `0 0 * * 1` |
| First of month | `0 0 1 * *` |
| Every 5 minutes | `*/5 * * * *` |
| Every 30 minutes | `*/30 * * * *` |

---

## ✅ Stack 13 Complete!

You learned:
- ✅ What is Cron and how it works
- ✅ Cron syntax and special characters
- ✅ Managing cron jobs (crontab)
- ✅ Using `at` for one-time scheduling
- ✅ Systemd timers (modern alternative)
- ✅ Creating practical scheduled tasks

### Next: More stacks coming soon! →
### Or revisit previous stacks for practice!

---

## 📝 Challenge: Build Your Own Scheduler

Create a comprehensive backup scheduler that:
1. Runs full backup weekly
2. Runs incremental backup daily
3. Cleans up old backups monthly
4. Sends email notifications on failure

---

*End of Stack 13*