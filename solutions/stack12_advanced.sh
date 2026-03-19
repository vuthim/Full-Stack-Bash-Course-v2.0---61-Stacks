#!/bin/bash
# Stack 12 Solution: Advanced Scripting - System Admin Toolbox

set -euo pipefail  # Strict mode

# ================ CONFIGURATION ================

NAME="System Admin Toolbox"
VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\03[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ================ HELPER FUNCTIONS ================

log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}"
}

die() {
    error "$*"
    exit 1
}

# ================ INPUT VALIDATION ================

validate_number() {
    local num=$1
    if ! [[ $num =~ ^[0-9]+$ ]]; then
        error "Not a number: $num"
        return 1
    fi
    return 0
}

validate_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        error "File not found: $file"
        return 1
    fi
    return 0
}

# ================ DEBUGGING ================

DEBUG=false

debug() {
    if [ "$DEBUG" = true ]; then
        echo -e "${YELLOW}[DEBUG] $*${NC}"
    fi
}

# ================ ERROR HANDLING ================

trap 'error "Error on line $LINENO"; exit 1' ERR
trap 'debug "Cleaning up..."' EXIT

# ================ COMMAND LINE PARSING ================

show_usage() {
    cat << EOF
$NAME v$VERSION

Usage: $0 [COMMAND] [OPTIONS]

COMMANDS:
    sysinfo      Show system information
    disks        Show disk usage
    memory       Show memory usage
    processes    Show top processes
    network      Show network status
    logs [n]     View recent system logs
    backup       Run backup

OPTIONS:
    -h, --help   Show this help
    -v, --version Show version
    -d           Enable debug mode

EXAMPLES:
    $0 sysinfo
    $0 disks
    $0 processes
EOF
}

# ================ MAIN FUNCTIONS ================

do_sysinfo() {
    echo -e "${CYAN}=== System Information ===${NC}"
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Users: $(who | wc -l) currently logged in"
    echo "Last boot: $(who -b | awk '{print $3, $4}')"
}

do_disks() {
    echo -e "${CYAN}=== Disk Usage ===${NC}"
    df -h | grep -v tmpfs | awk '{printf "%-20s %10s %10s %10s %s\n", $1, $2, $3, $4, $5}'
}

do_memory() {
    echo -e "${CYAN}=== Memory Usage ===${NC}"
    free -h | awk 'NR==1{printf "%-15s %10s %10s %10s\n", $1, $2, $3, $4} NR>1{printf "%-15s %10s %10s %10s\n", $1, $2, $3, $3}'
}

do_processes() {
    echo -e "${CYAN}=== Top Processes (Memory) ===${NC}"
    ps aux --sort=-%mem | head -11 | awk '{printf "%-10s %6s %6s %s\n", $2, $4, 11, $11}'
}

do_network() {
    echo -e "${CYAN}=== Network Status ===${NC}"
    echo "IP Addresses:"
    ip -brief addr show | grep UP || echo "No active interfaces"
    echo ""
    echo "Active Connections:"
    ss -tun | grep ESTAB | wc -l | xargs echo "  Established:"
}

do_logs() {
    local lines=${1:-10}
    echo -e "${CYAN}=== Last $lines System Logs ===${NC}"
    journalctl -n "$lines" 2>/dev/null || \
        tail -n "$lines" /var/log/syslog 2>/dev/null || \
        echo "No logs available"
}

do_backup() {
    echo -e "${CYAN}=== Backup Tool ===${NC}"
    local backup_dir=${1:-/tmp}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/backup_$timestamp.tar.gz"
    
    log "Creating backup..."
    tar -czf "$backup_file" lessons/ 2>/dev/null && \
        success "Backup created: $backup_file" || \
        die "Backup failed"
}

# ================ MAIN ================

main() {
    local cmd=${1:-}
    case $cmd in
        sysinfo)   do_sysinfo ;;
        disks)     do_disks ;;
        memory)    do_memory ;;
        processes) do_processes ;;
        network)   do_network ;;
        logs)      do_logs "${2:-10}" ;;
        backup)    do_backup "${2:-/tmp}" ;;
        -h|--help) show_usage ;;
        -v|--version) echo "$VERSION" ;;
        -d)         DEBUG=true; shift; main "$@" ;;
        "")        show_usage ;;
        *)         die "Unknown command: $cmd" ;;
    esac
}

main "$@"