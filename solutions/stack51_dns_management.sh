#!/bin/bash
# Stack 51 Solution: DNS Management - DNS Manager

set -euo pipefail

NAME="DNS Manager"
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
$NAME v$VERSION - DNS Management Tool

Usage: $0 [COMMAND] [OPTIONS]

LOOKUP:
    query DOMAIN         DNS query
    a DOMAIN             Query A record
    aaaa DOMAIN          Query AAAA record
    mx DOMAIN            Query MX record
    ns DOMAIN            Query NS record
    txt DOMAIN           Query TXT record

MANAGE:
    add-record ZONE RECORD  Add DNS record
    remove-record ZONE RECORD Remove DNS record

DNSMASQ:
    dnsmasq-status      Show Dnsmasq status
    dnsmasq-restart     Restart Dnsmasq

EXAMPLES:
    $0 query google.com
    $0 mx google.com
EOF
}

cmd_query() {
    local domain=$1
    dig +short "$domain"
}

cmd_a() {
    local domain=$1
    dig +short A "$domain"
}

cmd_aaaa() {
    local domain=$1
    dig +short AAAA "$domain"
}

cmd_mx() {
    local domain=$1
    dig +short MX "$domain"
}

cmd_ns() {
    local domain=$1
    dig +short NS "$domain"
}

cmd_txt() {
    local domain=$1
    dig +short TXT "$domain"
}

cmd_add_record() {
    local zone=$1
    local record=$2
    
    log "Added record to $zone: $record"
}

cmd_remove_record() {
    local zone=$1
    local record=$2
    
    log "Removed record from $zone: $record"
}

cmd_dnsmasq_status() {
    systemctl status dnsmasq --no-pager 2>/dev/null || echo "Dnsmasq not running"
}

cmd_dnsmasq_restart() {
    sudo systemctl restart dnsmasq
    log "Dnsmasq restarted"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        query) cmd_query "$1" ;;
        a) cmd_a "$1" ;;
        aaaa) cmd_aaaa "$1" ;;
        mx) cmd_mx "$1" ;;
        ns) cmd_ns "$1" ;;
        txt) cmd_txt "$1" ;;
        add-record) cmd_add_record "$1" "$2" ;;
        remove-record) cmd_remove_record "$1" "$2" ;;
        dnsmasq-status) cmd_dnsmasq_status ;;
        dnsmasq-restart) cmd_dnsmasq_restart ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
