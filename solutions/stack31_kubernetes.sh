#!/bin/bash
# Stack 31 Solution: Kubernetes Basics - K8s Manager

set -euo pipefail

NAME="K8s Manager"
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
$NAME v$VERSION - Kubernetes Management Tool

Usage: $0 [COMMAND] [OPTIONS]

CLUSTER:
    cluster-info         Show cluster info
    nodes                List nodes
    namespaces           List namespaces

WORKLOADS:
    pods [NAMESPACE]     List pods
    deploy [NS]          List deployments
    svc [NAMESPACE]      List services

MANAGE:
    create NAME IMAGE    Create deployment
    delete NAME          Delete deployment
    scale NAME N         Scale deployment
    restart NAME         Restart deployment

LOGS:
    logs NAME            Get pod logs
    describe NAME        Describe resource

EXAMPLES:
    $0 pods
    $0 create myapp nginx
    $0 scale myapp 3
EOF
}

check_kubectl() {
    if ! command -v kubectl &>/dev/null; then
        error "kubectl not installed"
        exit 1
    fi
}

cmd_cluster_info() {
    check_kubectl
    kubectl cluster-info
}

cmd_nodes() {
    check_kubectl
    kubectl get nodes
}

cmd_namespaces() {
    check_kubectl
    kubectl get namespaces
}

cmd_pods() {
    check_kubectl
    local ns=${1:-default}
    kubectl get pods -n "$ns"
}

cmd_deploy() {
    check_kubectl
    local ns=${1:-default}
    kubectl get deployments -n "$ns"
}

cmd_svc() {
    check_kubectl
    local ns=${1:-default}
    kubectl get svc -n "$ns"
}

cmd_create() {
    check_kubectl
    local name=$1
    local image=$2
    
    kubectl create deployment "$name" --image="$image"
    log "Created deployment: $name"
}

cmd_delete() {
    check_kubectl
    local name=$1
    
    kubectl delete deployment "$name"
    log "Deleted deployment: $name"
}

cmd_scale() {
    check_kubectl
    local name=$1
    local replicas=$2
    
    kubectl scale deployment "$name" --replicas="$replicas"
    log "Scaled $name to $replicas replicas"
}

cmd_restart() {
    check_kubectl
    local name=$1
    
    kubectl rollout restart deployment/"$name"
    log "Restarted deployment: $name"
}

cmd_logs() {
    check_kubectl
    local name=$1
    
    kubectl logs deployment/"$name" --tail=50
}

cmd_describe() {
    check_kubectl
    local name=$1
    
    kubectl describe deployment "$name"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        cluster-info) cmd_cluster_info ;;
        nodes) cmd_nodes ;;
        namespaces) cmd_namespaces ;;
        pods) cmd_pods "${1:-default}" ;;
        deploy) cmd_deploy "${1:-default}" ;;
        svc) cmd_svc "${1:-default}" ;;
        create) cmd_create "$1" "$2" ;;
        delete) cmd_delete "$1" ;;
        scale) cmd_scale "$1" "$2" ;;
        restart) cmd_restart "$1" ;;
        logs) cmd_logs "$1" ;;
        describe) cmd_describe "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
