#!/bin/bash
# Stack 30 Solution: Logging Best Practices - Log Manager

set -euo pipefail

NAME="Log Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_DIR="${LOG_DIR:-/var/log}"
APP_LOG="$LOG_DIR/app.log"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Logging Best Practices Tool

Usage: $0 [COMMAND] [OPTIONS]

LOGGING:
    write LEVEL MSG      Write log entry
    tail [LINES]         Tail application logs
    grep PATTERN         Search logs
    rotate               Rotate logs

ANALYSIS:
    stats                Show log statistics
    errors               Show error entries
    summary              Show log summary

EXAMPLES:
    $0 write info "Application started"
    $0 tail 50
    $0 errors
EOF
}

log_with_timestamp() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$APP_LOG"
}

cmd_write() {
    local level=$1
    local msg=$2
    
    log_with_timestamp "$level" "$msg"
    log "Logged: [$level] $msg"
}

cmd_tail() {
    local lines=${1:-20}
    
    if [ -f "$APP_LOG" ]; then
        tail -n "$lines" "$APP_LOG"
    else
        error "Log file not found: $APP_LOG"
    fi
}

cmd_grep() {
    local pattern=$1
    
    if [ -f "$APP_LOG" ]; then
        grep -i "$pattern" "$APP_LOG"
    else
        error "Log file not found: $APP_LOG"
    fi
}

cmd_rotate() {
    if [ ! -f "$APP_LOG" ]; then
        error "Log file not found"
        exit 1
    fi
    
    local archived="$APP_LOG.$(date +%Y%m%d)"
    mv "$APP_LOG" "$archived"
    touch "$APP_LOG"
    chmod 644 "$APP_LOG"
    
    gzip "$archived"
    log "Rotated log to: ${archived}.gz"
}

cmd_stats() {
    if [ ! -f "$APP_LOG" ]; then
        error "Log file not found"
        exit 1
    fi
    
    echo -e "${BLUE}=== Log Statistics ===${NC}"
    echo "Total entries: $(wc -l < "$APP_LOG")"
    echo "Errors: $(grep -c "ERROR" "$APP_LOG" 2>/dev/null || echo 0)"
    echo "Warnings: $(grep -c "WARN" "$APP_LOG" 2>/dev/null || echo 0)"
    echo "Info: $(grep -c "INFO" "$APP_LOG" 2>/dev/null || echo 0)"
}

cmd_errors() {
    if [ -f "$APP_LOG" ]; then
        grep -E "ERROR|CRITICAL" "$APP_LOG"
    else
        error "Log file not found"
    fi
}

cmd_summary() {
    if [ ! -f "$APP_LOG" ]; then
        error "Log file not found"
        exit 1
    fi
    
    echo -e "${BLUE}=== Log Summary ===${NC}"
    echo "Last 10 entries:"
    tail -10 "$APP_LOG"
    echo ""
    cmd_stats
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        write) cmd_write "$1" "$2" ;;
        tail) cmd_tail "${1:-20}" ;;
        grep) cmd_grep "$1" ;;
        rotate) cmd_rotate ;;
        stats) cmd_stats ;;
        errors) cmd_errors ;;
        summary) cmd_summary ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
