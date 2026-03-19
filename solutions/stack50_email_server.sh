#!/bin/bash
# Stack 50 Solution: Email Server - Mail Server Manager

set -euo pipefail

NAME="Mail Server Manager"
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
$NAME v$Version - Email Server Management

Usage: $0 [COMMAND] [OPTIONS]

SERVICES:
    status               Show mail services status
    start                Start mail services
    stop                 Stop mail services
    restart              Restart mail services

POSTFIX:
    postfix-status       Postfix status
    postfix-reload      Reload Postfix
    queue               Show mail queue

DOVECOT:
    dovecot-status      Dovecot status
    dovecot-reload      Reload Dovecot

MAIL:
    test EMAIL           Send test email
    check EMAIL         Check mail for user

EXAMPLES:
    $0 status
    $0 queue
EOF
}

cmd_status() {
    echo "=== Mail Services ==="
    systemctl status postfix --no-pager 2>/dev/null || echo "Postfix: not running"
    systemctl status dovecot --no-pager 2>/dev/null || echo "Dovecot: not running"
}

cmd_start() {
    sudo systemctl start postfix dovecot
    log "Mail services started"
}

cmd_stop() {
    sudo systemctl stop postfix dovecot
    log "Mail services stopped"
}

cmd_restart() {
    sudo systemctl restart postfix dovecot
    log "Mail services restarted"
}

cmd_postfix_status() {
    systemctl status postfix --no-pager
}

cmd_postfix_reload() {
    sudo systemctl reload postfix
    log "Postfix reloaded"
}

cmd_queue() {
    mailq 2>/dev/null || postqueue -p
}

cmd_dovecot_status() {
    systemctl status dovecot --no-pager
}

cmd_dovecot_reload() {
    sudo systemctl reload dovecot
    log "Dovecot reloaded"
}

cmd_test() {
    local email=$1
    
    echo "Test email" | mail -s "Test" "$email"
    log "Test email sent to $email"
}

cmd_check() {
    local user=$1
    
    mail -u "$user" 2>/dev/null || echo "No mail for $user"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        status) cmd_status ;;
        start) cmd_start ;;
        stop) cmd_stop ;;
        restart) cmd_restart ;;
        postfix-status) cmd_postfix_status ;;
        postfix-reload) cmd_postfix_reload ;;
        queue) cmd_queue ;;
        dovecot-status) cmd_dovecot_status ;;
        dovecot-reload) cmd_dovecot_reload ;;
        test) cmd_test "$1" ;;
        check) cmd_check "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
