# 🔧 STACK 27: SYSTEMD DEEP DIVE
## Modern Service Management in Linux

**What is Systemd?** Think of systemd as the "conductor" of your Linux system's orchestra. Just as a conductor ensures all musicians play together at the right time, systemd coordinates all the different parts of your Linux system to work in harmony.

**Why Care?** Systemd is how you start/stop/restart services, check logs, and automate tasks on modern Linux. It's essential knowledge because:
- It's the first process that starts when your computer boots (PID 1)
- It manages everything that runs on your system
- Understanding it gives you powerful control over your Linux environment
- Nearly every modern Linux distribution uses it (Ubuntu, Debian, Fedora, CentOS, etc.)

---

## 🔰 What is Systemd?

Systemd is the "system and service manager" for Linux - it's the backbone that keeps everything running smoothly. Think of it as the air traffic controller for your computer's processes.

**The Technical Definition:** Systemd is the init system (PID 1) - the very first process that starts when your computer boots, with process ID number 1. All other processes are its children.

**In Plain English:** When you turn on your computer, systemd is like the stage manager who:
- Shows up first and turns on the lights
- Reads the schedule of what needs to happen and when
- Makes sure each actor (service) enters at the right time
- Steps in if someone forgets their lines (restarts crashed services)
- Takes detailed notes of everything that happens (logging)
- Makes sure the show runs smoothly from start to finish

### Why Systemd? (The Benefits)

Systemd solved many problems with older Linux initialization systems. Here's what makes it special:

- ⚡ **Faster Boot Times**: Instead of waiting for one service to finish before starting the next, systemd can start multiple services at the same time (when they don't depend on each other). This can cut boot time in half or more!

- 🔗 **Smart Dependencies**: Systemd understands that your web server needs networking to be up before it can start. It automatically starts services in the right order based on what they need.

- 📋 **Built-in Logging**: No more wondering where service logs went. With `journalctl`, you can easily view logs for any service in one consistent place.

- 🎯 **Unified Control**: Whether you want to start, stop, check status, or configure a service, you use the same command: `systemctl`. No more remembering different commands for different services.

- ⚡ **On-Demand Services**: With socket activation, services like printing or Bluetooth only start up when actually needed, saving memory and CPU when idle.

- 🔒 **Enhanced Security**: Systemd can isolate services using Linux security features, limiting what they can do if compromised.

- 💾 **Persistence**: Services configured to start at boot will reliably do so, even after power failures or system crashes.

### Simple Systemd Analogy

Imagine your Linux system as a restaurant:

```
Your computer boots up:
1. Systemd arrives first and unlocks the doors (PID 1)
2. Checks the reservation list and staff schedule (reads unit files)
3. Makes sure the kitchen opens before the dining room (starts services in order)
4. Fills in if a staff member calls out sick (restarts crashed services)
5. Keeps a detailed log of who did what and when (journalctl)
6. Ensures smooth service from opening to closing
```

**Real-World Example:** When you install a web server like nginx:
1. Systemd makes sure networking is ready first
2. Then starts nginx
3. If nginx crashes, systemd automatically restarts it
4. You can check nginx's health with `systemctl status nginx`
5. You can view nginx's logs with `journalctl -u nginx`
6. When you reboot, systemd automatically starts nginx again

---

## 📋 Systemd Components: The Team Players

Systemd isn't just one program - it's a suite of tools that work together to manage your Linux system. Think of them as specialized departments in a company, each handling a specific aspect of system operations.

| Component | What It Does | Real-World Analogy |
|-----------|--------------|---------------------|
| **systemd** | The main process (PID 1) that starts everything else and manages services | The CEO/General Manager |
| **systemd-analyze** | Tools to examine boot performance and service dependencies | The Efficiency Expert |
| **systemd-logind** | Manages user logins and sessions (both local and remote) | The Front Desk/Reception |
| **systemd-networkd** | Handles network configuration (alternative to NetworkManager) | The IT Network Team |
| **systemd-resolved** | Provides network name resolution (DNS caching and resolution) | The Company Operator |
| **journald** | The logging service that collects and manages system logs | The Records/Archives Department |

**Key Insight:** While systemd is the central process, you'll most frequently interact with:
- `systemctl` - for managing services (the main control interface)
- `journalctl` - for viewing logs (your window into what's happening)
- `systemd-analyze` - for troubleshooting performance issues

---

## 🏢 Managing Services: Your Remote Control for Linux

Think of `systemctl` as your TV remote control for Linux services. Instead of getting up to manually start/stop each service, you can control them all from one place with simple commands.

### Basic Service Commands: The Essentials

These are the commands you'll use 90% of the time when working with services:

```bash
# Start a service (turn it on)
sudo systemctl start nginx

# Stop a service (turn it off)
sudo systemctl stop nginx

# Restart a service (turn off, then on again)
sudo systemctl restart nginx

# Reload a service (apply new config without stopping)
sudo systemctl reload nginx

# Check a service's status (is it running? healthy?)
sudo systemctl status nginx

# Enable a service to start automatically at boot
sudo systemctl enable nginx

# Prevent a service from starting at boot
sudo systemctl disable nginx

# Check if a service is set to start at boot
systemctl is-enabled nginx

# Check if a service is currently running
systemctl is-active nginx
```

**Pro Tip:** Most of these commands require `sudo` because they change system settings. The `is-enabled` and `is-active` commands are exceptions - they just check status so don't need sudo.

**Service Name Examples:** Replace `nginx` with whatever service you're managing:
- `apache2` or `httpd` (web server)
- `mysql` or `mariadb` (database)
- `ssh` (secure shell for remote access)
- `docker` (container platform)
- `postgresql` (database)
- `mongodb` (NoSQL database)

### Understanding What These Commands Actually Do

Let's demystify what happens behind the scenes:

- **`systemctl start nginx`**: Tells systemd to begin running the nginx service right now
- **`systemctl stop nginx`**: Tells systemd to stop the nginx service right now
- **`systemctl restart nginx`**: Stops nginx if it's running, then starts it again
- **`systemctl reload nginx`**: Asks nginx to refresh its configuration files without stopping (if it supports this)
- **`systemctl status nginx`**: Shows whether nginx is active, recent log output, and main process ID
- **`systemctl enable nginx`**: Creates a symbolic link so nginx starts automatically when the system boots
- **`systemctl disable nginx`**: Removes the automatic startup link

**Quick Health Check:** When you're unsure if a service is working, this is your go-to sequence:
```bash
sudo systemctl status servicename     # Is it active?
sudo journalctl -u servicename -n 20  # What's it been doing lately?
```

**Common Service Management Scenarios:**

1. **After making config changes:**
   ```bash
   sudo systemctl reload servicename   # Try gentle reload first
   # If that doesn't work or isn't supported:
   sudo systemctl restart servicename  # Full restart
   ```

2. **When a service seems stuck:**
   ```bash
   sudo systemctl status servicename   # Check what state it's in
   sudo systemctl restart servicename  # Give it a fresh start
   ```

3. **To make a service start automatically:**
   ```bash
   sudo systemctl enable servicename   # Survives reboots
   sudo systemctl start servicename    # Start it now too
   ```

4. **To temporarily stop a service:**
   ```bash
   sudo systemctl stop servicename     # Off until next boot or manual start
   sudo systemctl disable servicename  # Also prevent auto-start at boot
   ```

### Service States
```bash
# List all active services
systemctl list-units --type=service

# List failed services
systemctl --failed

# List all installed service files
systemctl list-unit-files
```

---

## 📝 Creating a Service

### Simple Service File
```bash
# /etc/systemd/system/myservice.service
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/home/ubuntu/myscript.sh
Restart=always
RestartSec=10

# Environment variables
Environment=PORT=8080
EnvironmentFile=/etc/myservice.env

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myservice

[Install]
WantedBy=multi-user.target
```

### Service Types

| Type | Description |
|------|-------------|
| simple | Default, process runs continuously |
| forking | Process forks background daemon |
| oneshot | Runs once and exits |
| notify | Signals when ready |
| idle | Waits until all jobs before completing |

---

## ⏱️ Creating Timers

### Timer Unit File
```bash
# /etc/systemd/system/mytask.timer
[Unit]
Description=Run mytask daily

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
```

### Paired Service
```bash
# /etc/systemd/system/mytask.service
[Unit]
Description=My Scheduled Task

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mytask.sh
```

### Timer Management
```bash
# Start timer
sudo systemctl start mytask.timer

# Enable timer (at boot)
sudo systemctl enable mytask.timer

# List active timers
systemctl list-timers

# Check timer status
systemctl status mytask.timer
```

### Timer Schedule Formats
```bash
# Daily at midnight
OnCalendar=daily

# Weekly on Sunday at 3 AM
OnCalendar=Sun *-*-* 03:00:00

# Every hour
OnCalendar=hourly

# Every 15 minutes
OnCalendar=*:0/15

# Specific time
OnCalendar=*-*-* 09:00:00
```

---

## 📊 Systemd Targets

### Common Targets
```bash
# Graphical target (GUI)
sudo systemctl set-default graphical.target

# Multi-user (text mode)
sudo systemctl set-default multi-user.target

# Current target
systemctl get-default

# Switch target (without reboot)
sudo systemctl isolate multi-user.target
```

### Target Units
| Target | Purpose |
|--------|---------|
| graphical.target | GUI login |
| multi-user.target | Text login |
| rescue.target | Single user mode |
| emergency.target | Emergency shell |
| reboot.target | Reboot |
| poweroff.target | Power off |

---

## 📈 Monitoring Services

### View Logs (journalctl)
```bash
# View service logs
sudo journalctl -u nginx

# Follow logs in real-time
sudo journalctl -u nginx -f

# View recent logs
sudo journalctl -u nginx -n 50

# Since specific time
sudo journalctl -u nginx --since "1 hour ago"

# Since specific date
sudo journalctl -u nginx --since "2024-01-01"

# Filter by priority
sudo journalctl -p err

# Priority levels: emerg, alert, crit, err, warning, notice, info, debug
```

### System Performance
```bash
# Analyze boot time
systemd-analyze

# Breakdown by service
systemd-analyze blame

# Critical chain
systemd-analyze critical-chain

# Dot file (dependencies)
systemd-analyze dot | dot -Tsvg > graph.svg
```

---

## 🔧 Advanced Configuration

### Dependencies
```bash
# /etc/systemd/system/myservice.service
[Unit]
Description=My Service
# Start after network is up
After=network.target
# Requires network
Requires=network.target
# Wants doesn't enforce requirement
Wants=network-online.target
```

### Resource Limits
```bash
[Service]
# Memory limit
MemoryMax=1G
MemoryHigh=512M

# CPU limit (percentage)
CPUQuota=50%

# Number of processes
TasksMax=100
```

### Sandboxing (Security)
```bash
[Service]
# Restrict access
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/var/log/myservice

# Drop capabilities
AmbientCapabilities=CAP_NET_BIND_SERVICE
```

---

## 🔄 Service Dependencies

### Visualizing Dependencies
```bash
# Generate dependency graph
systemd-analyze dot | grep "after" > deps.dot
```

### Common Dependencies
```bash
# Network dependent
After=network.target
After=network-online.target

# Storage dependent
After=local-fs.target

# Time dependent
After=time-set.target
```

---

## 🎯 Troubleshooting

### Common Issues
```bash
# Service failed to start
sudo systemctl status nginx
sudo journalctl -u nginx -n 50

# Check configuration
systemd-analyze verify /etc/systemd/system/myservice.service

# Reload systemd (after changes)
sudo systemctl daemon-reload

# Force restart
sudo systemctl restart --force nginx
```

### Debug Mode
```bash
# Run service in foreground for debugging
ExecStart=/bin/bash -c '/path/to/script.sh; echo "Press Ctrl+C to stop"'
Type=simple

# Check environment
sudo systemd-run --scope -p StandardOutput=journal /env
```

---

## 🏆 Practice Exercises

### Exercise 1: Create a Simple Service
```bash
# Create sample script
cat > ~/myservice.sh << 'EOF'
#!/bin/bash
while true; do
    echo "$(date): Service running" >> /var/log/myservice.log
    sleep 60
done
EOF
chmod +x ~/myservice.sh

# Create service file
sudo tee /etc/systemd/system/myservice.service << 'EOF'
[Unit]
Description=My Test Service
After=network.target

[Service]
Type=simple
ExecStart=/home/ubuntu/myservice.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start and enable
sudo systemctl daemon-reload
sudo systemctl start myservice
sudo systemctl enable myservice

# Check status
sudo systemctl status myservice
```

### Exercise 2: Create a Timer
```bash
# Create task script
cat > ~/hourly_task.sh << 'EOF'
#!/bin/bash
echo "$(date): Hourly task ran" >> /tmp/hourly.log
EOF
chmod +x ~/hourly_task.sh

# Create service
sudo tee /etc/systemd/system/hourly_task.service << 'EOF'
[Unit]
Description=Hourly Task
[Service]
Type=oneshot
ExecStart=/home/ubuntu/hourly_task.sh
EOF

# Create timer
sudo tee /etc/systemd/system/hourly_task.timer << 'EOF'
[Unit]
Description=Hourly Timer
[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now hourly_task.timer
```

---

## 📋 Systemd Cheat Sheet

| Command | Action |
|---------|--------|
| `systemctl start` | Start service |
| `systemctl stop` | Stop service |
| `systemctl restart` | Restart service |
| `systemctl status` | Check status |
| `systemctl enable` | Enable at boot |
| `systemctl disable` | Disable at boot |
| `journalctl -u` | View service logs |
| `systemctl daemon-reload` | Reload configs |

---

## 🎓 Final Project: Systemd Service Manager

Now that you've mastered Systemd basics, let's see how a professional system administrator might automate service management. We'll examine the "Systemd Manager" — a tool that simplifies creating, monitoring, and managing your own custom background services.

### What the Systemd Service Manager Does:
1. **Lists All Services** with a focus on running vs. failed units.
2. **Simplifies Lifecycle Management** (start, stop, enable, disable) with one-word commands.
3. **Automates Service Creation** by generating unit files from a template.
4. **Streams Logs** directly to your terminal without complex `journalctl` flags.
5. **Monitors Active Timers** to keep track of your scheduled background tasks.
6. **Handles Daemon Reloading** automatically whenever a new service is created.

### Key Snippet: Automated Service Creation
The manager can turn any script or command into a background service by generating a standard `.service` file on the fly.

```bash
cmd_create() {
    local name=$1
    local cmd=$2
    local unit_file="/etc/systemd/system/${name}.service"
    
    # Generate the service definition
    sudo tee "$unit_file" > /dev/null << EOF
[Unit]
Description=$name Background Service
After=network.target

[Service]
Type=simple
ExecStart=$cmd
Restart=always       # Restart automatically if it crashes!
RestartSec=10        # Wait 10 seconds before restarting

[Install]
WantedBy=multi-user.target
EOF
    
    # Tell systemd to look for new files
    sudo systemctl daemon-reload
    log "Service '$name' created successfully!"
}
```

### Key Snippet: Simplified Log Viewing
Instead of typing `journalctl -u myapp -n 50 --no-pager`, the manager provides a much simpler `logs` command.

```bash
cmd_logs() {
    local name=$1
    # -u: Unit name
    # -n 50: Show only the last 50 lines
    # --no-pager: Don't open in 'less' (just print to screen)
    journalctl -u "$name" -n 50 --no-pager
}
```

**Pro Tip:** Wrapping these complex commands into a manager script makes you faster and less prone to errors when managing dozens of services!

---

## ✅ Stack 27 Complete!

Congratulations! You've successfully mastered the "brain" of your Linux system! You can now:
- ✅ **Manage system services** like a pro using `systemctl`
- ✅ **Turn any script into a service** that runs automatically in the background
- ✅ **Troubleshoot service failures** using `journalctl` and status checks
- ✅ **Master Systemd Timers** as a modern, robust alternative to Cron
- ✅ **Control service lifecycles** (Start, Stop, Enable, Disable)
- ✅ **Configure auto-restart policies** to ensure your apps never stay down

### What's Next?
In the next stack, we'll dive into **Package Management**. You'll learn how to automate the installation and updating of software across different Linux distributions!

**Next: Stack 28 - Package Management →**

---

*End of Stack 27*