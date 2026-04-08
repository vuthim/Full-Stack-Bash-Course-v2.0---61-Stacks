# ⚡ STACK 41: PERFORMANCE TUNING
## Optimizing Linux System Performance

**What is Performance Tuning?** Think of it like tuning a car engine. The car runs fine out of the box, but with adjustments (fuel mixture, timing, tire pressure), you can squeeze out more power and efficiency!

**Why This Matters:** A tuned system runs faster, uses fewer resources, and handles more users. Small tweaks can make a big difference under load.

---

## 🔰 Performance Optimization Areas

Performance tuning touches every part of your system:

| Area | What It Affects | Quick Win |
|------|----------------|-----------|
| **CPU** | Processing speed, scheduling | Nice values, CPU affinity |
| **Memory** | How RAM is used and managed | Swappiness, caching |
| **Disk I/O** | Read/write speed, responsiveness | I/O scheduler, readahead |
| **Network** | Throughput, latency, connections | Buffer sizes, TCP settings |
| **Kernel** | Low-level system behavior | sysctl optimizations |

### The Performance Tuning Mindset
```
1. MEASURE first (don't guess!)
2. IDENTIFY the bottleneck (CPU? Memory? Disk? Network?)
3. CHANGE ONE thing at a time
4. MEASURE again (did it help?)
5. REPEAT

Never tune blindly - always measure before and after!
```

**Pro Tip:** The biggest performance gains come from fixing the RIGHT bottleneck, not from tweaking random settings. Use `top`, `iostat`, `vmstat` to identify the real problem first!

---

## 💻 CPU Optimization

### Viewing CPU Info
```bash
# CPU details
lscpu
cat /proc/cpuinfo

# Current load
uptime
top
htop
```

### CPU Performance Tuning
```bash
# Set CPU governor (performance vs powersave)
# Install cpufrequtils
sudo apt install cpufrequtils

# Set all cores to performance
sudo cpufreq-set -r -g performance

# Check current settings
cpufreq-info
```

### Process Priority
```bash
# Nice value (-20 to 19)
# Lower = higher priority
nice -n 10 ./script.sh

# Change priority of running process
renice -n 5 -p 1234
```

---

## 🧠 Memory Optimization

### Viewing Memory
```bash
# Memory usage
free -h
cat /proc/meminfo

# Detailed stats
vmstat 1
```

### Tuning
```bash
# Swappiness (0-100, lower = less swap)
cat /proc/sys/vm/swappiness
echo 10 | sudo tee /proc/sys/vm/swappiness
# Or in /etc/sysctl.conf
vm.swappiness = 10

# Cache pressure
echo 50 | sudo tee /proc/sys/vm/vfs_cache_pressure
vm.vfs_cache_pressure = 50

# Drop caches
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

---

## 💾 Disk I/O Optimization

### Checking Disk Performance
```bash
# Disk usage
df -h

# I/O stats
iostat -xz 1

# Check disk speed
sudo hdparm -t /dev/sda
```

### Optimization
```bash
# Add to /etc/sysctl.conf
# I/O scheduler (deadline for SSD, cfq for HDD)
echo "deadline" | sudo tee /sys/block/sda/queue/scheduler

# Read-ahead
echo 4096 | sudo tee /sys/block/sda/queue/read_ahead_kb

# Noop scheduler for SSD
echo "noop" | sudo tee /sys/block/nvme0n1/queue/scheduler
```

### Filesystem Options
```bash
# noatime - Don't update access time
# nodiratime - Don't update dir access time
# relatime - Relative atime (better for mail, etc)

# Add to /etc/fstab
UUID=xxx / ext4 defaults,noatime,nodiratime 0 1
```

---

## 🌐 Network Tuning

### Network Performance
```bash
# View network stats
netstat -s
ss -s

# Tuning network buffers
echo 65536 | sudo tee /proc/sys/net/core/rmem_max
echo 65536 | sudo tee /proc/sys/net/core/wmem_max

# TCP buffer sizes
echo "4096 87380 6291456" | sudo tee /proc/sys/net/ipv4/tcp_rmem
echo "4096 87380 6291456" | sudo tee /proc/sys/net/ipv4/tcp_wmem
```

### Socket Tuning
```bash
# Increase file descriptors
echo 65536 | sudo tee /proc/sys/fs/file-max

# In /etc/sysctl.conf
fs.file-max = 65536
```

---

## 🔧 Kernel Tuning

### sysctl Best Practices
```bash
# /etc/sysctl.conf optimization
# Network
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 15

# Memory
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 5

# Apply
sudo sysctl -p
```

---

## 🏆 Practice Exercises

### Exercise 1: Check System Performance
```bash
# CPU info
lscpu | grep -E "^CPU\(s\)|^Model name|^CPU MHz"

# Memory
free -h

# Disk
df -h

# Load
uptime
```

### Exercise 2: Optimize for Performance
```bash
# Disable transparent hugepages (for some DBs)
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag

# Add to /etc/rc.local for persistence
```

### Exercise 3: System Limits
```bash
# Check current limits
ulimit -a

# Add to /etc/security/limits.conf
# * soft nofile 65535
# * hard nofile 65535
# root soft nofile 65535
# root hard nofile 65535
```

---

## 📋 Performance Tools

| Tool | Purpose |
|------|---------|
| `top` | Process monitor |
| `htop` | Enhanced top |
| `iostat` | I/O stats |
| `vmstat` | Memory stats |
| `sar` | Performance data |
| `perf` | Profiling |

---

## 🎓 Final Project: Linux Performance Optimizer

Now that you've mastered the concepts of performance tuning, let's see how a professional System Engineer might build a tool to optimize their servers. We'll examine the "Performance Tuner" — a script that analyzes system bottlenecks and applies kernel-level optimizations automatically.

### What the Linux Performance Optimizer Does:
1. **Analyzes CPU Load** and identifies the top processes consuming cycles.
2. **Audits Memory Usage** to find leaks and "memory-hungry" applications.
3. **Monitors Disk I/O** to identify slow drives or inefficient mount options.
4. **Sets CPU Governors** (e.g., 'performance' vs 'powersave') across all cores.
5. **Tunes Network Buffers** using `sysctl` to handle high-traffic loads.
6. **Configures Disk Schedulers** to optimize for SSDs vs HDDs.

### Key Snippet: Tuning the CPU Governor
To get the maximum speed out of your processor, the tuner can switch all CPU cores into "Performance" mode with a single loop.

```bash
cmd_cpu_governor() {
    local mode=$1 # e.g., "performance"
    
    # Loop through every CPU core on the system
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        # Write the new mode into the kernel's control file
        echo "$mode" | sudo tee "$cpu" > /dev/null
    done
    
    log "All CPU cores switched to $mode mode successfully!"
}
```

### Key Snippet: Network Buffer Optimization
For servers handling thousands of connections, the default Linux network buffers are often too small. The tuner uses `sysctl` to expand them.

```bash
cmd_network_buffer() {
    log "Expanding network receive/transmit buffers..."
    
    # net.core.rmem_max: Maximum receive window size
    sudo sysctl -w net.core.rmem_max=16777216
    
    # net.ipv4.tcp_rmem: Min, default, and max TCP receive buffers
    sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
    
    log "Network stack optimized for high-throughput traffic."
}
```

**Pro Tip:** Performance tuning is a balance. Always measure the system *before* and *after* applying optimizations to ensure they actually helped!

---

## ✅ Stack 41 Complete!

Congratulations! You've successfully learned how to make Linux run at "warp speed"! You can now:
- ✅ **Identify system bottlenecks** using professional analysis tools
- ✅ **Optimize CPU performance** for high-load applications
- ✅ **Tune memory and swap** to prevent system sluggishness
- ✅ **Maximize disk throughput** with proper schedulers and mount options
- ✅ **Hard-tune the network stack** for massive traffic loads
- ✅ **Manage kernel parameters** safely using `sysctl` and `/sys`

### What's Next?
In the next stack, we'll dive into **Raspberry Pi Projects**. You'll learn how to take your Bash skills to the world of hardware and IoT (Internet of Things)!

**Next: Stack 42 - Raspberry Pi Projects →**

---

*End of Stack 41*
- **Previous:** [Stack 40 → GitLab CI/CD](40_gitlab_ci.md)
-- **Next:** [Stack 42 - Raspberry Pi Projects](42_raspberry_pi.md)