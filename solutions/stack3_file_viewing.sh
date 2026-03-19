#!/bin/bash
# Stack 3 Solution: File Viewing & Editing - File Viewer

set -euo pipefail

NAME="File Viewer"
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
$NAME v$VERSION - File Viewing & Editing Tool

Usage: $0 [COMMAND] [OPTIONS]

VIEW:
    cat FILE             Display file contents
    head FILE [LINES]   Show first lines
    tail FILE [LINES]   Show last lines
    lines FILE          Count lines in file
    words FILE          Count words

SEARCH:
    grep PATTERN FILE   Search pattern
    find PATTERN FILE   Find matching lines

EDIT:
    replace OLD NEW FILE  Replace text in file

EXAMPLES:
    $0 cat /etc/passwd
    $0 head /var/log/syslog 20
    $0 grep error /var/log/syslog
EOF
}

cmd_cat() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        error "File not found: $file"
        exit 1
    fi
    
    cat "$file"
}

cmd_head() {
    local file=$1
    local lines=${2:-10}
    
    head -n "$lines" "$file"
}

cmd_tail() {
    local file=$1
    local lines=${2:-10}
    
    tail -n "$lines" "$file"
}

cmd_lines() {
    local file=$1
    
    wc -l < "$file"
}

cmd_words() {
    local file=$1
    
    wc -w < "$file"
}

cmd_grep() {
    local pattern=$1
    local file=$2
    
    grep -n "$pattern" "$file"
}

cmd_find() {
    local pattern=$1
    local file=$2
    
    grep -n "$pattern" "$file"
}

cmd_replace() {
    local old=$1
    local new=$2
    local file=$3
    
    sed -i "s/$old/$new/g" "$file"
    log "Replaced '$old' with '$new' in $file"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        cat) cmd_cat "$1" ;;
        head) cmd_head "$1" "${2:-10}" ;;
        tail) cmd_tail "$1" "${2:-10}" ;;
        lines) cmd_lines "$1" ;;
        words) cmd_words "$1" ;;
        grep) cmd_grep "$1" "$2" ;;
        find) cmd_find "$1" "$2" ;;
        replace) cmd_replace "$1" "$2" "$3" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
