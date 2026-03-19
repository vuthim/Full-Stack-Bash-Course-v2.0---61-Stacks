#!/bin/bash
# Stack 53 Solution: Terminal UI Development - TUI Framework

set -euo pipefail

NAME="TUI Framework"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_usage() {
    cat << EOF
$NAME v$VERSION - Terminal UI Development Examples

Usage: $0 [PATTERN]

PATTERNS:
    progress-bar         Progress bar example
    spinner             Spinner example
    menu                Menu example
    table               Table example
    dialog              Dialog example

EXAMPLES:
    $0 progress-bar
EOF
}

progress_bar_example() {
    echo -n "Progress: ["
    for i in {1..50}; do
        echo -n "#"
        sleep 0.02
    done
    echo "] Done!"
}

spinner_example() {
    local delay=0.1
    local spinstr='|/-\'
    
    echo -n "Working... "
    for i in {1..20}; do
        local temp=${spinstr#?}
        printf "\b%c" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\bDone!\n"
}

menu_example() {
    echo -e "${BLUE}=== Main Menu ===${NC}"
    echo "1. Option 1"
    echo "2. Option 2"
    echo "3. Option 3"
    echo "q. Quit"
    echo ""
    read -p "Select: " choice
    
    case $choice in
        1) echo "Selected Option 1" ;;
        2) echo "Selected Option 2" ;;
        3) echo "Selected Option 3" ;;
        q) exit ;;
    esac
}

table_example() {
    printf "${BLUE}%-10s %-10s %-10s${NC}\n" "Name" "Status" "Value"
    echo "--------------------------------"
    printf "%-10s %-10s %-10s\n" "Item 1" "OK" "100"
    printf "%-10s %-10s %-10s\n" "Item 2" "FAIL" "0"
    printf "%-10s %-10s %-10s\n" "Item 3" "OK" "50"
}

dialog_example() {
    if command -v dialog &>/dev/null; then
        dialog --msgbox "Hello from TUI!" 10 30
    else
        echo "Dialog not installed - showing alternative"
        echo "=============================="
        echo "     Dialog Box"
        echo "=============================="
        echo "Hello from TUI!"
    fi
}

main() {
    local pattern=${1:-}
    
    case $pattern in
        progress-bar) progress_bar_example ;;
        spinner) spinner_example ;;
        menu) menu_example ;;
        table) table_example ;;
        dialog) dialog_example ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
