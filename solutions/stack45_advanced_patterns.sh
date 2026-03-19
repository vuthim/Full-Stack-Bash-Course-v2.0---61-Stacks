#!/bin/bash
# Stack 45 Solution: Advanced Patterns - Advanced Scripting Patterns

set -euo pipefail

NAME="Advanced Patterns"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Advanced Bash Patterns

Usage: $0 [PATTERN] [OPTIONS]

PATTERNS:
    state-machine        State machine example
    parser               Command parser pattern
    event-handler        Event handler pattern
    pipeline             Pipeline processor
    worker-pool          Worker pool pattern

EXAMPLES:
    $0 state-machine
    $0 worker-pool
EOF
}

state_machine_example() {
    cat << 'PATTERN'
# State Machine Pattern
STATE="idle"

handle_event() {
    local event=$1
    
    case $STATE in
        idle)
            case $event in
                start) STATE="running" ;;
            esac
            ;;
        running)
            case $event in
                stop) STATE="idle" ;;
                pause) STATE="paused" ;;
            esac
            ;;
        paused)
            case $event in
                resume) STATE="running" ;;
                stop) STATE="idle" ;;
            esac
            ;;
    esac
    
    echo "State: $STATE"
}
PATTERN
}

parser_example() {
    cat << 'PATTERN'
# Command Parser Pattern
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) help; exit ;;
            -v|--verbose) VERBOSE=1 ;;
            -f|--file) FILE="$2"; shift ;;
            *) echo "Unknown: $1" ;;
        esac
        shift
    done
}
PATTERN
}

event_handler_example() {
    cat << 'PATTERN'
# Event Handler Pattern
declare -A EVENT_HANDLERS

on() {
    local event=$1
    local handler=$2
    EVENT_HANDLERS[$event]=$handler
}

emit() {
    local event=$1
    shift
    local handler=${EVENT_HANDLERS[$event]}
    if [ -n "$handler" ]; then
        $handler "$@"
    fi
}

on "build" echo "Building..."
emit "build"
PATTERN
}

pipeline_example() {
    cat << 'PATTERN'
# Pipeline Processor
pipe_to() {
    local func=$1
    shift
    while read -r line; do
        $func "$line"
    done
}

uppercase() { echo "${1^^}"; }
lowercase() { echo "${1,,}"; }

echo "Hello World" | pipe_to uppercase
PATTERN
}

worker_pool_example() {
    cat << 'PATTERN'
# Worker Pool Pattern
WORKER_COUNT=3
TASK_QUEUE=()

submit_task() {
    TASK_QUEUE+=("$1")
}

process_tasks() {
    for task in "${TASK_QUEUE[@]}"; do
        echo "Processing: $task" &
    done
    wait
}
PATTERN
}

main() {
    local pattern=${1:-}
    
    case $pattern in
        state-machine) state_machine_example ;;
        parser) parser_example ;;
        event-handler) event_handler_example ;;
        pipeline) pipeline_example ;;
        worker-pool) worker_pool_example ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
