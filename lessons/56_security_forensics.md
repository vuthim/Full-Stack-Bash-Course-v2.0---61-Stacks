# 🔒 STACK 56: SECURITY AUDITING & FORENSICS
## Security Automation Scripts

**What is Security Auditing?** Think of it like a home security inspection. You check every door, window, and alarm to find weaknesses BEFORE a burglar does. Forensics is what happens AFTER a break-in - figuring out what happened, when, and who did it.

**⚠️ WARNING:** Security auditing finds vulnerabilities that attackers could exploit. Handle findings responsibly. Never scan systems you don't own or have explicit permission to test!

---

## 🔰 What You'll Learn

| Skill | What It Does | Real-World Application |
|-------|--------------|-----------------------|
| **System security auditing** | Automated security checks | Find weaknesses before attackers do |
| **Log analysis for threats** | Spot attack patterns in logs | Detect brute-force attempts, intrusions |
| **File integrity checking** | Verify files haven't been tampered with | Detect malware, unauthorized changes |
| **Network forensics** | Analyze network traffic for threats | Identify data exfiltration, C2 connections |
| **Incident response automation** | Auto-respond to security events | Block attacking IPs, isolate compromised hosts |

### The Security Auditing Mindset
```
Normal admin: "Is the system running?"
Security auditor: "Can someone break in? How? What would they find?"

Think like an attacker to defend like a professional.
```

---

## 🔍 System Security Audit

### Audit Script
```bash
#!/bin/bash
# security_audit.sh

REPORT="/tmp/security_audit_$(date +%Y%m%d).txt"

echo "Security Audit Report - $(date)" > "$REPORT"
echo "=================================" >> "$REPORT"

# Check for unused accounts
echo -e "\n[1] Inactive Accounts:" >> "$REPORT"
lastlog | grep "Never" >> "$REPORT"

# Check sudoers
echo -e "\n[2] Sudo Users:" >> "$REPORT"
getent group sudo >> "$REPORT"

# Check open ports
echo -e "\n[3] Open Ports:" >> "$REPORT"
ss -tuln >> "$REPORT"

# Check running services
echo -e "\n[4] Running Services:" >> "$REPORT"
systemctl list-units --type=service --state=running >> "$REPORT"

# Check recent failed logins
echo -e "\n[5] Failed Logins:" >> "$REPORT"
lastb -20 >> "$REPORT"

# Check cron jobs
echo -e "\n[6] System Cron Jobs:" >> "$REPORT"
ls -la /etc/cron.d/ >> "$REPORT"

# Check SUID files
echo -e "\n[7] SUID Files:" >> "$REPORT"
find / -perm /6000 -type f 2>/dev/null | head -20 >> "$REPORT"

# Check world-writable files
echo -e "\n[8] World-Writable Files:" >> "$REPORT"
find / -perm -0002 -type f 2>/dev/null | head -20 >> "$REPORT"

echo "Audit complete: $REPORT"
```

### User Audit
```bash
#!/bin/bash
# user_audit.sh

echo "=== User Account Audit ==="
echo ""

# All users
echo "All User Accounts:"
getent passwd | grep -v '/nologin\|/false' | cut -d: -f1,3,7

echo ""

# Recent login
echo "Users who logged in recently:"
last -30 | awk '!seen[$1]++ {print $1}'

echo ""

# Password status
echo "Password Expiration Status:"
for user in $(getent passwd | cut -d: -f1); do
    chage -l "$user" 2>/dev/null | head -1
done | grep -B1 "never"

# Check for duplicate UIDs
echo ""
echo "Duplicate UIDs:"
getent passwd | cut -d: -f3 | sort | uniq -d | while read uid; do
    echo "UID $uid:"
    getent passwd | awk -F: -v u=$uid '($3 == u) {print "  " $1}'
done
```

---

## 🕵️ File Integrity Monitoring

### Baseline Scanner
```bash
#!/bin/bash
# file_integrity.sh

BASELINE="/tmp/baseline.db"
REPORT="/tmp/integrity_report_$(date +%Y%m%d).txt"
CHECK_DIRS="/bin /sbin /usr/bin /usr/sbin /etc"

# Create baseline
create_baseline() {
    echo "Creating baseline..."
    > "$BASELINE"
    
    find $CHECK_DIRS -type f -exec sha256sum {} \; 2>/dev/null >> "$BASELINE"
    echo "Baseline created: $BASELINE"
}

# Check integrity
check_integrity() {
    echo "Checking integrity..."
    
    while IFS= read -r line; do
        file=$(echo "$line" | cut -d' ' -f3-)
        hash=$(echo "$line" | cut -d' ' -f1)
        
        if [ -f "$file" ]; then
            current_hash=$(sha256sum "$file" | cut -d' ' -f1)
            if [ "$hash" != "$current_hash" ]; then
                echo "MODIFIED: $file" | tee -a "$REPORT"
            fi
        else
            echo "DELETED: $file" | tee -a "$REPORT"
        fi
    done < "$BASELINE"
    
    # Check for new files
    find $CHECK_DIRS -type f -newer "$BASELINE" 2>/dev/null | while read f; do
        echo "NEW: $f" | tee -a "$REPORT"
    done
    
    echo "Report: $REPORT"
}

# Usage
case "${1:-check}" in
    baseline) create_baseline ;;
    check) check_integrity ;;
esac
```

### Tripwire-like Script
```bash
#!/bin/bash
# tripwire.sh

# Simplified tripwire implementation
DB_FILE="/var/lib/integrity.db"
ALERT_EMAIL="admin@example.com"

# Hash function
hash_file() {
    sha256sum "$1" | cut -d' ' -f1
}

# Initialize database
init() {
    echo "Initializing database..."
    mkdir -p "$(dirname "$DB_FILE")"
    
    find /etc -type f 2>/dev/null | while read f; do
        echo "$(hash_file "$f")|$f" >> "$DB_FILE"
    done
}

# Check for changes
check() {
    while IFS='|' read -r expected_hash filename; do
        if [ ! -f "$filename" ]; then
            echo "DELETED: $filename"
        elif [ "$(hash_file "$filename")" != "$expected_hash" ]; then
            echo "MODIFIED: $filename"
        fi
    done < "$DB_FILE"
}

# Update database
update() {
    while IFS='|' read -r old_hash filename; do
        if [ -f "$filename" ]; then
            echo "$(hash_file "$filename")|$filename"
        fi
    done < "$DB_FILE" > "$DB_FILE.new"
    mv "$DB_FILE.new" "$DB_FILE"
}

# Usage
case "${1:-check}" in
    init) init ;;
    check) check ;;
    update) update ;;
esac
```

---

## 📊 Log Analysis & Threat Detection

### Failed Login Detector
```bash
#!/bin/bash
# login_detector.sh

LOG_FILE="/var/log/auth.log"
THRESHOLD=5
TIME_WINDOW=10  # minutes

# Get failed logins in time window
failed_logins() {
    sudo awk -v start="$(date -d '10 minutes ago' '+%b %d %H:%M')" \
        '$1" "$2" "$3 >= start && /Failed password/ {print $1,$2,$3,$11,$13}' "$LOG_FILE"
}

# Count by IP
count_by_ip() {
    failed_logins | awk '{print $NF}' | sort | uniq -c | \
        sort -rn | while read count ip; do
            if [ "$count" -ge "$THRESHOLD" ]; then
                echo "ALERT: $count failed attempts from $ip"
                
                # Block IP (optional)
                # sudo iptables -A INPUT -s "$ip" -j DROP
            fi
        done
}

# Count by user
count_by_user() {
    failed_logins | awk '{print $NF}' | sort | uniq -c | \
        sort -rn | while read count user; do
            if [ "$count" -ge "$THRESHOLD" ]; then
                echo "ALERT: $count failed attempts for user: $user"
            fi
        done
}

echo "Failed Login Analysis"
echo "====================="
echo ""
echo "Top Offending IPs:"
count_by_ip
echo ""
echo "Targeted Users:"
count_by_user
```

### Anomaly Detection
```bash
#!/bin/bash
# anomaly_detection.sh

# Detect unusual commands
detect_anomalies() {
    local history_file="$1"
    
    # Look for dangerous commands in history
    grep -E "rm -rf|mkfs|wget.*bash|curl.*bash|eval|base64.*-d" "$history_file" 2>/dev/null
    
    # Check for unusual times
    last -50 | awk '$7 ~ /[0-2][0-9]:[0-9][0-9]/ && ($7 < "06:00" || $7 > "22:00") {print}'
    
    # Detect reverse shells
    grep -E "/dev/tcp|/dev/udp|bash -i" "$history_file" 2>/dev/null
}

# System anomaly check
system_anomalies() {
    # Unusual processes
    echo "Unusual processes:"
    ps aux --sort=-%mem | head -5
    
    # Unusual network connections
    echo ""
    echo "Network connections:"
    ss -tunap | grep ESTAB
    
    # Unusual file access
    echo ""
    echo "Recently modified files in /tmp:"
    find /tmp -type f -mtime -1 2>/dev/null | head -10
}

detect_anomalies "$HOME/.bash_history"
system_anomalies
```

---

## 🚨 Incident Response

### Automated Response
```bash
#!/bin/bash
# incident_response.sh

INCIDENT_DIR="/tmp/incident_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$INCIDENT_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$INCIDENT_DIR/log.txt"
}

# Collect evidence
collect_evidence() {
    log "Starting evidence collection..."
    
    # System info
    uname -a > "$INCIDENT_DIR/system_info.txt"
    date > "$INCIDENT_DIR/timestamp.txt"
    
    # Network state
    ss -tuln > "$INCIDENT_DIR/network_connections.txt"
    netstat -antp > "$INCIDENT_DIR/netstat.txt" 2>/dev/null
    
    # Running processes
    ps auxf > "$INCIDENT_DIR/processes.txt"
    
    # Recent commands
    last -50 > "$INCIDENT_DIR/recent_logins.txt"
    history > "$INCIDENT_DIR/command_history.txt" 2>/dev/null
    
    # Log files
    cp /var/log/auth.log "$INCIDENT_DIR/" 2>/dev/null
    cp /var/log/syslog "$INCIDENT_DIR/" 2>/dev/null
    
    # Memory dump (if possible)
    if command -v LiME &> /dev/null; then
        log "Memory dump tool available"
    fi
    
    log "Evidence collected in: $INCIDENT_DIR"
}

# Containment actions
containment() {
    log "Starting containment..."
    
    # Kill suspicious processes (add your rules)
    # pkill -9 suspicious_process
    
    # Block IPs (add your rules)
    # iptables -A INPUT -s attacker_ip -j DROP
    
    # Disable compromised accounts
    # passwd -l compromised_user
    
    log "Containment complete"
}

# Run incident response
log "Incident Response Started"
collect_evidence
containment
log "Incident Response Complete"

echo "Evidence directory: $INCIDENT_DIR"
```

---

## 🔐 Permission Analysis

### Find Permission Issues
```bash
#!/bin/bash
# permission_audit.sh

echo "=== Permission Audit ==="

# World-readable sensitive files
echo -e "\n[1] Sensitive files that are world-readable:"
find /etc -perm -004 2>/dev/null | grep -E "passwd|shadow|group|sudoers" | while read f; do
    echo "  $f"
done

# SUID files
echo -e "\n[2] SUID files (potential privilege escalation):"
find / -perm /6000 -type f 2>/dev/null | while read f; do
    owner=$(stat -c '%U' "$f")
    echo "  $f (owner: $owner)"
done

# Writable files in system dirs
echo -e "\n[3] World-writable files in system directories:"
find /bin /sbin /usr/bin /usr/sbin -perm -0002 2>/dev/null | while read f; do
    echo "  $f"
done

# Unowned files
echo -e "\n[4] Unowned files:"
find / -nouser -o -nogroup 2>/dev/null | head -20 | while read f; do
    echo "  $f"
done

# SSH keys with bad permissions
echo -e "\n[5] SSH keys with improper permissions:"
find ~ -name "id_rsa*" -perm /077 2>/dev/null | while read f; do
    echo "  $f"
done
```

---

## 🏆 Practice Exercises

### Exercise 1: Security Audit
Write a full system security audit script

### Exercise 2: File Integrity Monitor
Implement a file integrity checking system

### Exercise 3: Log Analyzer
Create a script to detect brute force attacks

---

## 🎓 Final Project: The Bash Forensics Investigator

Now that you've mastered security auditing, let's see how a professional Security Analyst might build a forensics tool. We'll examine the "Forensics Investigator" — a script that performs deep system audits, monitors file integrity, and creates event timelines to investigate suspicious activity.

### What the Bash Forensics Investigator Does:
1. **Performs Real-Time Anomaly Detection** by scanning for suspicious processes (like `netcat` or `nmap`).
2. **Audits Failed Logins** using the `lastb` command to identify brute-force attacks.
3. **Monitors File Integrity** by generating and comparing SHA-256 hashes of critical system binaries.
4. **Tracks File Modifications** to find any system files changed in the last 24 hours.
5. **Generates Event Timelines** by correlating logins, command history, and system logs.
6. **Audits Network Surfaces** by listing all listening ports and their associated processes.

### Key Snippet: File Integrity Monitoring (FIM)
The most critical part of forensics is knowing if a system file (like `/bin/ls`) has been replaced by a hacker. The investigator uses hashing to detect even a single character change.

```bash
cmd_compare_hashes() {
    echo "=== Comparing Hashes with Security Baseline ==="
    
    # Read the 'known good' hashes from a baseline file
    while read -r line; do
        local file=$(echo "$line" | awk '{print $2}')
        local expected_hash=$(echo "$line" | awk '{print $1}')
        
        # Calculate the CURRENT hash of the file
        local current_hash=$(sha256sum "$file" | awk '{print $1}')
        
        if [ "$expected_hash" != "$current_hash" ]; then
            warn "ALERT: File $file has been MODIFIED or REPLACED!"
        fi
    done < ~/.file_hashes_baseline
}
```

### Key Snippet: Suspicious Process Auditing
Hackers often leave "backdoors" running. The investigator scans the process list for common tools used in cyber attacks.

```bash
cmd_audit() {
    echo "=== Scanning for Suspicious Activity ==="
    
    # -E: Use extended regex to search for multiple hacker tools
    # grep -v grep: Don't show this search process itself!
    ps aux | grep -E "nc|netcat|nmap|socat" | grep -v grep || \
        echo "No suspicious processes detected."
}
```

**Pro Tip:** Forensics is about "the breadcrumbs." Automating the collection of these crumbs ensures you have the evidence you need when a real security incident occurs!

---

## ✅ Stack 56 Complete!

Congratulations! You've successfully become a "Digital Detective"! You can now:
- ✅ **Perform deep system audits** to identify security weaknesses
- ✅ **Investigate system breaches** using professional forensics techniques
- ✅ **Monitor file integrity** to detect unauthorized modifications
- ✅ **Audit user activity** and correlate logs into an event timeline
- ✅ **Identify suspicious processes** and network connections
- ✅ **Automate incident response** using custom forensic scripts

### What's Next?
In the next stack, we'll dive into **Advanced Data Structures**. You'll learn how to handle complex data like JSON, CSV, and associative arrays to build even more powerful Bash applications!

**Next: Stack 57 - Advanced Data Structures →**

---

*End of Stack 56*