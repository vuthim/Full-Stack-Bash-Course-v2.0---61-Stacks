#!/bin/bash
# Stack 27 Solution: Systemd Deep Dive - Service Manager

set -euo pipefail

NAME="Systemd Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Systemd Service Management

Usage: $0 [COMMAND] [OPTIONS]

SERVICES:
    list                 List all services
    running              List running services
    start NAME           Start service
    stop NAME           Stop service
    restart NAME        Restart service
    status NAME         Show service status
    enable NAME         Enable service
    disable NAME        Disable service

LOGS:
    logs NAME            Show service logs
    logs-err NAME       Show error logs

CREATE:
    create NAME CMD     Create simple service

TIMERS:
    timers              List active timers
    list-timer NAME     List timer details

EXAMPLES:
    $0 running
    $0 status nginx
    $0 logs myapp
    $0 create myapp "/usr/bin/myapp"
EOF
}

cmd_list() {
    echo -e "${BLUE}=== All Services ===${NC}"
    systemctl list-units --type=service --all | head -30
}

cmd_running() {
    echo -e "${BLUE}=== Running Services ===${NC}"
    systemctl list-units --type=service --state=running
}

cmd_start() {
    sudo systemctl start "$1"
    log "Started: $1"
}

cmd_stop() {
    sudo systemctl stop "$1"
    log "Stopped: $1"
}

cmd_restart() {
    sudo systemctl restart "$1"
    log "Restarted: $1"
}

cmd_status() {
    systemctl status "$1" --no-pager
}

cmd_enable() {
    sudo systemctl enable "$1"
    log "Enabled: $1"
}

cmd_disable() {
    sudo systemctl disable "$1"
    log "Disabled: $1"
}

cmd_logs() {
    local name=$1
    journalctl -u "$name" -n 50 --no-pager
}

cmd_logs_err() {
    local name=$1
    journalctl -u "$name" -p err -n 50 --no-pager
}

cmd_create() {
    local name=$1
    local cmd=$2
    
    local unit_file="/etc/systemd/system/${name}.service"
    
    sudo tee "$unit_file" > /dev/null << EOF
[Unit]
Description=$name Service
After=network.target

[Service]
Type=simple
ExecStart=$cmd
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    log "Created service: $name"
}

cmd_timers() {
    echo -e "${BLUE}=== Active Timers ===${NC}"
    systemctl list-timers --all
}

cmd_list_timer() {
    local name=$1
    systemctl list-timers "$name" --all
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        list) cmd_list ;;
        running) cmd_running ;;
        start) cmd_start "$1" ;;
        stop) cmd_stop "$1" ;;
        restart) cmd_restart "$1" ;;
        status) cmd_status "$1" ;;
        enable) cmd_enable "$1" ;;
        disable) cmd_disable "$1" ;;
        logs) cmd_logs "$1" ;;
        logs-err) cmd_logs_err "$1" ;;
        create) cmd_create "$1" "$2" ;;
        timers) cmd_timers ;;
        list-timer) cmd_list_timer "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
