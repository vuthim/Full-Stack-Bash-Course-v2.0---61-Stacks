#!/bin/bash
# Stack 47 Solution: Advanced Git - Git Workflows

set -euo pipefail

NAME="Advanced Git"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Advanced Git Workflows

Usage: $0 [COMMAND] [OPTIONS]

WORKFLOW:
    rebase-main          Rebase on main branch
    cherry-pick HASH     Cherry-pick commit
    bisect-start         Start bisect
    bisect-good          Mark as good
    bisect-bad           Mark as bad

CLEANUP:
    prune                Prune remote refs
    cleanup-branches     Delete merged branches

HISTORY:
    graph                Show git graph
    contributions        Show contributions

EXAMPLES:
    $0 rebase-main
    $0 bisect-start
EOF
}

cmd_rebase_main() {
    local main=${1:-main}
    
    git fetch origin
    git rebase origin/"$main"
    log "Rebased on $main"
}

cmd_cherry_pick() {
    local hash=$1
    git cherry-pick "$hash"
    log "Cherry-picked: $hash"
}

cmd_bisect_start() {
    local commit=${1:-HEAD}
    git bisect start "$commit"
    log "Bisect started"
}

cmd_bisect_good() {
    git bisect good
    log "Marked as good"
}

cmd_bisect_bad() {
    git bisect bad
    log "Marked as bad"
}

cmd_prune() {
    git remote prune origin
    log "Pruned remote refs"
}

cmd_cleanup_branches() {
    local merged=$(git branch --merged main | grep -v main)
    
    if [ -n "$merged" ]; then
        echo "$merged" | xargs git branch -d
        log "Cleaned merged branches"
    else
        log "No merged branches to clean"
    fi
}

cmd_graph() {
    git log --oneline --graph --all -n 20
}

cmd_contributions() {
    git shortlog -sn --all
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        rebase-main) cmd_rebase_main "${1:-main}" ;;
        cherry-pick) cmd_cherry_pick "$1" ;;
        bisect-start) cmd_bisect_start "${1:-HEAD}" ;;
        bisect-good) cmd_bisect_good ;;
        bisect-bad) cmd_bisect_bad ;;
        prune) cmd_prune ;;
        cleanup-branches) cmd_cleanup_branches ;;
        graph) cmd_graph ;;
        contributions) cmd_contributions ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
