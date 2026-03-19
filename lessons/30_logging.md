# 📝 STACK 30: LOGGING BEST PRACTICES
## Effective Logging for Scripts and Applications

---

## 🔰 Why Logging Matters

- **Debugging**: Track down issues in production
- **Auditing**: Who did what and when
- **Monitoring**: Real-time system awareness
- **Compliance**: Regulatory requirements
- **Performance**: Identify bottlenecks

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

## ✅ Stack 30 Complete!

You learned:
- ✅ Log levels and when to use
- ✅ Log file locations and management
- ✅ Structured logging (JSON, syslog)
- ✅ Bash script logging
- ✅ Log rotation
- ✅ Centralized logging
- ✅ Log analysis

### Next: Stack 31 - Kubernetes Basics →

---

*End of Stack 30*