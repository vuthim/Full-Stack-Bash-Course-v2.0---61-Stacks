#!/bin/bash
# Stack 38 Solution: Ansible Essentials - Ansible Manager

set -euo pipefail

NAME="Ansible Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ANSIBLE_DIR="$HOME/ansible"
mkdir -p "$ANSIBLE_DIR"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

check_ansible() {
    if ! command -v ansible &>/dev/null; then
        error "Ansible not installed"
        exit 1
    fi
}

show_usage() {
    cat << EOF
$NAME v$VERSION - Ansible Automation Tool

Usage: $0 [COMMAND] [OPTIONS]

PLAYBOOKS:
    list                 List available playbooks
    run PLAYBOOK         Run playbook
    check PLAYBOOK       Dry run playbook
    list-hosts           List inventory hosts

MODULE:
    ping HOST            Ping host
    command HOST CMD     Run command
    shell HOST CMD       Run shell command
    copy SRC DST         Copy file

VAULT:
    encrypt FILE         Encrypt file
    decrypt FILE         Decrypt file

EXAMPLES:
    $0 list
    $0 run site.yml
    $0 ping all
EOF
}

cmd_list() {
    echo -e "${BLUE}=== Available Playbooks ===${NC}"
    ls -la "$ANSIBLE_DIR"/*.yml 2>/dev/null || echo "No playbooks found"
}

cmd_run() {
    local playbook=$1
    
    check_ansible
    ansible-playbook "$ANSIBLE_DIR/$playbook"
    log "Ran playbook: $playbook"
}

cmd_check() {
    local playbook=$1
    
    check_ansible
    ansible-playbook --check "$ANSIBLE_DIR/$playbook"
}

cmd_list_hosts() {
    check_ansible
    ansible-inventory --list
}

cmd_ping() {
    local host=$1
    
    check_ansible
    ansible "$host" -m ping
}

cmd_command() {
    local host=$1
    shift
    local cmd="$*"
    
    check_ansible
    ansible "$host" -m command -a "$cmd"
}

cmd_shell() {
    local host=$1
    shift
    local cmd="$*"
    
    check_ansible
    ansible "$host" -m shell -a "$cmd"
}

cmd_copy() {
    local src=$1
    local dest=$2
    
    check_ansible
    ansible all -m copy -a "src=$src dest=$dest"
}

cmd_encrypt() {
    local file=$1
    
    ansible-vault encrypt "$file"
    log "Encrypted: $file"
}

cmd_decrypt() {
    local file=$1
    
    ansible-vault decrypt "$file"
    log "Decrypted: $file"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        list) cmd_list ;;
        run) cmd_run "$1" ;;
        check) cmd_check "$1" ;;
        list-hosts) cmd_list_hosts ;;
        ping) cmd_ping "$1" ;;
        command) cmd_command "$1" "${@:2}" ;;
        shell) cmd_shell "$1" "${@:2}" ;;
        copy) cmd_copy "$1" "$2" ;;
        encrypt) cmd_encrypt "$1" ;;
        decrypt) cmd_decrypt "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
