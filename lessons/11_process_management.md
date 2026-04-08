# ⚙️ STACK 11: PROCESS MANAGEMENT
## Controlling Running Programs (Like Being a Computer Traffic Cop)

Think of your computer as a busy city with thousands of cars (programs) running all at once. Process management is like being a traffic cop - you get to see what's running, direct traffic, speed things up or slow them down, and even remove problematic vehicles when needed.

---

## 🔍 Understanding Processes

### What is a Process?
- A running instance of a program
- Has a unique PID (Process ID)
- Has a parent (PPID)
- Has states: Running, Sleeping, Stopped, Zombie

### Process States
```
R - Running
S - Sleeping (wait/event)
D - Sleeping (uninterruptible)
T - Stopped (suspended)
Z - Zombie (dead but not cleaned)
```

---

## 👁️ Viewing Processes

### ps - Process Status
```bash
# Basic
ps

# Full format
ps -ef
ps aux

# User's processes
ps -u username

# Specific process
ps -ef | grep nginx

# Tree view
ps -ef --forest

# Sorted by memory
ps aux --sort=-%mem

# Sorted by CPU
ps aux --sort=-%cpu
```

### ps Output Explanation
```
USER       PID  %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1   0.0  0.0  12345  6789 ?        Ss   Jan15   0:05 /sbin/init
```

| Column | Meaning |
|--------|---------|
| USER | Owner |
| PID | Process ID |
| %CPU | CPU usage |
| %MEM | Memory usage |
| VSZ | Virtual memory |
| RSS | Real memory |
| TTY | Terminal |
| STAT | Process state |
| START | Start time |
| TIME | CPU time |
| COMMAND | Command |

---

## 🔎 Other Process Tools

### top - Interactive Monitor
```bash
top                 # Interactive view
top -u user         # User's processes only
top -p 1234        # Monitor specific PID
top -n 2           # Run 2 iterations
htop               # Enhanced version (if installed)
```

### top Commands (Interactive)
| Key | Action |
|-----|--------|
| `q` | Quit |
| `M` | Sort by memory |
| `P` | Sort by CPU |
| `k` | Kill process |
| `r` | Renice process |
| `1` | Show all CPUs |
| `f` | Customize fields |

### Additional Tools
```bash
# Quick process view
pstree             # Process tree

# Real-time process monitoring
watch -n 1 'ps aux | grep chrome'

# Who is using what
lsof               # List open files
lsof -i            # Network connections
lsof -p 1234      # Files for PID
```

---

## 📍 Working with Jobs

### jobctl - Background & Foreground
```bash
# Run command in background
command &

# List background jobs
jobs

# Bring to foreground
fg %1              # Job 1

# Send to background (while running)
# Press Ctrl+Z (suspend)
bg                 # Resume in background

# Kill background job
kill %1
```

---

## 🦆 Running in Background

### Background Execution
```bash
# Start in background
./script.sh &

# Run and immediately disown
nohup ./script.sh &

# Redirect output from background
./script.sh > output.log 2>&1 &

# Run even if terminal closes
nohup ./script.sh &>/dev/null &
```

### screen - Terminal Multiplexer
```bash
# Install
sudo apt install screen   # Ubuntu/Debian
sudo yum install screen   # RHEL/CentOS

# Commands
screen -S name            # Create named session
screen -ls               # List sessions
screen -r name           # Attach to session
screen -r pid            # Attach by PID
Ctrl+a d                 # Detach from session
```

### tmux - Alternative to screen
```bash
# Install
sudo apt install tmux

# Commands
tmux new -s name         # Create session
tmux ls                  # List sessions
tmux attach -t name     # Attach
Ctrl+b d                 # Detach
```

---

## 🔪 Process Control

### kill - Send Signals
```bash
# Kill by PID
kill 1234

# Force kill (-9 is SIGKILL)
kill -9 1234

# Kill by name
pkill nginx

# Kill all of a user's processes
pkill -u username

# Graceful shutdown (-15 is SIGTERM)
kill -15 1234
```

### Common Signals
| Signal | Number | Description |
|--------|--------|-------------|
| SIGHUP | 1 | Hangup |
| SIGINT | 2 | Ctrl+C |
| SIGQUIT | 3 | Ctrl+\ |
| SIGKILL | 9 | Force kill |
| SIGTERM | 15 | Graceful shutdown |
| SIGSTOP | 19 | Stop process |

### killall
```bash
# Kill all processes by name
killall nginx

# Kill by exact name
killall -e exact_name

# Force kill
killall -9 nginx
```

---

## ⭐ Process Priority

### nice & renice
```bash
# Start with priority (default 10)
nice -n 10 ./script.sh

# Nice values: -20 (highest) to 19 (lowest)
nice -n -10 ./high_priority.sh    # Higher priority
nice -n 10 ./low_priority.sh     # Lower priority

# Change priority of running process
renice -n 5 -p 1234

# Change all processes by user
renice -n 10 -u username
```

---

## 📋 Common Examples

### Example 1: Find & Kill Process
```bash
# Find nginx process
ps aux | grep nginx

# Kill nginx
pkill nginx

# Or find PID and kill
kill $(pgrep nginx)
```

### Example 2: Monitor & Alert
```bash
#!/bin/bash

process="nginx"
threshold=80

while true; do
    mem=$(ps aux | grep "$process" | grep -v grep | awk '{sum+=$4} END {print sum}')
    
    if (( $(echo "$mem > $threshold" | bc -l) )); then
        echo "ALERT: Memory at ${mem}%"
    fi
    
    sleep 60
done
```

### Example 3: Daemon Process
```bash
#!/bin/bash

# Check if already running
if pgrep -f "mydaemon.sh" > /dev/null; then
    echo "Already running"
    exit 1
fi

# Run in background with logging
exec > /var/log/mydaemon.log 2>&1

while true; do
    # Do work
    sleep 30
done
```

### Example 4: Run Until Complete
```bash
#!/bin/bash

# Run heavy task and send email on completion
{
    echo "Task started at $(date)"
    
    # Your heavy task
    ./heavy_task.sh
    
    echo "Task ended at $(date)"
} | mail -s "Task Complete" user@email.com
```

### Example 5: Parallel Execution
```bash
#!/bin/bash

# Run tasks in parallel
for i in {1..5}; do
    ./process_item.sh $i &
done

# Wait for all to complete
wait

echo "All tasks completed!"
```

---

## 🔄 System Process Info

### /proc Filesystem
```bash
# View process details
ls /proc/1234/

# Process cmdline
cat /proc/1234/cmdline

# Process environment
cat /proc/1234/environ

# Process status
cat /proc/1234/status

# Current directory
ls -la /proc/1234/cwd

# Open files
ls -la /proc/1234/fd

# Maps (memory)
cat /proc/1234/maps
```

### System Resource Usage
```bash
# Memory info
free -h              # RAM
cat /proc/meminfo   # Detailed

# CPU info
cat /proc/cpuinfo   # CPU details
lscpu               # Summary

# Disk I/O
iostat -x 2         # Every 2 seconds
```

---

## 📋 Process Management Cheat Sheet

| Command | Description |
|---------|-------------|
| `ps` | List processes |
| `top` | Interactive monitor |
| `pstree` | Process tree |
| `jobs` | Background jobs |
| `fg` | Bring to foreground |
| `bg` | Send to background |
| `kill` | Send signal to process |
| `pkill` | Kill by name |
| `killall` | Kill all by name |
| `nice` | Start with priority |
| `renice` | Change priority |
| `nohup` | Run immune to hangup |
| `screen` | Terminal session |

---

## 🏆 Practice Exercises

### Exercise 1: Monitor System
```bash
# See what's running
ps aux --sort=-%cpu | head -10

# What uses most memory?
ps aux --sort=-%mem | head -10
```

### Exercise 2: Background Task
```bash
#!/bin/bash

# Create background task
nohup ./long_task.sh > task.log 2>&1 &

# Note the PID
echo $!

# Check if it's running
ps -p $!
```

### Exercise 3: Graceful Shutdown
```bash
#!/bin/bash

# Start process in background
./myapp &

# On script completion, kill gracefully
cleanup() {
    echo "Shutting down..."
    kill -15 $(jobs -p)
    exit 0
}

trap cleanup SIGTERM SIGINT
wait
```

---

## ✅ Stack 11 Complete!

You learned:
- ✅ Understanding processes
- ✅ ps, top, htop commands
- ✅ Job control (fg, bg, jobs)
- ✅ Running commands in background
- ✅ screen and tmux sessions
- ✅ kill, pkill, killall signals
- ✅ Process priority (nice, renice)
- ✅ Real-world process management

- **Previous:** [Stack 10 → Regular Expressions](10_regular_expressions.md)
- **Next:** [Stack 12 - Advanced Scripting](12_advanced_scripting.md) 