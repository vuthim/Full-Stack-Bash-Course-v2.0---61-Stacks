#!/bin/bash
# Stack 42 Solution: Raspberry Pi Projects - Pi Manager

set -euo pipefail

NAME="Raspberry Pi Manager"
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
$NAME v$VERSION - Raspberry Pi Project Manager

Usage: $0 [COMMAND] [OPTIONS]

SYSTEM:
    info                 Show Pi info
    temp                 Show temperature
    overclock            Show overclock settings

GPIO:
    gpio-read PIN        Read GPIO pin
    gpio-write PIN VAL   Write GPIO pin
    gpio-mode PIN MODE   Set pin mode

PROJECTS:
    project-list         List projects
    project-create NAME  Create project

EXAMPLES:
    $0 info
    $0 temp
EOF
}

cmd_info() {
    if [ -f /proc/device-tree/model ]; then
        echo "Model: $(cat /proc/device-tree/model)"
    else
        echo "Raspberry Pi detected"
    fi
    
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
}

cmd_temp() {
    echo "CPU Temperature:"
    vcgencmd measure_temp 2>/dev/null || cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000 "°C"}'
}

cmd_overclock() {
    echo "Current settings:"
    sudo cat /boot/config.txt | grep -E "^overclock" || echo "Default"
}

cmd_gpio_read() {
    local pin=$1
    gpio -g mode "$pin" in
    gpio -g read "$pin"
}

cmd_gpio_write() {
    local pin=$1
    local val=$2
    gpio -g mode "$pin" out
    gpio -g write "$pin" "$val"
}

cmd_gpio_mode() {
    local pin=$1
    local mode=$2
    gpio -g mode "$pin" "$mode"
}

cmd_project_list() {
    echo "Pi Projects:"
    ls -la ~/pi-projects 2>/dev/null || echo "No projects"
}

cmd_project_create() {
    local name=$1
    mkdir -p ~/pi-projects/"$name"
    log "Created project: $name"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        info) cmd_info ;;
        temp) cmd_temp ;;
        overclock) cmd_overclock ;;
        gpio-read) cmd_gpio_read "$1" ;;
        gpio-write) cmd_gpio_write "$1" "$2" ;;
        gpio-mode) cmd_gpio_mode "$1" "$2" ;;
        project-list) cmd_project_list ;;
        project-create) cmd_project_create "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
