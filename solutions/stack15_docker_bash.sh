#!/bin/bash
# Stack 15 Solution: Docker & Bash - Container Management

set -euo pipefail

NAME="Docker Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Docker Container Management

Usage: $0 [COMMAND] [OPTIONS]

CONTAINERS:
    ps              List running containers
    ps-all          List all containers
    start NAME      Start a container
    stop NAME       Stop a container
    restart NAME    Restart a container
    remove NAME     Remove a container
    logs NAME       View container logs
    exec NAME CMD   Execute command in container
    stats           Show container stats

IMAGES:
    images          List images
    pull IMAGE      Pull an image
    remove-img IMG Remove an image
    rmi-dangling   Remove dangling images

NETWORKS:
    net-list        List networks
    net-create NAME Create network
    net-rm NAME     Remove network

VOLUMES:
    vol-list        List volumes
    vol-create NAME Create volume
    vol-rm NAME     Remove volume

BUILD:
    build FILE      Build image from Dockerfile
    prune           Clean up unused resources

EXAMPLES:
    $0 ps
    $0 start myapp
    $0 exec myapp ls /app
    $0 build ./Dockerfile -t myapp:latest
EOF
}

cmd_ps() {
    echo -e "${BLUE}=== Running Containers ===${NC}"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
}

cmd_ps_all() {
    echo -e "${BLUE}=== All Containers ===${NC}"
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"
}

cmd_start() {
    local name=$1
    docker start "$name"
    log "Started container: $name"
}

cmd_stop() {
    local name=$1
    docker stop "$name"
    log "Stopped container: $name"
}

cmd_restart() {
    local name=$1
    docker restart "$name"
    log "Restarted container: $name"
}

cmd_remove() {
    local name=$1
    docker rm -f "$name"
    log "Removed container: $name"
}

cmd_logs() {
    local name=$1
    local lines=${2:-50}
    docker logs --tail "$lines" "$name"
}

cmd_exec() {
    local name=$1
    shift
    docker exec -it "$name" "$@"
}

cmd_stats() {
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

cmd_images() {
    echo -e "${BLUE}=== Docker Images ===${NC}"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
}

cmd_pull() {
    local image=$1
    docker pull "$image"
    log "Pulled image: $image"
}

cmd_remove_img() {
    local image=$1
    docker rmi "$image"
    log "Removed image: $image"
}

cmd_rmi_dangling() {
    docker image prune -f
    log "Removed dangling images"
}

cmd_net_list() {
    echo -e "${BLUE}=== Networks ===${NC}"
    docker network ls
}

cmd_net_create() {
    local name=$1
    docker network create "$name"
    log "Created network: $name"
}

cmd_net_rm() {
    local name=$1
    docker network rm "$name"
    log "Removed network: $name"
}

cmd_vol_list() {
    echo -e "${BLUE}=== Volumes ===${NC}"
    docker volume ls
}

cmd_vol_create() {
    local name=$1
    docker volume create "$name"
    log "Created volume: $name"
}

cmd_vol_rm() {
    local name=$1
    docker volume rm "$name"
    log "Removed volume: $name"
}

cmd_build() {
    local dockerfile=${1:-./Dockerfile}
    local tag=${2:-latest}
    docker build -t "$tag" -f "$dockerfile" .
    log "Built image: $tag"
}

cmd_prune() {
    docker system prune -af
    log "Cleaned up unused resources"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        ps) cmd_ps ;;
        ps-all) cmd_ps_all ;;
        start) cmd_start "$1" ;;
        stop) cmd_stop "$1" ;;
        restart) cmd_restart "$1" ;;
        remove|rm) cmd_remove "$1" ;;
        logs) cmd_logs "$1" "${2:-50}" ;;
        exec) cmd_exec "$@" ;;
        stats) cmd_stats ;;
        images|img) cmd_images ;;
        pull) cmd_pull "$1" ;;
        remove-img) cmd_remove_img "$1" ;;
        rmi-dangling) cmd_rmi_dangling ;;
        net-list) cmd_net_list ;;
        net-create) cmd_net_create "$1" ;;
        net-rm) cmd_net_rm "$1" ;;
        vol-list) cmd_vol_list ;;
        vol-create) cmd_vol_create "$1" ;;
        vol-rm) cmd_vol_rm "$1" ;;
        build) cmd_build "$1" "${2:-}" ;;
        prune) cmd_prune ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
