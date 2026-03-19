#!/bin/bash
# Stack 44 Solution: ShellCheck - Code Quality Checker

set -euo pipefail

NAME="ShellCheck Runner"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

check_shellcheck() {
    if ! command -v shellcheck &>/dev/null; then
        error "ShellCheck not installed"
        exit 1
    fi
}

show_usage() {
    cat << EOF
$NAME v$VERSION - ShellCheck Code Quality

Usage: $0 [COMMAND] [OPTIONS]

CHECK:
    check FILE           Check script
    check-all DIR       Check all scripts in directory
    format FILE         Format script

INSTALL:
    install              Install ShellCheck

EXAMPLES:
    $0 check myscript.sh
    $0 check-all ./scripts
EOF
}

cmd_check() {
    local file=$1
    
    check_shellcheck
    
    if [ ! -f "$file" ]; then
        error "File not found: $file"
        exit 1
    fi
    
    shellcheck "$file"
    
    if [ $? -eq 0 ]; then
        log "No issues found in $file"
    else
        warn "Issues found in $file"
    fi
}

cmd_check_all() {
    local dir=${1:-.}
    
    check_shellcheck
    
    find "$dir" -name "*.sh" -type f | while read -r file; do
        echo -e "${BLUE}=== Checking: $file ===${NC}"
        shellcheck "$file" || true
    done
}

cmd_format() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        error "File not found: $file"
        exit 1
    fi
    
    bashfmt "$file" 2>/dev/null || shfmt -w "$file"
    log "Formatted: $file"
}

cmd_install() {
    if command -v apt &>/dev/null; then
        sudo apt install -y shellcheck
    elif command -v brew &>/dev/null; then
        brew install shellcheck
    else
        error "Install ShellCheck manually"
    fi
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        check) cmd_check "$1" ;;
        check-all) cmd_check_all "${1:-.}" ;;
        format) cmd_format "$1" ;;
        install) cmd_install ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
