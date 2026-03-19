#!/bin/bash
# Stack 23 Solution: Security Scripting - Security Tools

set -euo pipefail

NAME="Security Tools"
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
$NAME v$VERSION - Security Scripting Tools

Usage: $0 [COMMAND] [OPTIONS]

AUDIT:
    perms FILE           Check file permissions
    owners               Find unsafe file ownership
    suid                 Find SUID files
    capabilities        Check file capabilities

PASSWORDS:
    passwd-check USER    Check password strength
    brute-check HOST     Test brute force protection

NETWORK:
    open-ports          Check open ports
    ssh-audit HOST       Audit SSH configuration

SANITIZE:
    sanitize STRING      Sanitize user input

EXAMPLES:
    $0 perms /etc/passwd
    $0 open-ports
    $0 sanitize "test; rm -rf"
EOF
}

cmd_perms() {
    local file=$1
    
    if [ ! -e "$file" ]; then
        error "File not found: $file"
        exit 1
    fi
    
    echo -e "${BLUE}=== Permissions for $file ===${NC}"
    ls -la "$file"
    
    local perms=$(stat -c %a "$file")
    echo ""
    echo "Permission bits: $perms"
    
    if [ "$perms" = "644" ] || [ "$perms" = "600" ]; then
        log "File permissions look OK"
    else
        warn "Consider fixing permissions (644 or 600)"
    fi
}

cmd_owners() {
    echo -e "${BLUE}=== Unusual File Ownership ===${NC}"
    find /home -nouser -nogroup 2>/dev/null | head -20
}

cmd_suid() {
    echo -e "${BLUE}=== SUID Files ===${NC}"
    find / -perm -4000 -type f 2>/dev/null | head -20
}

cmd_capabilities() {
    echo -e "${BLUE}=== File Capabilities ===${NC}"
    if command -v getcap &>/dev/null; then
        getcap -r / 2>/dev/null | head -20
    else
        error "getcap not available"
    fi
}

cmd_passwd_check() {
    local user=$1
    
    echo -e "${BLUE}=== Password Check for $user ===${NC}"
    
    local max_days=$(sudo chage -l "$user" 2>/dev/null | grep "Maximum days" | awk '{print $4}')
    local last_change=$(sudo chage -l "$user" 2>/dev/null | grep "Last password change" | awk '{print $5}')
    
    echo "Last change: $last_change"
    echo "Max days: $max_days"
    
    if [ "${max_days:-0}" -gt 90 ]; then
        warn "Password should be rotated (>$max_days days)"
    else
        log "Password rotation OK"
    fi
}

cmd_brute_check() {
    local host=$1
    
    echo -e "${BLUE}=== Brute Force Check for $host ===${NC}"
    
    if command -v ssh &>/dev/null; then
        timeout 5 ssh -o BatchMode=yes -o ConnectTimeout=2 "$host" exit 2>&1 || true
        log "SSH connection tested"
    fi
}

cmd_open_ports() {
    echo -e "${BLUE}=== Open Ports ===${NC}"
    ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null
}

cmd_ssh_audit() {
    local host=$1
    
    echo -e "${BLUE}=== SSH Audit for $host ===${NC}"
    ssh "$host" "cat /etc/ssh/sshd_config" 2>/dev/null | grep -E "^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)" || \
        error "Could not audit SSH config"
}

cmd_sanitize() {
    local input=$1
    
    echo "Original: $input"
    echo "Sanitized: ${input//[^a-zA-Z0-9_-]/}"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        perms) cmd_perms "$1" ;;
        owners) cmd_owners ;;
        suid) cmd_suid ;;
        capabilities) cmd_capabilities ;;
        passwd-check) cmd_passwd_check "$1" ;;
        brute-check) cmd_brute_check "$1" ;;
        open-ports) cmd_open_ports ;;
        ssh-audit) cmd_ssh_audit "$1" ;;
        sanitize) cmd_sanitize "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
