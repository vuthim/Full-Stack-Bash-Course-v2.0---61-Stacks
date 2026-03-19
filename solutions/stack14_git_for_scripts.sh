#!/bin/bash
# Stack 14 Solution: Git for Scripters - Git Management Tool

set -euo pipefail

NAME="Git Script Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_DIR="$HOME/git_repos"
mkdir -p "$REPO_DIR"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Git Repository Management

Usage: $0 [COMMAND] [OPTIONS]

COMMANDS:
    init NAME              Initialize a new Git repository
    clone URL [DIR]        Clone a repository
    status                 Show repository status
    log [n]                Show recent commits
    branch                 List branches
    branch-create NAME     Create new branch
    branch-delete NAME      Delete branch
    checkout BRANCH        Switch to branch
    commit "MESSAGE"       Commit changes
    push                   Push to remote
    pull                   Pull from remote
    stash                 Stash changes
    stash-pop              Apply stashed changes
    diff                   Show changes
    rollback [n]           Rollback n commits
    tag TAG                Create tag
    clean                  Clean untracked files

EXAMPLES:
    $0 init myproject
    $0 clone https://github.com/user/repo
    $0 status
EOF
}

is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

cmd_init() {
    local name=$1
    local repo_path="$REPO_DIR/$name"
    
    if [ -d "$repo_path" ]; then
        error "Repository '$name' already exists"
        exit 1
    fi
    
    mkdir -p "$repo_path"
    cd "$repo_path"
    git init
    git config user.email "developer@local"
    git config user.name "Developer"
    
    cat > README.md << EOF
# $name

Created: $(date)
EOF
    
    git add .
    git commit -m "Initial commit"
    log "Initialized repository: $name"
}

cmd_clone() {
    local url=$1
    local dir=${2:-}
    
    if [ -z "$dir" ]; then
        dir=$(basename "$url" .git)
    fi
    
    git clone "$url" "$REPO_DIR/$dir"
    log "Cloned to: $dir"
}

cmd_status() {
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    echo -e "${BLUE}=== Git Status ===${NC}"
    git status --short
    echo ""
    echo "Branch: $(git branch --show-current)"
    echo "Commits ahead: $(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)"
    echo "Staged: $(git diff --cached --numstat | wc -l)"
    echo "Modified: $(git diff --numstat | wc -l)"
    echo "Untracked: $(git ls-files --others --exclude-standard | wc -l)"
}

cmd_log() {
    local n=${1:-10}
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git log --oneline -n "$n" --graph --decorate
}

cmd_branch() {
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    echo -e "${BLUE}=== Branches ===${NC}"
    git branch -a
}

cmd_branch_create() {
    local name=$1
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git checkout -b "$name"
    log "Created and switched to branch: $name"
}

cmd_branch_delete() {
    local name=$1
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git branch -d "$name"
    log "Deleted branch: $name"
}

cmd_checkout() {
    local branch=$1
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git checkout "$branch"
    log "Switched to branch: $branch"
}

cmd_commit() {
    local msg=$1
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git add -A
    git commit -m "$msg"
    log "Committed: $msg"
}

cmd_push() {
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git push -u origin $(git branch --show-current)
    log "Pushed to remote"
}

cmd_pull() {
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git pull
    log "Pulled from remote"
}

cmd_stash() {
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git stash
    log "Stashed changes"
}

cmd_stash_pop() {
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git stash pop
    log "Applied stashed changes"
}

cmd_diff() {
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git diff
}

cmd_rollback() {
    local n=${1:-1}
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git reset --hard "HEAD~$n"
    log "Rolled back $n commits"
}

cmd_tag() {
    local tag=$1
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git tag -a "$tag" -m "Release $tag"
    log "Created tag: $tag"
}

cmd_clean() {
    if ! is_git_repo; then
        error "Not a Git repository"
        exit 1
    fi
    
    git clean -fd
    log "Cleaned untracked files"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        init) cmd_init "$1" ;;
        clone) cmd_clone "$1" "${2:-}" ;;
        status) cmd_status ;;
        log) cmd_log "${1:-10}" ;;
        branch)
            if [ "${1:-}" = "-create" ]; then
                cmd_branch_create "$2"
            elif [ "${1:-}" = "-delete" ]; then
                cmd_branch_delete "$2"
            else
                cmd_branch
            fi ;;
        branch-create) cmd_branch_create "$1" ;;
        branch-delete) cmd_branch_delete "$1" ;;
        checkout) cmd_checkout "$1" ;;
        commit) cmd_commit "$1" ;;
        push) cmd_push ;;
        pull) cmd_pull ;;
        stash) cmd_stash ;;
        stash-pop) cmd_stash_pop ;;
        diff) cmd_diff ;;
        rollback) cmd_rollback "${1:-1}" ;;
        tag) cmd_tag "$1" ;;
        clean) cmd_clean ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
