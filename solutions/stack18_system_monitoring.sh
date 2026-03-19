#!/bin/bash
# Stack 18 Solution: System Monitoring - System Monitor

set -euo pipefail

NAME="System Monitor"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - System Monitoring Dashboard

Usage: $0 [COMMAND] [OPTIONS]

DASHBOARDS:
    overview            System overview
    cpu                 CPU usage details
    memory              Memory usage details
    disk                Disk usage details
    processes           Top processes
    network             Network statistics
    io                  I/O statistics
    all                 Full system dashboard

MONITORING:
    watch [INTERVAL]    Continuous monitoring
    alert THRESHOLD     Alert when threshold exceeded
    history             Show historical data

SERVICES:
    services            List running services
    failed              Show failed services

EXAMPLES:
    $0 overview
    $0 watch 5
    $0 alert 90
EOF
}

cmd_overview() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}     SYSTEM OVERVIEW${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    echo -e "${YELLOW}--- CPU ---${NC}"
    top -bn1 | head -5 | tail -1
    echo ""
    echo -e "${YELLOW}--- Memory ---${NC}"
    free -h
    echo ""
    echo -e "${YELLOW}--- Disk ---${NC}"
    df -h | grep -E '^/dev/'
}

cmd_cpu() {
    echo -e "${BLUE}=== CPU Information ===${NC}"
    lscpu | grep -E "Model name|CPU\(s\)|Thread|Core|Socket"
    echo ""
    echo -e "${YELLOW}=== Current Usage ===${NC}"
    top -bn1 | head -8 | tail -3
}

cmd_memory() {
    echo -e "${BLUE}=== Memory Usage ===${NC}"
    free -h
    echo ""
    echo -e "${BLUE}=== Memory Details ===${NC}"
    cat /proc/meminfo | head -10
}

cmd_disk() {
    echo -e "${BLUE}=== Disk Usage ===${NC}"
    df -h | grep -E '^/dev/'
    echo ""
    echo -e "${BLUE}=== Inode Usage ===${NC}"
    df -i | grep -E '^/dev/'
}

cmd_processes() {
    echo -e "${BLUE}=== Top Processes by CPU ===${NC}"
    ps aux --sort=-%cpu | head -11
    echo ""
    echo -e "${BLUE}=== Top Processes by Memory ===${NC}"
    ps aux --sort=-%mem | head -11
}

cmd_network() {
    echo -e "${BLUE}=== Network Interfaces ===${NC}"
    ip -br addr show
    echo ""
    echo -e "${BLUE}=== Network Statistics ===${NC}"
    cat /proc/net/snmp | head -10
    echo ""
    echo -e "${BLUE}=== Active Connections ===${NC}"
    ss -s
}

cmd_io() {
    echo -e "${BLUE}=== I/O Statistics ===${NC}"
    iostat -x 2>/dev/null || (echo "iostat not available" && cat /proc/diskstats | head -10)
}

cmd_all() {
    cmd_overview
    echo ""
    cmd_processes
    echo ""
    cmd_network
}

cmd_watch() {
    local interval=${1:-2}
    echo "Monitoring (Ctrl+C to stop)..."
    while true; do
        clear
        echo "Updated: $(date)"
        echo ""
        cmd_overview
        sleep "$interval"
    done
}

cmd_alert() {
    local threshold=$1
    log "Monitoring CPU usage. Alert threshold: $threshold%"
    
    while true; do
        cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        if [ "${cpu%.*}" -gt "$threshold" ]; then
            echo -e "${RED}ALERT: CPU at ${cpu}%${NC}"
        fi
        sleep 5
    done
}

cmd_services() {
    echo -e "${BLUE}=== Running Services ===${NC}"
    systemctl list-units --type=service --state=running | head -20
}

cmd_failed() {
    echo -e "${RED}=== Failed Services ===${NC}"
    systemctl --failed --type=service
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        overview) cmd_overview ;;
        cpu) cmd_cpu ;;
        memory) cmd_memory ;;
        disk) cmd_disk ;;
        processes) cmd_processes ;;
        network) cmd_network ;;
        io) cmd_io ;;
        all) cmd_all ;;
        watch) cmd_watch "${1:-2}" ;;
        alert) cmd_alert "${1:-90}" ;;
        services) cmd_services ;;
        failed) cmd_failed ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
