#!/bin/bash
# Stack 32 Solution: User Management - User Manager

set -euo pipefail

NAME="User Manager"
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
$NAME v$VERSION - User & Group Management

Usage: $0 [COMMAND] [OPTIONS]

USERS:
    list                 List all users
    add USER            Add new user
    del USER            Delete user
    passwd USER         Set user password
    info USER           Show user info

GROUPS:
    groups               List groups
    group-add NAME       Create group
    group-del NAME       Delete group
    group-add-user USER GRP  Add user to group

PERMISSIONS:
    sudo USER            Add to sudo group
    unsudo USER         Remove from sudo group
    lock USER           Lock account
    unlock USER         Unlock account

EXAMPLES:
    $0 add john
    $0 group-add developers
    $0 sudo john
EOF
}

cmd_list() {
    echo -e "${BLUE}=== Users ===${NC}"
    getent passwd | awk -F: '{print $1, $3, $6, $7}' | column -t
}

cmd_add() {
    local user=$1
    
    sudo useradd -m -s /bin/bash "$user"
    log "Created user: $user"
}

cmd_del() {
    local user=$1
    
    sudo userdel -r "$user"
    log "Deleted user: $user"
}

cmd_passwd() {
    local user=$1
    
    sudo passwd "$user"
}

cmd_info() {
    local user=$1
    
    id "$user"
    getent passwd "$user"
}

cmd_groups() {
    echo -e "${BLUE}=== Groups ===${NC}"
    getent group | awk -F: '{print $1, $3, $4}' | column -t
}

cmd_group_add() {
    local group=$1
    
    sudo groupadd "$group"
    log "Created group: $group"
}

cmd_group_del() {
    local group=$1
    
    sudo groupdel "$group"
    log "Deleted group: $group"
}

cmd_group_add_user() {
    local user=$1
    local group=$2
    
    sudo usermod -aG "$group" "$user"
    log "Added $user to group $group"
}

cmd_sudo() {
    local user=$1
    
    sudo usermod -aG sudo "$user"
    log "Added $user to sudo group"
}

cmd_unsudo() {
    local user=$1
    
    sudo gpasswd -d "$user" sudo
    log "Removed $user from sudo group"
}

cmd_lock() {
    local user=$1
    
    sudo usermod -L "$user"
    log "Locked account: $user"
}

cmd_unlock() {
    local user=$1
    
    sudo usermod -U "$user"
    log "Unlocked account: $user"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        list) cmd_list ;;
        add) cmd_add "$1" ;;
        del) cmd_del "$1" ;;
        passwd) cmd_passwd "$1" ;;
        info) cmd_info "$1" ;;
        groups) cmd_groups ;;
        group-add) cmd_group_add "$1" ;;
        group-del) cmd_group_del "$1" ;;
        group-add-user) cmd_group_add_user "$1" "$2" ;;
        sudo) cmd_sudo "$1" ;;
        unsudo) cmd_unsudo "$1" ;;
        lock) cmd_lock "$1" ;;
        unlock) cmd_unlock "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
