#!/bin/bash
# Stack 56 Solution: Security Auditing & Forensics - Security Audit

set -euo pipefail

NAME="Security Forensics"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Security Auditing & Forensics

Usage: $0 [COMMAND] [OPTIONS]

AUDIT:
    audit                Run security audit
    check-login          Check failed logins
    check-process        Check suspicious processes
    check-files          Check modified files

FORENSICS:
    timeline             Create event timeline
    hash-files           Generate file hashes
    compare-hashes      Compare file hashes

EXAMPLES:
    $0 audit
    $0 check-login
EOF
}

cmd_audit() {
    echo -e "${BLUE}=== Security Audit ===${NC}"
    
    echo "Checking for suspicious processes..."
    ps aux | grep -E "nc|netcat|nmap" | grep -v grep || echo "None found"
    
    echo ""
    echo "Checking for SUID files..."
    find / -perm -4000 -type f 2>/dev/null | head -10
    
    echo ""
    echo "Checking open ports..."
    ss -tlnp | grep LISTEN
}

cmd_check_login() {
    echo -e "${BLUE}=== Failed Login Attempts ===${NC}"
    lastb | head -20
    echo ""
    echo "Successful logins:"
    last | head -20
}

cmd_check_process() {
    echo -e "${BLUE}=== Running Processes ===${NC}"
    ps aux --sort=-%mem | head -15
    echo ""
    echo "Process count: $(ps aux | wc -l)"
}

cmd_check_files() {
    echo -e "${BLUE}=== Recently Modified Files ===${NC}"
    find / -type f -mtime -1 2>/dev/null | head -20
}

cmd_timeline() {
    echo -e "${BLUE}=== Event Timeline ===${NC}"
    
    echo "Last logins:"
    last | head -10
    echo ""
    echo "Last commands:"
    history | tail -10
    echo ""
    echo "System events:"
    journalctl -n 10 --no-pager
}

cmd_hash_files() {
    echo -e "${BLUE}=== File Hashes ===${NC}"
    
    for file in /bin/ls /bin/bash /etc/passwd; do
        if [ -f "$file" ]; then
            echo "$file: $(sha256sum "$file" | awk '{print $1}')"
        fi
    done
}

cmd_compare_hashes() {
    echo "Comparing current hashes with baseline..."
    
    if [ -f ~/.file_hashes ]; then
        while read -r line; do
            file=$(echo "$line" | awk '{print $2}')
            old_hash=$(echo "$line" | awk '{print $1}')
            new_hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
            
            if [ "$old_hash" != "$new_hash" ]; then
                warn "Modified: $file"
            fi
        done < ~/.file_hashes
    else
        echo "No baseline found. Run hash-files first."
    fi
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        audit) cmd_audit ;;
        check-login) cmd_check_login ;;
        check-process) cmd_check_process ;;
        check-files) cmd_check_files ;;
        timeline) cmd_timeline ;;
        hash-files) cmd_hash_files ;;
        compare-hashes) cmd_compare_hashes ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
