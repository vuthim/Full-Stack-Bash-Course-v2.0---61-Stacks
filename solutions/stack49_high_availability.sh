#!/bin/bash
# Stack 49 Solution: High Availability - HA Manager

set -euo pipefail

NAME="High Availability Manager"
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
$NAME v$VERSION - High Availability Management

Usage: $0 [COMMAND] [OPTIONS]

CLUSTER:
    status               Show cluster status
    nodes                List cluster nodes
    resources            List resources

MANAGE:
    start RESOURCE       Start resource
    stop RESOURCE        Stop resource
    migrate RESOURCE NODE Migrate resource

COROSYNC:
    corosync-status      Show Corosync status
    pcs-status           Show PCS status

EXAMPLES:
    $0 status
    $0 resources
EOF
}

cmd_status() {
    if command -v pcs &>/dev/null; then
        pcs status
    elif command -v crm_mon &>/dev/null; then
        crm_mon -1
    else
        echo "Cluster tools not available"
    fi
}

cmd_nodes() {
    if command -v pcs &>/dev/null; then
        pcs status nodes
    else
        echo "Cluster tools not available"
    fi
}

cmd_resources() {
    if command -v pcs &>/dev/null; then
        pcs status resources
    else
        echo "Cluster tools not available"
    fi
}

cmd_start() {
    local resource=$1
    pcs resource start "$resource"
    log "Started resource: $resource"
}

cmd_stop() {
    local resource=$1
    pcs resource stop "$resource"
    log "Stopped resource: $resource"
}

cmd_migrate() {
    local resource=$1
    local node=$2
    pcs resource move "$resource" "$node"
    log "Migrated $resource to $node"
}

cmd_corosync_status() {
    corosync-cmapctl 2>/dev/null || corosync-quorumtool
}

cmd_pcs_status() {
    pcs status
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        status) cmd_status ;;
        nodes) cmd_nodes ;;
        resources) cmd_resources ;;
        start) cmd_start "$1" ;;
        stop) cmd_stop "$1" ;;
        migrate) cmd_migrate "$1" "$2" ;;
        corosync-status) cmd_corosync_status ;;
        pcs-status) cmd_pcs_status ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
