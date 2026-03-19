#!/bin/bash
# Stack 36 Solution: Terraform Basics - Terraform Manager

set -euo pipefail

NAME="Terraform Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TERRAFORM_DIR="$HOME/terraform"
mkdir -p "$TERRAFORM_DIR"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

check_terraform() {
    if ! command -v terraform &>/dev/null; then
        error "Terraform not installed"
        exit 1
    fi
}

show_usage() {
    cat << EOF
$NAME v$VERSION - Terraform Infrastructure Management

Usage: $0 [COMMAND] [OPTIONS]

MANAGE:
    init [DIR]           Initialize Terraform
    validate [DIR]       Validate configuration
    plan [DIR]           Create execution plan
    apply [DIR]          Apply changes
    destroy [DIR]        Destroy resources

WORKSPACES:
    workspace list       List workspaces
    workspace new NAME  Create workspace
    workspace select NAME  Switch workspace

STATE:
    state list           List resources
    state show NAME     Show resource details

EXAMPLES:
    $0 init
    $0 plan
    $0 apply
EOF
}

cmd_init() {
    local dir=${1:-.}
    
    check_terraform
    cd "$dir"
    terraform init
    log "Initialized Terraform"
}

cmd_validate() {
    local dir=${1:-.}
    
    check_terraform
    cd "$dir"
    terraform validate
}

cmd_plan() {
    local dir=${1:-.}
    
    check_terraform
    cd "$dir"
    terraform plan
}

cmd_apply() {
    local dir=${1:-.}
    
    check_terraform
    cd "$dir"
    terraform apply
}

cmd_destroy() {
    local dir=${1:-.}
    
    check_terraform
    cd "$dir"
    terraform destroy
}

cmd_workspace_list() {
    check_terraform
    terraform workspace list
}

cmd_workspace_new() {
    local name=$1
    
    check_terraform
    terraform workspace new "$name"
    log "Created workspace: $name"
}

cmd_workspace_select() {
    local name=$1
    
    check_terraform
    terraform workspace select "$name"
    log "Switched to workspace: $name"
}

cmd_state_list() {
    check_terraform
    terraform state list
}

cmd_state_show() {
    local name=$1
    
    check_terraform
    terraform state show "$name"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        init) cmd_init "${1:-.}" ;;
        validate) cmd_validate "${1:-.}" ;;
        plan) cmd_plan "${1:-.}" ;;
        apply) cmd_apply "${1:-.}" ;;
        destroy) cmd_destroy "${1:-.}" ;;
        workspace)
            case $1 in
                list) cmd_workspace_list ;;
                new) cmd_workspace_new "$2" ;;
                select) cmd_workspace_select "$2" ;;
            esac
            ;;
        state)
            case $1 in
                list) cmd_state_list ;;
                show) cmd_state_show "$2" ;;
            esac
            ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
