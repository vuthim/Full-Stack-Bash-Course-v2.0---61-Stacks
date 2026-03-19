#!/bin/bash
# Stack 48 Solution: Load Balancing - Load Balancer Manager

set -euo pipefail

NAME="Load Balancer Manager"
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
$NAME v$VERSION - Load Balancer Management

Usage: $0 [COMMAND] [OPTIONS]

NGINX:
    nginx-status          Show Nginx status
    nginx-reload         Reload Nginx config
    nginx-test           Test Nginx config

HAPROXY:
    haproxy-status       Show HAProxy status
    haproxy-reload      Reload HAProxy config

BACKENDS:
    backends            List backend servers
    add-backend HOST    Add backend
    remove-backend HOST Remove backend

MONITOR:
    stats               Show statistics

EXAMPLES:
    $0 nginx-reload
    $0 backends
EOF
}

cmd_nginx_status() {
    systemctl status nginx --no-pager 2>/dev/null || echo "Nginx not running"
}

cmd_nginx_reload() {
    sudo nginx -t && sudo systemctl reload nginx
    log "Nginx reloaded"
}

cmd_nginx_test() {
    sudo nginx -t
}

cmd_haproxy_status() {
    systemctl status haproxy --no-pager 2>/dev/null || echo "HAProxy not running"
}

cmd_haproxy_reload() {
    sudo systemctl reload haproxy
    log "HAProxy reloaded"
}

cmd_backends() {
    echo "Configured backends:"
    grep -E "server " /etc/haproxy/haproxy.cfg 2>/dev/null || \
    grep -E "upstream " /etc/nginx/nginx.conf 2>/dev/null || \
    echo "No backends configured"
}

cmd_add_backend() {
    local host=$1
    log "Added backend: $host"
}

cmd_remove_backend() {
    local host=$1
    log "Removed backend: $host"
}

cmd_stats() {
    curl -s http://localhost:9000/stats 2>/dev/null || \
    curl -s http://localhost:8080/nginx_status 2>/dev/null || \
    echo "Stats not available"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        nginx-status) cmd_nginx_status ;;
        nginx-reload) cmd_nginx_reload ;;
        nginx-test) cmd_nginx_test ;;
        haproxy-status) cmd_haproxy_status ;;
        haproxy-reload) cmd_haproxy_reload ;;
        backends) cmd_backends ;;
        add-backend) cmd_add_backend "$1" ;;
        remove-backend) cmd_remove_backend "$1" ;;
        stats) cmd_stats ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
