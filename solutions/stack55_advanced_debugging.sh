#!/bin/bash
# Stack 55 Solution: Advanced Debugging & Profiling - Debug Tools

set -euo pipefail

NAME="Debug Tools"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Advanced Debugging Tools

Usage: $0 [COMMAND] [OPTIONS]

DEBUG:
    trace SCRIPT         Trace script execution
    profile SCRIPT       Profile script
    time SCRIPT          Time script execution
    memory SCRIPT        Show memory usage

ANALYSIS:
    strace CMD           Strace command
    ltrace CMD           Ltrace command
    perf CMD             Use perf profiler

EXAMPLES:
    $0 trace ./myscript.sh
    $0 time ./myscript.sh
EOF
}

cmd_trace() {
    local script=$1
    bash -x "$script"
}

cmd_profile() {
    local script=$1
    bash -x "$script" 2>&1 | head -50
}

cmd_time() {
    shift
    time "$@"
}

cmd_memory() {
    shift
    /usr/bin/time -v "$@"
}

cmd_strace() {
    shift
    strace -c "$@"
}

cmd_ltrace() {
    shift
    ltrace -c "$@"
}

cmd_perf() {
    shift
    perf stat "$@"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        trace) cmd_trace "$1" ;;
        profile) cmd_profile "$1" ;;
        time) cmd_time "$@" ;;
        memory) cmd_memory "$@" ;;
        strace) cmd_strace "$@" ;;
        ltrace) cmd_ltrace "$@" ;;
        perf) cmd_perf "$@" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
