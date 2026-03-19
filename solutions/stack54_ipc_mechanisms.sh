#!/bin/bash
# Stack 54 Solution: IPC Mechanisms - Inter-Process Communication

set -euo pipefail

NAME="IPC Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - IPC Mechanism Examples

Usage: $0 [MECHANISM]

MECHANISMS:
    pipe                 Named pipe example
    signal               Signal handling example
    lock                 File locking example
    shared-memory        Shared memory example

EXAMPLES:
    $0 pipe
    $0 lock
EOF
}

pipe_example() {
    local pipe="/tmp/test_pipe_$$"
    mkfifo "$pipe"
    
    echo "Producer: Writing to pipe"
    echo "Hello from pipe" > "$pipe" &
    
    echo "Consumer: Reading from pipe"
    cat "$pipe"
    
    rm "$pipe"
}

signal_example() {
    trap 'echo "Received SIGINT"; exit' INT
    trap 'echo "Received SIGTERM"' TERM
    
    echo "Press Ctrl+C to test signal handling"
    sleep 10
}

lock_example() {
    local lockfile="/tmp/test_lock_$$"
    
    (
        flock -n 9 || { echo "Lock failed"; exit 1; }
        echo "Lock acquired"
        sleep 5
        echo "Lock released"
    ) 9>"$lockfile"
    
    rm "$lockfile"
}

shared_memory_example() {
    echo "Shared Memory Example (using /dev/shm)"
    
    local shm_file="/dev/shm/ipc_test_$$"
    echo "test data" > "$shm_file"
    
    cat "$shm_file"
    
    rm "$shm_file"
}

main() {
    local mech=${1:-}
    
    case $mech in
        pipe) pipe_example ;;
        signal) signal_example ;;
        lock) lock_example ;;
        shared-memory) shared_memory_example ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
