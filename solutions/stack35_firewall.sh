#!/bin/bash
# Stack 35 Solution: Firewall & Security - Firewall Manager

set -euo pipefail

NAME="Firewall Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

detect_firewall() {
    if command -v ufw &>/dev/null; then
        echo "ufw"
    elif command -v firewall-cmd &>/dev/null; then
        echo "firewalld"
    elif command -v iptables &>/dev/null; then
        echo "iptables"
    else
        echo "none"
    fi
}

FW=$(detect_firewall)

show_usage() {
    cat << EOF
$NAME v$VERSION - Firewall Management Tool
Detected: $FW

Usage: $0 [COMMAND] [OPTIONS]

STATUS:
    status               Show firewall status
    list                List rules

RULES:
    allow PORT          Allow port
    deny PORT           Deny port
    allow SERVICE       Allow service
    delete RULE         Delete rule

MANAGE:
    enable              Enable firewall
    disable             Disable firewall
    reset               Reset firewall

EXAMPLES:
    $0 status
    $0 allow 8080
    $0 allow http
EOF
}

cmd_status() {
    case $FW in
        ufw) sudo ufw status verbose ;;
        firewalld) sudo firewall-cmd --list-all ;;
        iptables) sudo iptables -L -n -v ;;
        *) echo "No firewall detected" ;;
    esac
}

cmd_list() {
    cmd_status
}

cmd_allow() {
    local port=$1
    
    case $FW in
        ufw)
            sudo ufw allow "$port"/tcp
            ;;
        firewalld)
            sudo firewall-cmd --add-port="$port"/tcp --permanent
            sudo firewall-cmd --reload
            ;;
        iptables)
            sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
            ;;
        *)
            error "No firewall detected"
            ;;
    esac
    
    log "Allowed port: $port"
}

cmd_deny() {
    local port=$1
    
    case $FW in
        ufw)
            sudo ufw deny "$port"/tcp
            ;;
        firewalld)
            sudo firewall-cmd --remove-port="$port"/tcp --permanent
            sudo firewall-cmd --reload
            ;;
        iptables)
            sudo iptables -A INPUT -p tcp --dport "$port" -j DROP
            ;;
        *)
            error "No firewall detected"
            ;;
    esac
    
    log "Denied port: $port"
}

cmd_allow_service() {
    local service=$1
    
    case $FW in
        ufw)
            sudo ufw allow "$service"
            ;;
        firewalld)
            sudo firewall-cmd --add-service="$service" --permanent
            sudo firewall-cmd --reload
            ;;
        *)
            error "No firewall detected"
            ;;
    esac
    
    log "Allowed service: $service"
}

cmd_delete() {
    local rule=$1
    
    case $FW in
        ufw)
            sudo ufw delete "$rule"
            ;;
        firewalld)
            error "Use rule number with firewall-cmd"
            ;;
        *)
            error "No firewall detected"
            ;;
    esac
}

cmd_enable() {
    case $FW in
        ufw) sudo ufw enable ;;
        firewalld) sudo systemctl enable firewalld ;;
        iptables) error "Enable iptables manually" ;;
        *) error "No firewall detected" ;;
    esac
    
    log "Firewall enabled"
}

cmd_disable() {
    case $FW in
        ufw) sudo ufw disable ;;
        firewalld) sudo systemctl stop firewalld ;;
        iptables) sudo iptables -F ;;
        *) error "No firewall detected" ;;
    esac
    
    log "Firewall disabled"
}

cmd_reset() {
    case $FW in
        ufw) sudo ufw reset ;;
        firewalld) sudo firewall-cmd --complete-reload ;;
        iptables) sudo iptables -F ;;
        *) error "No firewall detected" ;;
    esac
    
    log "Firewall reset"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        status) cmd_status ;;
        list) cmd_list ;;
        allow) cmd_allow "$1" ;;
        deny) cmd_deny "$1" ;;
        allow-service) cmd_allow_service "$1" ;;
        delete) cmd_delete "$1" ;;
        enable) cmd_enable ;;
        disable) cmd_disable ;;
        reset) cmd_reset ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
