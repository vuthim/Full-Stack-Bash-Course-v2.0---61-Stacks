#!/bin/bash
# Stack 41 Solution: Performance Tuning - Performance Optimizer

set -euo pipefail

NAME="Performance Tuner"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Performance Tuning Tool

Usage: $0 [COMMAND] [OPTIONS]

ANALYZE:
    cpu                  Analyze CPU usage
    memory               Analyze memory usage
    disk                 Analyze disk I/O
    network              Analyze network performance

TUNE:
    cpu-governor         Set CPU governor
    disk-scheduler       Set disk scheduler
    network-buffer       Tune network buffers

EXAMPLES:
    $0 cpu
    $0 cpu-governor performance
EOF
}

cmd_cpu() {
    echo -e "${BLUE}=== CPU Analysis ===${NC}"
    echo "Load average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "CPU usage:"
    top -bn1 | grep "Cpu(s)"
    echo ""
    echo "Top CPU consumers:"
    ps aux --sort=-%cpu | head -6
}

cmd_memory() {
    echo -e "${BLUE}=== Memory Analysis ===${NC}"
    free -h
    echo ""
    echo "Top memory consumers:"
    ps aux --sort=-%mem | head -6
}

cmd_disk() {
    echo -e "${BLUE}=== Disk I/O Analysis ===${NC}"
    iostat -x 2>/dev/null || cat /proc/diskstats | head -10
    echo ""
    echo "Mount options:"
    mount | grep '^/dev/'
}

cmd_network() {
    echo -e "${BLUE}=== Network Performance ===${NC}"
    ss -s
    echo ""
    echo "Network buffers:"
    ip -s link show | grep -A1 RX
}

cmd_cpu_governor() {
    local governor=$1
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$governor" | sudo tee "$cpu" > /dev/null 2>&1
    done
    
    log "CPU governor set to: $governor"
}

cmd_disk_scheduler() {
    local device=$1
    local scheduler=$2
    
    echo "$scheduler" | sudo tee "/sys/block/$device/queue/scheduler" > /dev/null
    log "Disk scheduler set for $device"
}

cmd_network_buffer() {
    log "Tuning network buffers..."
    
    sudo sysctl -w net.core.rmem_max=16777216
    sudo sysctl -w net.core.wmem_max=16777216
    sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
    sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216"
    
    log "Network buffers tuned"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        cpu) cmd_cpu ;;
        memory) cmd_memory ;;
        disk) cmd_disk ;;
        network) cmd_network ;;
        cpu-governor) cmd_cpu_governor "$1" ;;
        disk-scheduler) cmd_disk_scheduler "$1" "$2" ;;
        network-buffer) cmd_network_buffer ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
