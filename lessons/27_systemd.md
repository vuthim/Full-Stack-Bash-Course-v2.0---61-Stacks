# 🔧 STACK 27: SYSTEMD DEEP DIVE
## Modern Service Management in Linux

**What is Systemd?** Think of systemd as the "operating system manager" - it's the first thing that starts when your computer boots (PID 1), and it manages everything else: services, devices, mounts, timers, and more.

**Why Care?** Systemd is how you start/stop/restart services, check logs, and automate tasks on modern Linux. It's essential knowledge for any Linux user!

---

## 🔰 What is Systemd?

Systemd is the init system (PID 1) for most modern Linux distributions. It manages system services, devices, mount points, and more.

### Why Systemd? (The Benefits)
- ✅ **Parallel startup**: Faster boot times (services start simultaneously)
- ✅ **Dependencies**: Smart service ordering ("start networking before web server")
- ✅ **Monitoring**: Built-in logging with `journalctl`
- ✅ **Control**: Unified interface for all services (`systemctl`)
- ✅ **Socket activation**: On-demand service startup (save resources)

### Systemd Analogy
```
Your computer boots up:
1. Systemd wakes up first (PID 1)
2. Reads the "to-do list" (unit files)
3. Starts services in the right order
4. Keeps watching them (restarts if they crash)
5. Logs everything (journalctl)
```

---

## 📋 Systemd Components

| Component | Purpose |
|-----------|---------|
| systemd | Init system (PID 1) |
| systemd-analyze | Performance analysis |
| systemd-logind | Login management |
| systemd-networkd | Network configuration |
| systemd-resolved | DNS resolution |
| journald | Logging daemon |

---

## 🏢 Managing Services

### Basic Service Commands
```bash
# Start a service
sudo systemctl start nginx

# Stop a service
sudo systemctl stop nginx

# Restart a service
sudo systemctl restart nginx

# Reload (gentle restart)
sudo systemctl reload nginx

# Check status
sudo systemctl status nginx

# Enable at boot
sudo systemctl enable nginx

# Disable at boot
sudo systemctl disable nginx

# Check if enabled
systemctl is-enabled nginx

# Check if active
systemctl is-active nginx
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

## ✅ Stack 27 Complete!

You learned:
- ✅ What is systemd and its components
- ✅ Managing services (start, stop, enable)
- ✅ Creating service units
- ✅ Creating timers for scheduled tasks
- ✅ Monitoring and logging
- ✅ Advanced features (limits, sandboxing)
- ✅ Troubleshooting

### Next: Stack 28 - Package Management →

---

## 📝 Challenge: Build a Production Service

Create a systemd service for one of your scripts that:
1. Auto-starts on boot
2. Runs as a specific user
3. Has proper logging configured
4. Restarts automatically on failure

---

*End of Stack 27*