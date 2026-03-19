#!/bin/bash
# Stack 37 Solution: Prometheus & Grafana - Monitoring Stack

set -euo pipefail

NAME="Monitoring Stack"
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
$NAME v$VERSION - Monitoring Stack Management

Usage: $0 [COMMAND] [OPTIONS]

SERVICES:
    start                Start monitoring stack
    stop                 Stop monitoring stack
    restart              Restart monitoring stack
    status               Show service status

PROMETHEUS:
    prom-status          Prometheus status
    prom-targets         Show targets
    prom-alerts         Show alerts

GRAFANA:
    grafana-status       Grafana status
    grafana-dashboards   List dashboards

LOGS:
    prom-logs            Show Prometheus logs
    grafana-logs         Show Grafana logs

EXAMPLES:
    $0 start
    $0 prom-targets
EOF
}

cmd_start() {
    sudo docker compose -f /etc/monitoring/docker-compose.yml up -d 2>/dev/null || \
    sudo systemctl start prometheus || \
    sudo systemctl start grafana-server
    log "Monitoring stack started"
}

cmd_stop() {
    sudo docker compose -f /etc/monitoring/docker-compose.yml down 2>/dev/null || \
    sudo systemctl stop prometheus || \
    sudo systemctl stop grafana-server
    log "Monitoring stack stopped"
}

cmd_restart() {
    cmd_stop
    cmd_start
}

cmd_status() {
    echo -e "${BLUE}=== Prometheus ===${NC}"
    sudo systemctl status prometheus --no-pager 2>/dev/null || echo "Prometheus not running"
    echo ""
    echo -e "${BLUE}=== Grafana ===${NC}"
    sudo systemctl status grafana-server --no-pager 2>/dev/null || echo "Grafana not running"
}

cmd_prom_status() {
    curl -s http://localhost:9090/api/v1/status/config | jq . 2>/dev/null || \
        echo "Prometheus not available"
}

cmd_prom_targets() {
    curl -s http://localhost:9090/api/v1/targets | jq . 2>/dev/null || \
        echo "Prometheus not available"
}

cmd_prom_alerts() {
    curl -s http://localhost:9090/api/v1/alerts | jq . 2>/dev/null || \
        echo "Prometheus not available"
}

cmd_grafana_status() {
    sudo systemctl status grafana-server --no-pager 2>/dev/null || echo "Grafana not running"
}

cmd_grafana_dashboards() {
    curl -s -u admin:admin http://localhost:3000/api/search | jq . 2>/dev/null || \
        echo "Grafana not available"
}

cmd_prom_logs() {
    sudo journalctl -u prometheus -n 50 --no-pager
}

cmd_grafana_logs() {
    sudo journalctl -u grafana-server -n 50 --no-pager
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        start) cmd_start ;;
        stop) cmd_stop ;;
        restart) cmd_restart ;;
        status) cmd_status ;;
        prom-status) cmd_prom_status ;;
        prom-targets) cmd_prom_targets ;;
        prom-alerts) cmd_prom_alerts ;;
        grafana-status) cmd_grafana_status ;;
        grafana-dashboards) cmd_grafana_dashboards ;;
        prom-logs) cmd_prom_logs ;;
        grafana-logs) cmd_grafana_logs ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
