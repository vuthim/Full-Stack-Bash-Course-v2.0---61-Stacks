#!/bin/bash
# Stack 43 Solution: Windows WSL - WSL Manager

set -euo pipefail

NAME="WSL Manager"
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
$NAME v$VERSION - Windows Subsystem for Linux Manager

Usage: $0 [COMMAND] [OPTIONS]

LIST:
    list                 List installed distros
    running              List running distros

MANAGE:
    start DISTRO         Start distribution
    stop DISTRO          Stop distribution
    restart DISTRO       Restart distribution

INSTALL:
    install DISTRO        Install new distribution
    update               Update WSL

CONFIG:
    set-default DISTRO   Set default distro

EXAMPLES:
    $0 list
    $0 start Ubuntu
EOF
}

cmd_list() {
    wsl --list --verbose
}

cmd_running() {
    wsl --list --running
}

cmd_start() {
    local distro=$1
    wsl -d "$distro"
}

cmd_stop() {
    local distro=$1
    wsl -t "$distro"
}

cmd_restart() {
    local distro=$1
    wsl -t "$distro"
    wsl -d "$distro"
}

cmd_install() {
    local distro=$1
    wsl --install -d "$distro"
}

cmd_update() {
    wsl --update
}

cmd_set_default() {
    local distro=$1
    wsl --set-default "$distro"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        list) cmd_list ;;
        running) cmd_running ;;
        start) cmd_start "$1" ;;
        stop) cmd_stop "$1" ;;
        restart) cmd_restart "$1" ;;
        install) cmd_install "$1" ;;
        update) cmd_update ;;
        set-default) cmd_set_default "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
