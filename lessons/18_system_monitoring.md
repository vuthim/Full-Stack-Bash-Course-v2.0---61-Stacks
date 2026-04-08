# 📊 STACK 18: SYSTEM MONITORING
## Real-Time System Monitoring Scripts

**What is System Monitoring?** Think of it like a health checkup for your computer. Just as doctors check your heart rate, blood pressure, and temperature, system monitoring checks CPU, memory, disk, and network health.

**Why This Matters:** Monitoring helps you catch problems BEFORE they become emergencies - like noticing a fever before it gets dangerous.

---

## 🔰 System Monitoring Basics

### Your First 5 Monitoring Commands

```bash
# 1. "How's my computer doing overall?"
uptime
# Shows: current time, how long it's been running, how many users, load average

# 2. "What's using my CPU?"
top
# Shows: All running processes, sorted by CPU usage (press q to quit)

# 3. "How much memory is free?"
free -h
# Shows: Total, used, and available RAM (the -h makes it human-readable)

# 4. "How much disk space is left?"
df -h
# Shows: Disk usage for all mounted drives

# 5. "What's my system info?"
uname -a
# Shows: Kernel version, architecture, hostname
```

**Pro Tip:** Add `-h` to commands (like `free -h`, `df -h`) for "human-readable" output. Without it, you'll see raw bytes instead of nice GB/MB values!

---

## 📈 Resource Monitoring

### Understanding the Metrics (What Do These Numbers Mean?)

**CPU Usage:** 
- 0-50% = Healthy ✅
- 50-80% = Getting busy, watch it ⚠️
- 80-100% = Danger zone! Something's hogging resources 🔴

**Memory (RAM):**
- Think of RAM like your desk space - more desk = more work you can do at once
- High memory usage isn't always bad (Linux uses free RAM for caching)
- Watch for "available" not just "free" in `free -h` output

**Disk Space:**
- Like your closet - when it's full, you can't add more stuff
- Keep at least 10-15% free for system health

### CPU Monitor Script
```bash
#!/bin/bash
# cpu_monitor.sh

# Get overall CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo "CPU Usage: ${cpu_usage}%"

# Alert if high
if (( $(echo "$cpu_usage > 80" | bc -l) )); then
    echo "⚠️ WARNING: CPU usage is high!"
fi

# Per-core usage (requires sysstat package)
mpstat -P ALL 1 1 | tail -n +4
```

**Pro Tip:** `top -bn1` runs top once (non-interactive) and exits. The `-b` is batch mode, `-n1` means run 1 iteration.

### Memory Monitor Script
```bash
#!/bin/bash
# memory_monitor.sh

total=$(free -m | awk '/^Mem:/ {print $2}')
used=$(free -m | awk '/^Mem:/ {print $3}')
free_mem=$(free -m | awk '/^Mem:/ {print $4}')
available=$(free -m | awk '/^Mem:/ {print $7}')

percent=$((used * 100 / total))

echo "Memory: ${used}MB / ${total}MB (${percent}% used)"
echo "Available: ${available}MB (includes cache)"

if [ $percent -gt 90 ]; then
    echo "⚠️ WARNING: High memory usage!"
    # Show top memory users
    echo "Top 5 memory consumers:"
    ps aux --sort=-%mem | head -6
fi
```

### Disk Monitor Script
```bash
#!/bin/bash
# disk_monitor.sh

# Check all filesystems, alert if over threshold
THRESHOLD=85

df -h | grep -v tmpfs | grep -v Filesystem | while read line; do
    usage=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mount=$(echo "$line" | awk '{print $6}')
    size=$(echo "$line" | awk '{print $2}')

    if [ "$usage" -gt "$THRESHOLD" ]; then
        echo "⚠️ $mount is ${usage}% full (total: $size)"
    else
        echo "✓ $mount is ${usage}% full"
    fi
done
```

---

## ⚠️ Common Monitoring Mistakes (Avoid These!)

### 1. Misunderstanding Load Average
```bash
uptime
# Output: 14:30:22 up 10 days, 3 users, load average: 0.50, 1.20, 2.10
#                               ↑ 1min  ↑ 5min  ↑ 15min

# ❌ Mistake: Thinking load average is percentage
# ✅ Reality: It's average number of running/waiting processes

# Rule of thumb (for single CPU):
# Load < 1.0 = Good
# Load > 1.0 = CPU is fully utilized (may need more cores)
# For multi-core: Divide by number of cores to get real load
```

**Pro Tip:** A load of 2.0 on a 4-core machine is only 50% utilization! Always check `nproc` for core count.

### 2. Panicking Over High Memory Usage
```bash
# ❌ Mistake: "90% memory used! System will crash!"
# ✅ Reality: Linux uses free RAM for disk caching (automatically freed when needed)

# Look at "available" not "free":
free -h
#              total   used   free   shared  buff/cache   available
# Mem:          15Gi  4.2Gi   1.8Gi   512Mi     9.5Gi       10Gi
# ↑ Available is what matters - this shows 10GB usable!
```

### 3. Not Monitoring Trends
```bash
# ❌ Mistake: Only checking when problems occur
# ✅ Fix: Log metrics regularly to spot trends

# Simple daily check-in:
*/5 * * * * /path/to/collect_metrics.sh  # Every 5 minutes
```

### 4. Alerting on Everything
```bash
# ❌ Mistake: Alert on every minor spike → alert fatigue
# ✅ Fix: Alert only on sustained issues

# Better: Alert if high for 5+ minutes, not just 1 spike
```

---

## 🎯 Real-Time Dashboard

```bash
#!/bin/bash
# dashboard.sh - Real-time monitoring dashboard

while true; do
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║     🖥️ System Monitoring Dashboard    ║"
    echo "╚══════════════════════════════════════╝"
    echo "Time: $(date)"
    echo ""
    
    echo "=== CPU ==="
    top -bn1 | head -5
    
    echo ""
    echo "=== Memory ==="
    free -h | grep -E "Mem|Swap"
    
    echo ""
    echo "=== Disk ==="
    df -h | grep -v tmpfs | head -5
    
    echo ""
    echo "=== Top Processes ==="
    ps aux --sort=-%cpu | head -6
    
    sleep 5
done
```

---

## 📊 Alerting System

```bash
#!/bin/bash
# alert_system.sh

THRESHOLD_CPU=80
THRESHOLD_MEM=85
THRESHOLD_DISK=90

# CPU Alert
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$cpu > $THRESHOLD_CPU" | bc -l) )); then
    echo "⚠️ High CPU: $cpu%" | mail -s "CPU Alert" admin@example.com
fi

# Memory Alert
mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
if [ "$mem" -gt "$THRESHOLD_MEM" ]; then
    echo "⚠️ High Memory: $mem%" | mail -s "Memory Alert" admin@example.com
fi
```

---

## 📈 Historical Monitoring

```bash
#!/bin/bash
# collect_metrics.sh - Store metrics for analysis

LOG_FILE="/var/log/metrics.log"

timestamp=$(date +%s)
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
disk=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

echo "$timestamp,$cpu,$mem,$disk" >> $LOG_FILE
```

```bash
# Analyze trends
awk -F',' '{print $2}' /var/log/metrics.log | sort -n | tail -1  # Max CPU
awk -F',' '{print $3}' /var/log/metrics.log | sort -n | tail -1  # Max Memory
```

---

## 🔔 Health Check Script

```bash
#!/bin/bash
# health_check.sh

ERRORS=0

check() {
    if [ $? -eq 0 ]; then
        echo "✓ $1 OK"
    else
        echo "✗ $1 FAILED"
        ((ERRORS++))
    fi
}

echo "Running health checks..."
echo ""

# System reachable
ping -c 1 google.com > /dev/null
check "Internet"

# Critical services
systemctl is-active --quiet nginx
check "Nginx"

systemctl is-active --quiet mysql
check "MySQL"

# Disk space
df / | tail -1 | awk '{if ($5+0 > 90) exit 1; else exit 0}'
check "Disk Space"

# Memory
free | grep Mem | awk '{if ($3/$2 * 100 > 95) exit 1; else exit 0}'
check "Memory"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All checks passed!"
else
    echo "⚠️ $ERRORS checks failed!"
    exit 1
fi
```

---

## 📊 Performance Profiling

```bash
#!/bin/bash
# profile_script.sh - Measure script performance

start_time=$(date +%s)

# Your commands here
sleep 2
echo "Processing..."

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "Script completed in ${duration} seconds"
```

---

## 🏆 Practice: Monitoring Dashboard

Create a comprehensive monitor that:
1. Shows CPU, Memory, Disk in real-time
2. Alerts when thresholds exceeded
3. Logs all metrics
4. Sends email notifications
5. Has a clean colored output

---

## 🎓 Final Project: System Monitoring Dashboard

Now that you've mastered monitoring commands, let's see how a professional system administrator might build a real-time dashboard. We'll examine the "System Monitor" — a tool that provides a centralized view of your computer's health, from CPU loads to failing services.

### What the System Monitoring Dashboard Does:
1. **Provides a Full System Overview** including uptime, load averages, and kernel info.
2. **Details Resource Usage** for CPU, Memory, and Disk in human-readable formats.
3. **Identifies Top Processes** by both CPU and Memory consumption.
4. **Monitors Network Health** showing active interfaces and connection stats.
5. **Tracks Service Status** listing all running and failed system services.
6. **Includes an Alert System** that warns you when CPU usage crosses a threshold.

### Key Snippet: Real-Time Monitoring Loop
The "watch" feature of the dashboard uses a simple `while` loop combined with the `clear` command to create a real-time updating interface.

```bash
cmd_watch() {
    local interval=${1:-2}
    echo "Monitoring (Ctrl+C to stop)..."
    
    while true; do
        clear # Wipe the screen
        echo "Updated: $(date)"
        
        # Call the overview function we defined earlier
        cmd_overview 
        
        sleep "$interval" # Wait before the next update
    done
}
```

### Key Snippet: Smart CPU Alerting
This snippet shows how to parse `top` output and trigger a visual alert if the CPU usage is too high.

```bash
cmd_alert() {
    local threshold=$1
    log "Monitoring CPU. Alert threshold: $threshold%"
    
    while true; do
        # Extract CPU usage percentage
        cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1)
        
        if [ "$cpu" -gt "$threshold" ]; then
            # Print in RED if threshold exceeded
            echo -e "\033[0;31mALERT: CPU at ${cpu}%\033[0m"
        fi
        sleep 5
    done
}
```

**Pro Tip:** A dashboard like this is the first thing a DevOps engineer looks at when a server is reported as "slow."

---

## ✅ Stack 18 Complete!

Congratulations! You've successfully built your own system command center! You can now:
- ✅ **Monitor system health** in real-time using Uptime and Top
- ✅ **Analyze resource usage** for CPU, RAM, and Disk Space
- ✅ **Identify performance bottlenecks** by finding top processes
- ✅ **Track network activity** and connection statistics
- ✅ **Audit system services** to find failing units
- ✅ **Build automated alerts** to catch problems before they crash the system

### What's Next?
In the next stack, we'll dive into **AWS CLI**. You'll learn how to take your Bash skills to the cloud and manage entire global infrastructures from your local terminal!

**Next: Stack 19 - AWS CLI →**

---

*End of Stack 18*