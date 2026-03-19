#!/bin/bash
# Stack 17 Solution: Network Scripting - Network Tools

set -euo pipefail

NAME="Network Tools"
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
$NAME v$VERSION - Network Scripting Tools

Usage: $0 [COMMAND] [OPTIONS]

DIAGNOSTICS:
    ping HOST [COUNT]      Ping host
    trace HOST             Traceroute
    dns DOMAIN             DNS lookup
    reverse-ip IP          Reverse DNS lookup
    port-check HOST PORT   Check port status

INFO:
    myip                  Show public IP
    interfaces            List network interfaces
    connections           Show active connections
    listening             Show listening ports

MONITOR:
    watch-ports            Monitor port changes
    bandwidth              Monitor bandwidth
    http-check URL         Check HTTP status

SCAN:
    scan-ports HOST [RANGE]    Scan ports
    scan-local             Scan local network

EXAMPLES:
    $0 ping 8.8.8.8
    $0 dns google.com
    $0 port-check example.com 443
    $0 scan-ports 192.168.1.1 1-1000
EOF
}

cmd_ping() {
    local host=$1
    local count=${2:-4}
    ping -c "$count" "$host"
}

cmd_trace() {
    local host=$1
    if command -v traceroute &>/dev/null; then
        traceroute "$host"
    else
        tracepath "$host"
    fi
}

cmd_dns() {
    local domain=$1
    echo -e "${BLUE}=== DNS Records for $domain ===${NC}"
    
    for type in A AAAA MX NS TXT CNAME; do
        result=$(dig +short "$type" "$domain" 2>/dev/null)
        if [ -n "$result" ]; then
            echo "$type: $result"
        fi
    done
}

cmd_reverse_ip() {
    local ip=$1
    dig +short -x "$ip"
}

cmd_port_check() {
    local host=$1
    local port=$2
    
    if timeout 3 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        log "Port $port is open on $host"
    else
        error "Port $port is closed on $host"
    fi
}

cmd_myip() {
    echo "Public IP: $(curl -s ifconfig.me)"
}

cmd_interfaces() {
    echo -e "${BLUE}=== Network Interfaces ===${NC}"
    ip -br addr show
    echo ""
    echo -e "${BLUE}=== Routing Table ===${NC}"
    ip route
}

cmd_connections() {
    echo -e "${BLUE}=== Active Connections ===${NC}"
    ss -tunap | grep ESTAB || echo "No established connections"
}

cmd_listening() {
    echo -e "${BLUE}=== Listening Ports ===${NC}"
    ss -tlnp | awk 'NR>1{print $4}' | sort -u
}

cmd_watch_ports() {
    echo "Monitoring port changes (Ctrl+C to stop)..."
    while true; do
        clear
        ss -tlnp | awk 'NR>1{print $4}' | sort -u
        sleep 5
    done
}

cmd_bandwidth() {
    echo -e "${BLUE}=== Network Statistics ===${NC}"
    ip -s link show
    echo ""
    cat /proc/net/dev
}

cmd_http_check() {
    local url=$1
    local code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$code" -eq 200 ]; then
        log "HTTP $code - OK"
    else
        error "HTTP $code - Failed"
    fi
}

cmd_scan_ports() {
    local host=$1
    local range=${2:-"1-1000"}
    
    local start=${range%-*}
    local end=${range#*-}
    
    echo "Scanning $host ports $start-$end..."
    
    for port in $(seq "$start" "$end"); do
        if timeout 0.1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
            echo "Port $port is open"
        fi
    done
}

cmd_scan_local() {
    local gateway=$(ip route | awk '/default/ {print $3}')
    local network=$(echo "$gateway" | sed 's/\.[0-9]*$/.*/')
    
    echo "Scanning local network: $network"
    
    for ip in $(seq 1 254); do
        timeout 0.2 ping -c 1 "${network%.*}.$ip" &>/dev/null && \
            echo "Found: ${network%.*}.$ip"
    done
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        ping) cmd_ping "$1" "${2:-4}" ;;
        trace) cmd_trace "$1" ;;
        dns) cmd_dns "$1" ;;
        reverse-ip) cmd_reverse_ip "$1" ;;
        port-check) cmd_port_check "$1" "$2" ;;
        myip) cmd_myip ;;
        interfaces) cmd_interfaces ;;
        connections) cmd_connections ;;
        listening) cmd_listening ;;
        watch-ports) cmd_watch_ports ;;
        bandwidth) cmd_bandwidth ;;
        http-check) cmd_http_check "$1" ;;
        scan-ports) cmd_scan_ports "$1" "${2:-1-1000}" ;;
        scan-local) cmd_scan_local ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
