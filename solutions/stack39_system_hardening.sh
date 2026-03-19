#!/bin/bash
# Stack 39 Solution: System Hardening - Security Hardening

set -euo pipefail

NAME="System Hardening"
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
$NAME v$VERSION - System Hardening Tool

Usage: $0 [COMMAND] [OPTIONS]

AUDIT:
    audit                Run security audit
    check-perms          Check file permissions
    check-services       Check running services

HARDENING:
    disable-services     Disable unnecessary services
    enable-firewall      Enable firewall
    set-perms            Set secure permissions
    secure-ssh           Secure SSH config

PASSWORDS:
    password-policy      Set password policy
    lock-inactive        Lock inactive accounts

EXAMPLES:
    $0 audit
    $0 enable-firewall
    $0 secure-ssh
EOF
}

cmd_audit() {
    echo -e "${BLUE}=== Security Audit ===${NC}"
    echo ""
    
    echo "--- System Info ---"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo ""
    
    echo "--- Open Ports ---"
    ss -tlnp 2>/dev/null | grep LISTEN || netstat -tlnp 2>/dev/null | grep LISTEN
    echo ""
    
    echo "--- Failed Login Attempts ---"
    lastb | head -10
    echo ""
    
    echo "--- SUID Files ---"
    find / -perm -4000 -type f 2>/dev/null | wc -l
    echo ""
    
    echo "--- User Accounts ---"
    awk -F: '($3 >= 1000) {print $1, $7}' /etc/passwd
}

cmd_check_perms() {
    echo "Checking critical file permissions..."
    
    for file in /etc/passwd /etc/shadow /etc/group; do
        if [ -f "$file" ]; then
            perms=$(stat -c %a "$file")
            owner=$(stat -c %U:%G "$file")
            echo "$file: $perms $owner"
        fi
    done
}

cmd_check_services() {
    echo -e "${BLUE}=== Running Services ===${NC}"
    systemctl list-units --type=service --state=running | head -20
}

cmd_disable_services() {
    local services=("telnet" "rsh" "rlogin" "vsftpd")
    
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            warn "Service $svc is running - consider disabling"
        fi
    done
    
    log "Check complete"
}

cmd_enable_firewall() {
    if command -v ufw &>/dev/null; then
        sudo ufw --force enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        log "UFW firewall enabled"
    elif command -v firewall-cmd &>/dev/null; then
        sudo firewall-cmd --set-default-zone=drop
        sudo firewall-cmd --reload
        log "firewalld enabled"
    else
        error "No firewall found"
    fi
}

cmd_set_perms() {
    log "Setting secure permissions..."
    
    chmod 600 /etc/ssh/sshd_config
    chmod 644 /etc/passwd
    chmod 600 /etc/shadow
    chmod 644 /etc/group
    
    log "Permissions set"
}

cmd_secure_ssh() {
    log "Securing SSH configuration..."
    
    local sshd_config="/etc/ssh/sshd_config"
    
    if [ -f "$sshd_config" ]; then
        sudo cp "$sshd_config" "${sshd_config}.bak"
        
        sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$sshd_config"
        sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"
        sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' "$sshd_config"
        
        sudo systemctl restart sshd
        log "SSH secured"
    else
        error "SSH config not found"
    fi
}

cmd_password_policy() {
    log "Setting password policy..."
    
    sudo authconfig --passmaxlen=128 --update
    sudo sed -i 's/^PASS_MAX_LEN.*/PASS_MAX_LEN 90/' /etc/login.defs
    
    log "Password policy updated"
}

cmd_lock_inactive() {
    log "Locking inactive accounts..."
    
    for user in $(awk -F: '($3 >= 1000) {print $1}' /etc/passwd); do
        last_log=$(lastlog -u "$user" | tail -1 | awk '{print $3}')
        if [ "$last_log" = "**Never" ] || [ -z "$last_log" ]; then
            warn "User $user has never logged in"
        fi
    done
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        audit) cmd_audit ;;
        check-perms) cmd_check_perms ;;
        check-services) cmd_check_services ;;
        disable-services) cmd_disable_services ;;
        enable-firewall) cmd_enable_firewall ;;
        set-perms) cmd_set_perms ;;
        secure-ssh) cmd_secure_ssh ;;
        password-policy) cmd_password_policy ;;
        lock-inactive) cmd_lock_inactive ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
