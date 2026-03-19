# 📊 STACK 18: SYSTEM MONITORING
## Real-Time System Monitoring Scripts

---

## 🔰 System Monitoring Basics

```bash
# CPU info
lscpu
cat /proc/cpuinfo

# Memory info
free -h
cat /proc/meminfo

# Disk usage
df -h
du -sh *

# Uptime
uptime
uptime -p
```

---

## 📈 Resource Monitoring

### CPU Monitor
```bash
#!/bin/bash
# cpu_monitor.sh

cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo "CPU Usage: ${cpu_usage}%"

# Per-core usage
mpstat -P ALL 1 1 | tail -n +4
```

### Memory Monitor
```bash
#!/bin/bash
# memory_monitor.sh

total=$(free -m | awk '/^Mem:/ {print $2}')
used=$(free -m | awk '/^Mem:/ {print $3}')
free=$(free -m | awk '/^Mem:/ {print $4}')

percent=$((used * 100 / total))

echo "Memory: ${used}MB / ${total}MB (${percent}%)"

if [ $percent -gt 90 ]; then
    echo "⚠️ WARNING: High memory usage!"
fi
```

### Disk Monitor
```bash
#!/bin/bash
# disk_monitor.sh

df -h | grep -v tmpfs | while read line; do
    usage=$(echo $line | awk '{print $5}' | tr -d '%')
    mount=$(echo $line | awk '{print $6}')
    
    if [ $usage -gt 85 ]; then
        echo "⚠️ $mount is ${usage}% full"
    fi
done
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

## ✅ Stack 18 Complete!