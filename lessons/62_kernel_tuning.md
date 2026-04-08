# ⚙️ STACK 62: KERNEL TUNING & sysctl
## Advanced System Optimization

**What is Kernel Tuning?** Think of the Linux kernel as a car engine. Out of the box, it's set to a "good for everyone" configuration. Kernel tuning is like a mechanic adjusting the fuel mixture, timing, and suspension for YOUR specific driving style - racing, towing, or city commuting.

**⚠️ WARNING:** Kernel tuning affects the core of your OS. Bad settings can crash your system or make it unstable. Always:
1. Change ONE setting at a time
2. Test thoroughly before production
3. Document every change
4. Have a rollback plan

---

## 🔰 Why Kernel Tuning?

Kernel tuning lets you optimize the heart of your system for YOUR specific workload:

| Area | What It Affects | Common Tuning Goal |
|------|----------------|-------------------|
| **Performance** | CPU scheduling, I/O priority | Faster response times, more throughput |
| **Network** | TCP settings, buffer sizes | Handle more connections, reduce latency |
| **Memory** | Swappiness, caching, OOM behavior | Better memory utilization, fewer OOM kills |
| **Security** | Kernel protections, ASLR | Harden against exploits |
| **File system** | Inode handling, dirty pages | Faster disk operations |

---

## 📋 sysctl Basics

### View Parameters
```bash
# List all parameters
sysctl -a

# View specific parameter
sysctl kernel.hostname
sysctl net.ipv4.tcp_congestion_control

# View with description
sysctl -a | grep description
```

### Set Parameters Temporarily
```bash
# Set single parameter
sysctl -w net.ipv4.ip_forward=1

# Set multiple
sysctl -w net.ipv4.conf.all.rp_filter=1 net.ipv4.conf.default.rp_filter=1
```

### Set Parameters Permanently
```bash
# Add to /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Or create custom file
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-custom.conf

# Apply without reboot
sysctl --system

# Apply specific file
sysctl -p /etc/sysctl.d/99-custom.conf
```

---

## 🌐 Network Tuning

### TCP Parameters
```bash
# Increase TCP buffer sizes
sysctl -w net.ipv4.tcp_rmem="4096 87380 6291456"
sysctl -w net.ipv4.tcp_wmem="4096 65536 6291456"

# Enable TCP window scaling
sysctl -w net.ipv4.tcp_window_scaling=1

# Enable timestamps
sysctl -w net.ipv4.tcp_timestamps=1

# Enable selective acknowledgments
sysctl -w net.ipv4.tcp_sack=1

# Connection tracking
sysctl -w net.netfilter.nf_conntrack_max=1048576
sysctl -w net.nf_conntrack_max=1048576

# TIME_WAIT reuse
sysctl -w net.ipv4.tcp_tw_reuse=1

# FIN_TIMEOUT
sysctl -w net.ipv4.tcp_fin_timeout=15
```

### Network Performance
```bash
# Increase socket backlog
sysctl -w net.core.somaxconn=65535
sysctl -w net.core.netdev_max_backlog=65535

# Increase file descriptors
sysctl -w fs.file-max=1048576
sysctl -w fs.nr_open=1048576

# Increase ARP cache
sysctl -w net.ipv4.neigh.default.gc_thresh1=4096
sysctl -w net.ipv4.neigh.default.gc_thresh2=6144
sysctl -w net.ipv4.neigh.default.gc_thresh3=8192
```

### IP Forwarding
```bash
# IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# IPv6 forwarding
sysctl -w net.ipv6.conf.all.forwarding=1
```

---

## 💾 Memory Tuning

### Kernel Memory
```bash
# Swappiness (0=never, 100=aggressive)
sysctl -w vm.swappiness=10

# Cache pressure
sysctl -w vm.vfs_cache_pressure=50

# Dirty page ratios
sysctl -w vm.dirty_ratio=15
sysctl -w vm.dirty_background_ratio=5

# OOM handling
sysctl -w vm.overcommit_memory=1
sysctl -w vm.overcommit_ratio=50

# Page size
sysctl -w vm.pagecache=1
```

### Shared Memory
```bash
# Increase shared memory
sysctl -w kernel.shmmax=68719476736
sysctl -w kernel.shmall=4294967296
```

---

## 🔒 Security Tuning

### Network Security
```bash
# Disable ICMP redirect acceptance
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.all.accept_redirects=0

# Disable source packet routing
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.all.accept_source_route=0

# Enable IP spoofing protection
sysctl -w net.ipv4.conf.all.rp_filter=1

# Disable ping
sysctl -w net.ipv4.icmp_echo_ignore_all=1

# Log suspicious packets
sysctl -w net.ipv4.conf.all.log_martians=1
```

### Kernel Hardening
```bash
# Disable core dumps
sysctl -w kernel.core_pattern=|/bin/false

# Restrict access to kernel pointers
sysctl -w kernel.kptr_restrict=2

# Disable kernel debug
sysctl -w kernel.dmesg_restrict=1

# Randomize PIDs
sysctl -w kernel.pid_max=4194304
```

---

## 📊 Process & Scheduler

### Process Limits
```bash
# Max processes per user
sysctl -w kernel.threads-max=4194304

# Max locks
sysctl -w fs.inotify.max_user_watches=524288
```

### Scheduler Tuning
```bash
# CPU frequency governor
# (set via cpufreq-set, not sysctl)
```

---

## 🔧 Complete Configuration

### High-Performance Web Server
```bash
# /etc/sysctl.d/99-web-server.conf

# Network
net.core.somaxconn=65535
net.core.netdev_max_backlog=65535
net.ipv4.tcp_max_syn_backlog=65535
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_rmem=4096 87380 6291456
net.ipv4.tcp_wmem=4096 65536 6291456
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1

# Files
fs.file-max=1048576
fs.nr_open=1048576

# Memory
vm.swappiness=10
vm.dirty_ratio=15
vm.dirty_background_ratio=5

# Security
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.accept_source_route=0
```

### High-Security Server
```bash
# /etc/sysctl.d/99-security.conf

# Network
net.ipv4.conf.all.accept_redirects=0
net.ipv6.conf.all.accept_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv6.conf.all.accept_source_route=0
net.ipv4.conf.all.rp_filter=1
net.ipv4.icmp_echo_ignore_all=1
net.ipv4.conf.all.log_martians=1

# Kernel
kernel.kptr_restrict=2
kernel.dmesg_restrict=1
kernel.core_pattern=|/bin/false
```

---

## 📝 Apply & Monitor

### Apply Changes
```bash
# Apply all config files
sysctl --system

# Apply specific file
sysctl -p /etc/sysctl.d/99-custom.conf
```

### Monitor Settings
```bash
# Check current values
sysctl net.core.somaxconn

# Watch changes in real-time
watch -n 1 'sysctl net.ipv4.tcp_mem'

# Show effective config
sysctl --system
```

---

## ✅ Stack 62 Complete!

You learned:
- ✅ sysctl basics and commands
- ✅ Network tuning (TCP, buffers, performance)
- ✅ Memory tuning (swappiness, cache, OOM)
- ✅ Security hardening
- ✅ Process and scheduler tuning
- ✅ Complete configurations for different use cases

---

*End of Stack 62*
