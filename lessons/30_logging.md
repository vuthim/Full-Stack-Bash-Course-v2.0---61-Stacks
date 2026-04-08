# 📝 STACK 30: LOGGING BEST PRACTICES
## Effective Logging for Scripts and Applications

**What is Logging?** Logging is like a black box recorder for your scripts and systems. When things go wrong (and they will), logs tell you exactly what happened, when, and why.

**Why This Matters:** Without logs, debugging is like guessing in the dark. With good logs, you can trace any issue back to its root cause in minutes.

---

## 🔰 Why Logging Matters

- ✅ **Debugging**: Track down issues in production (your #1 troubleshooting tool)
- ✅ **Auditing**: Who did what and when (compliance and security)
- ✅ **Monitoring**: Real-time system awareness (catch issues early)
- ✅ **Compliance**: Regulatory requirements (legal necessity in many industries)
- ✅ **Performance**: Identify bottlenecks (find slow parts of your code)

### The Golden Rule of Logging
```
"Log enough to debug, but not so much that you drown in noise."
```

---

## 📊 Log Levels

### Standard Levels
| Level | Number | Use Case |
|-------|--------|----------|
| DEBUG | 0 | Detailed debug info |
| INFO | 1 | General events |
| NOTICE | 2 | Normal but significant |
| WARNING | 3 | Warning messages |
| ERROR | 4 | Error conditions |
| CRITICAL | 5 | Critical conditions |

### Implementation
```bash
#!/bin/bash
# logging.sh

LOG_LEVELS=("DEBUG" "INFO" "NOTICE" "WARNING" "ERROR" "CRITICAL")
LOG_LEVEL=1  # Set to INFO

log() {
    local level=$1
    shift
    local message="$*"
    
    local level_num=0
    case "$level" in
        DEBUG) level_num=0 ;;
        INFO) level_num=1 ;;
        NOTICE) level_num=2 ;;
        WARNING) level_num=3 ;;
        ERROR) level_num=4 ;;
        CRITICAL) level_num=5 ;;
    esac
    
    if [ $level_num -ge $LOG_LEVEL ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message"
    fi
}
```

---

## 📁 Log Files

### Common Locations
```bash
/var/log/syslog       # System messages
/var/log/auth.log     # Authentication
/var/log/kern.log     # Kernel messages
/var/log/dmesg        # Driver messages
/var/log/apache2/     # Apache logs
/var/log/nginx/       # Nginx logs
~/.bash_history       # Command history
```

### Best Practices
```bash
# Log rotation (logrotate)
/etc/logrotate.d/myscript

# Size limits
# /var/log/myscript.log {
#     daily
#     rotate 7
#     size 10M
#     compress
#     delaycompress
# }

# Permissions
chmod 640 /var/log/myscript.log
chown root:adm /var/log/myscript.log
```

---

## 📋 Structured Logging

### JSON Format
```bash
log_json() {
    local level="$1"
    local message="$2"
    
    echo "{\"timestamp\":\"$(date -Iseconds)\",\"level\":\"$level\",\"message\":\"$message\"}"
}

log_json "INFO" "Server started" | tee -a app.log
# Output: {"timestamp":"2024-01-15T10:30:00+00:00","level":"INFO","message":"Server started"}
```

### Syslog Format
```bash
# Use logger command
logger -t myscript -p user.info "Application started"

# From script
logger -t myapp -s -p user.warning "Disk space low"
```

---

## 🛠️ Logging in Bash Scripts

### Basic Logging Function
```bash
#!/bin/bash
# script_with_logging.sh

LOG_FILE="/var/log/myapp.log"

log() {
    local level=$1
    shift
    local message="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}

log "INFO" "Script started"
log "WARNING" "Configuration file not found, using defaults"
log "ERROR" "Failed to connect to database"
log "INFO" "Script completed"
```

### Advanced Logging
```bash
#!/bin/bash
# advanced_logging.sh

LOG_FILE="${LOG_FILE:-/var/log/app.log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local pid=$$
    
    # Color for terminal
    local color=""
    case "$level" in
        DEBUG) color='\033[0;36m' ;;
        INFO) color='\033[0;32m' ;;
        WARNING) color='\033[0;33m' ;;
        ERROR) color='\033[0;31m' ;;
    esac
    
    # Log to file
    echo "[$timestamp] [$level] [$pid] $message" >> "$LOG_FILE"
    
    # Print to terminal with colors (if interactive)
    if [ -t 1 ]; then
        echo -e "${color}[$timestamp] [$level] $message\033[0m"
    fi
}

# Function to catch errors
error_handler() {
    local line=$1
    local status=$2
    log "ERROR" "Error on line $line with status $status"
}

trap 'error_handler $LINENO $?' ERR
```

---

## 🔄 Log Rotation

### logrotate Configuration
```bash
# /etc/logrotate.d/myapp
/var/log/myapp.log {
    daily              # Rotate daily
    rotate 14          # Keep 14 files
    missingok          # Don't error if missing
    notifempty         # Don't rotate if empty
    compress           # Compress old logs
    delaycompress      # Delay compression
    dateext            # Date-based rotation
    dateformat -%Y%m%d # Date format
    create 0640 root adm  # Permissions
    sharedscripts     # Run post-rotate
    postrotate
        systemctl reload myapp > /dev/null 2>&1 || true
    endscript
}
```

### Manual Log Rotation
```bash
#!/bin/bash
# rotate_logs.sh

LOG_DIR="/var/log/myapp"
MAX_SIZE=10485760  # 10MB

for logfile in "$LOG_DIR"/*.log; do
    if [ -f "$logfile" ]; then
        size=$(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile")
        if [ "$size" -gt "$MAX_SIZE" ]; then
            mv "$logfile" "${logfile}.$(date +%Y%m%d_%H%M%S)"
            gzip "${logfile}.$(date +%Y%m%d_%H%M%S)"
            : > "$logfile"
        fi
    fi
done
```

---

## 📊 Centralized Logging

### Using syslog
```bash
# Send to remote syslog server
logger -n syslog.example.com -P 514 -t myapp "Message here"

# In application
echo "*.* @syslog.example.com" >> /etc/rsyslog.conf
```

### Using journalctl
```bash
# View application logs
journalctl -u myservice

# Follow in real-time
journalctl -u myservice -f

# Since time
journalctl --since "1 hour ago"

# Filter by priority
journalctl -p err
```

---

## 🔍 Log Analysis

### Basic Analysis
```bash
# Count error messages
grep -c ERROR /var/log/app.log

# Extract errors
grep ERROR /var/log/app.log

# Time-based analysis
grep "10:30" /var/log/app.log

# Last hour
sed -n '/'"$(date -d '1 hour ago' '+%Y-%m-%d %H')"'/,$p' /var/log/app.log
```

### Log Statistics
```bash
# Most common errors
awk '/ERROR/ {print $NF}' /var/log/app.log | sort | uniq -c | sort -rn

# Requests per IP
awk '{print $1}' access.log | sort | uniq -c | sort -rn

# Bandwidth usage
awk '{sum+=$10} END {print sum/1024/1024 " MB"}' access.log
```

---

## 🏆 Practice Exercises

### Exercise 1: Create Logging System
```bash
# Create logging functions
cat > ~/lib/logging.sh << 'EOF'
#!/bin/bash
# Logging library

log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a /var/log/app.log
}

log_debug() { log "DEBUG" "$@"; }
log_info()  { log "INFO" "$@"; }
log_warn()  { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
EOF
```

### Exercise 2: Analyze Logs
```bash
# Generate sample log
cat > /tmp/test.log << 'EOF'
[2024-01-15 10:00:01] [INFO] Server started
[2024-01-15 10:00:02] [INFO] User logged in
[2024-01-15 10:00:03] [WARNING] High memory usage
[2024-01-15 10:00:04] [ERROR] Connection failed
[2024-01-15 10:00:05] [INFO] Server stopped
EOF

# Analyze
echo "Total lines: $(wc -l < /tmp/test.log)"
echo "Errors: $(grep -c ERROR /tmp/test.log)"
```

---

## 📋 Logging Cheat Sheet

| Command | Purpose |
|---------|---------|
| `logger` | Send to syslog |
| `journalctl` | View systemd logs |
| `tail -f` | Follow log |
| `logrotate` | Rotate logs |
| `awk` | Parse logs |
| `grep` | Search logs |

---

## 🎓 Final Project: Structured Log Manager

Now that you've mastered logging best practices, let's see how a professional scripter might build a tool to handle logs for their applications. We'll examine the "Log Manager" — a utility that provides a standard way to write, view, and analyze logs with proper timestamps and severity levels.

### What the Structured Log Manager Does:
1. **Writes Standardized Logs** with consistent timestamps and levels (INFO, WARN, ERROR).
2. **Handles Log Rotation** by archiving and compressing old logs to save space.
3. **Provides Real-Time Tailing** to watch your application's behavior as it happens.
4. **Performs Log Analysis** by counting the number of errors and warnings.
5. **Filters Error Entries** to help you focus on critical issues quickly.
6. **Generates Statistical Summaries** of your application's health.

### Key Snippet: Writing with Timestamps
The core of any good logger is a consistent timestamp. Our manager uses a helper function to ensure every log line looks the same.

```bash
log_with_timestamp() {
    local level=$1
    shift # Remove the level from the arguments
    local message="$*"
    
    # Format: [2023-10-27 10:30:05] [INFO] My message
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "/var/log/app.log"
}
```

### Key Snippet: Automated Log Rotation
To prevent your hard drive from filling up, the manager includes a "rotate" command that renames the current log and starts a fresh one.

```bash
cmd_rotate() {
    local archived="app.log.$(date +%Y%m%d)"
    
    # Move the current log to a dated filename
    mv "app.log" "$archived"
    touch "app.log" # Start a new empty log
    
    # Compress the old log to save 90% space!
    gzip "$archived"
    log "Log rotated and compressed: ${archived}.gz"
}
```

**Pro Tip:** High-quality logs are like a "black box" for your scripts. When something goes wrong in the middle of the night, your logs will tell you exactly what happened!

---

## ✅ Stack 30 Complete!

Congratulations! You've successfully given your scripts a voice! You can now:
- ✅ **Implement proper log levels** (DEBUG, INFO, WARN, ERROR)
- ✅ **Write structured logs** with consistent timestamps
- ✅ **Manage log files** and prevent them from consuming too much disk space
- ✅ **Perform basic log analysis** to identify system trends
- ✅ **Automate log rotation** using Bash and Gzip
- ✅ **Troubleshoot complex issues** by auditing application history

### What's Next?
In the next stack, we'll dive into **Kubernetes Basics**. You'll learn how to manage large-scale clusters of containers and orchestrate complex applications like a cloud professional!

**Next: Stack 31 - Kubernetes Basics →**

---

*End of Stack 30*
- **Previous:** [Stack 29 → CI/CD Pipelines](29_ci_cd_pipelines.md)
- **Next:** [Stack 31 - Kubernetes Basics](31_kubernetes.md)