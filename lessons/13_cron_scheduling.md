# ⏰ STACK 13: CRON & SCHEDULING
## Automate Your Scripts with Cron

Think of cron as your personal assistant that never sleeps - it runs your scripts automatically at the times you specify, like setting alarms for your code.

---

## 🔰 What is Cron?

**Cron** = Named after Chronos (Greek word for "time")

**Cron** is a time-based job scheduler in Unix-like systems. It lets you run scripts automatically at specified times - perfect for:
- ✅ **Backups** - Daily database dumps at 2 AM
- ✅ **Monitoring** - Check disk space every 5 minutes
- ✅ **Cleanup** - Delete old logs weekly
- ✅ **Reports** - Generate daily system reports

### The Cron Daemon (Background Service)
Cron runs as a background service (daemon) that checks every minute if any jobs need to run.

```bash
# Check if cron is running
sudo systemctl status cron    # Debian/Ubuntu
sudo systemctl status crond   # RedHat/CentOS

# Start cron if it's not running
sudo systemctl start cron

# Enable cron to start on boot
sudo systemctl enable cron
```

---

## ⏱ Cron Syntax (The Time Format)

Cron uses a simple 5-field format to specify when a job should run:

```
┌───────────── minute (0 - 59)
│ ┌─────────── hour (0 - 23)
│ │ ┌───────── day of month (1 - 31)
│ │ │ ┌─────── month (1 - 12)
│ │ │ │ ┌───── day of week (0 - 6) (Sunday = 0 or 7)
│ │ │ │ │
* * * * * command to execute
```

**Pro Tip:** Read it left to right: "At minute X, of hour Y, on day Z..."

### Special Characters (Make Scheduling Easier)

| Character | Meaning | Example | What It Does |
|-----------|---------|---------|--------------|
| `*` | Any value | `* * * * *` | Every minute |
| `,` | List values | `0,30 * * * *` | At minute 0 AND 30 |
| `-` | Range | `0 9-17 * * *` | Every hour from 9am to 5pm |
| `/` | Step values | `*/5 * * * *` | Every 5 minutes |

---

## 📋 Common Cron Examples

**Beginner Tip:** Start with simple schedules and test with `* * * * *` (every minute) to verify your script works!

### Every minute
```cron
* * * * * /path/to/script.sh
```

### Every hour (at minute 0)
```cron
0 * * * * /path/to/script.sh
```

### Every day at midnight
```cron
0 0 * * * /path/to/script.sh
```

### Every day at 3:30 AM (great for maintenance tasks)
```cron
30 3 * * * /path/to/script.sh
```

### Every Monday at 9 AM
```cron
0 9 * * 1 /path/to/script.sh
```

### First day of every month at midnight
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

### Every 6 hours (midnight, 6am, noon, 6pm)
```cron
0 */6 * * * /path/to/script.sh
```

---

## 🛠 Managing Cron Jobs

### View Current User's Crontab
```bash
crontab -l
# Shows all your scheduled jobs
```

### Edit Crontab (Add/Remove Jobs)
```bash
crontab -e
# Opens your cron jobs in a text editor (usually nano or vim)
# Add your schedules, save, and exit
```

**Pro Tip:** First time running `crontab -e`? It'll ask you to choose an editor. Pick `nano` if you're a beginner - it's easier to use!

### Remove All Crontabs
```bash
crontab -r
# WARNING: This deletes ALL your cron jobs instantly!
```

### View Other User's Crontab (Requires sudo)
```bash
crontab -u username -l
```

### System Crontab (For Root/Admin Tasks)
```bash
# Edit system-wide crontab (runs as root)
sudo crontab -e

# View system crontab
sudo crontab -l
```

### Cron Directories (The Easy Way - No Cron Syntax Needed!)
Instead of learning cron syntax, just drop scripts in these folders:

```bash
# Scripts here run automatically at these intervals:
/etc/cron.hourly/    # Once per hour
/etc/cron.daily/     # Once per day (usually around 6:25 AM)
/etc/cron.weekly/    # Once per week (usually Sunday)
/etc/cron.monthly/   # Once per month (1st of the month)

# Just make your script executable and copy it there:
chmod +x my_backup.sh
sudo cp my_backup.sh /etc/cron.daily/
```

---

## 📝 Cron Job Best Practices

### 1. Always Use Full Paths
Cron doesn't know where your files are - it runs with minimal environment.

```cron
# ✅ Good - Full paths for everything
0 0 * * * /home/user/scripts/backup.sh >> /home/user/logs/backup.log 2>&1

# ❌ Bad - These will FAIL in cron
0 0 * * * ./backup.sh              # Relative path won't work
0 0 * * * backup.sh                # Cron doesn't know where to look
```

### 2. Redirect Output (Log Everything!)
Cron emails you output by default, but logs are better for debugging.

```cron
# Log output (append mode with >>)
0 0 * * * /path/to/script.sh >> /var/log/script.log 2>&1

# Log with timestamps (even better!)
0 0 * * * /path/to/script.sh >> /var/log/script.log 2>&1 || echo "$(date): FAILED" >> /var/log/script.log

# Suppress all output (use carefully - you won't see errors)
0 0 * * * /path/to/script.sh > /dev/null 2>&1
```

**Pro Tip:** The `2>&1` means "send error messages to the same place as normal output". Without it, errors might still get emailed to you!

### 3. Set Environment Variables
Cron has a minimal environment - set what you need.

```cron
# Set PATH at the top of your crontab
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash

# Now your jobs can find commands
0 0 * * * /path/to/script.sh
```

### 4. Test Before Scheduling
Always test your script manually first:

```bash
# Test it works
/home/user/scripts/backup.sh

# Check the exit code
echo $?  # Should be 0 for success
```

---

## 🔧 Anacron - For Laptops & Non-24/7 Systems

**Problem with Cron:** If your computer is off when a job is scheduled, it won't run.

**Solution:** Anacron runs missed jobs when the system boots up next.

### Install Anacron
```bash
sudo apt install anacron    # Debian/Ubuntu
sudo yum install anacron    # RedHat/CentOS
```

### Anacron Configuration
```bash
# Edit anacrontab
sudo nano /etc/anacrontab

# Format: period delay job-identifier command
# period = Run every N days (or @daily, @weekly, @monthly)
# delay = Minutes to wait after boot before running
# Example:
1       5       backup  /home/user/scripts/backup.sh
@weekly 10      cleanup /home/user/scripts/cleanup.sh
```

**How it works:** If a weekly job was missed, anacron runs it 10 minutes after boot (gives system time to stabilize first).

---

## ⏰ Using `at` Command (One-Time Scheduling)

**When to use `at`:** You need to run something once at a specific time (not recurring like cron).

### Schedule a One-Time Job
```bash
# Run in 1 hour
at now + 1 hour
at> /path/to/script.sh
at> <Ctrl+D>   # Press Ctrl+D to save

# Run at specific time
at 3:30 PM
at> /path/to/script.sh
at> <Ctrl+D>

# Run tomorrow at 9 AM
at 9am tomorrow
at> /path/to/script.sh
at> <Ctrl+D>

# Run on a specific date
at 2025-12-31 23:59
at> echo "Happy New Year!" | mail -s "Reminder" user@email.com
at> <Ctrl+D>
```

### View Scheduled `at` Jobs
```bash
atq
# or
at -l

# Example output:
# 3  2025-04-09 09:00 a user
# 5  2025-04-10 15:30 a user
```

### Remove an `at` Job
```bash
atrm job_number
# Example:
atrm 3
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

## 🔔 Systemd Timers (Modern Alternative to Cron)

**Why use systemd timers?** Better logging, dependency management, and integration with modern Linux systems.

### Step 1: Create a Service Unit
This defines WHAT to run.

```bash
# Create: /etc/systemd/system/myscript.service
sudo nano /etc/systemd/system/myscript.service
```

```ini
[Unit]
Description=My Scheduled Script

[Service]
Type=oneshot
ExecStart=/home/user/scripts/myscript.sh
```

### Step 2: Create a Timer Unit
This defines WHEN to run it.

```bash
# Create: /etc/systemd/system/myscript.timer
sudo nano /etc/systemd/system/myscript.timer
```

```ini
[Unit]
Description=Run myscript every hour

[Timer]
# Wait 5 minutes after boot, then run every hour
OnBootSec=5min
OnUnitActiveSec=1h
Unit=myscript.service

[Install]
WantedBy=timers.target
```

### Step 3: Enable and Start the Timer
```bash
# Reload systemd to see new units
sudo systemctl daemon-reload

# Enable timer (starts on boot)
sudo systemctl enable myscript.timer

# Start timer now
sudo systemctl start myscript.timer
```

### Step 4: Check Timer Status
```bash
# List all active timers
systemctl list-timers

# Check specific timer status
systemctl status myscript.timer

# View timer details
systemctl show myscript.timer
```

**Pro Tip:** Systemd timers are more powerful than cron - they can handle dependencies (e.g., "run after network is ready") and have better logging via `journalctl`.

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

## 🎓 Final Project: Building a Task Scheduler

Now that you've mastered Cron and `at`, let's look at how a professional scripter might build a tool to manage these tasks. We'll examine the "Task Scheduler" — a script that makes adding, removing, and managing cron jobs much easier.

### What the Task Scheduler Does:
1. **List** all active cron jobs.
2. **Add** new jobs with a simple command (no need to open `crontab -e`).
3. **Remove** existing jobs by name.
4. **Enable/Disable** jobs without deleting them.
5. **Backup/Restore** your entire crontab.

### Key Snippet: Adding a Job Programmatically
One of the coolest tricks in the scheduler is adding a cron job without using the interactive editor:

```bash
# How to add a job from a script:
(crontab -l 2>/dev/null; echo "$schedule $script_path") | crontab -
```
*   `crontab -l` gets your current jobs.
*   `echo` adds the new line.
*   `| crontab -` sends the whole thing back to be saved.

### Key Snippet: Enabling/Disabling Jobs
The scheduler can "disable" a job by commenting it out (`#`) and "enable" it by removing the `#`.

```bash
# Disable a job using sed
crontab -l | sed "s|$script_path|#$script_path|" | crontab -
```

**Pro Tip:** Building your own "wrapper" scripts like this is how you turn basic Bash skills into powerful automation tools!

---

## ✅ Stack 13 Complete!

You've successfully mastered the art of time-traveling for your scripts! You can now:
- ✅ **Automate anything** using the power of Cron
- ✅ **Schedule one-off tasks** with the `at` command
- ✅ **Understand Cron syntax** like a pro (* * * * *)
- ✅ **Use modern alternatives** like Systemd timers
- ✅ **Manage system-wide tasks** safely

### What's Next?
In the next stack, we'll dive into **Git for Scripters**. You'll learn how to use version control to keep your scripts safe, track changes, and never lose a working version of your code again!

**Next: Stack 14 - Git for Scripters →**

---

*End of Stack 13*