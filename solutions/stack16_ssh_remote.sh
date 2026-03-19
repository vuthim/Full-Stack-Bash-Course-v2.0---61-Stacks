#!/bin/bash
# Stack 16 Solution: SSH & Remote Management - SSH Tool

set -euo pipefail

NAME="SSH Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

show_usage() {
    cat << EOF
$NAME v$VERSION - SSH & Remote Management

Usage: $0 [COMMAND] [OPTIONS]

CONNECT:
    connect HOST           Connect to host
    exec HOST CMD           Execute command on remote
    scp-local HOST FILE    Copy file to remote
    scp-remote HOST FILE    Copy file from remote
    sftp HOST              Start SFTP session

KEY MANAGEMENT:
    keygen [COMMENT]       Generate SSH key
    key-list               List SSH keys
    pubkey KEY             Show public key
    copy-id HOST USER      Copy key to server

CONFIG:
    config-add HOST USER [PORT]    Add SSH config entry
    config-list                    List SSH config
    config-rm HOST                 Remove config entry

TUNNEL:
    tunnel LOCAL PORT HOST RPORT   Create SSH tunnel
    tunnel-local HOST PORT         Local port forwarding
    tunnel-remote HOST PORT        Remote port forwarding

EXAMPLES:
    $0 connect server1
    $0 exec server1 "df -h"
    $0 scp-local server1 /path/file.tar
    $0 keygen "mykey@host"
    $0 copy-id server1 root
    $0 config-add server1 root 22
EOF
}

cmd_connect() {
    local host=$1
    ssh "$host"
}

cmd_exec() {
    local host=$1
    shift
    ssh "$host" "$@"
}

cmd_scp_local() {
    local host=$1
    local file=$2
    scp "$file" "$host:/tmp/"
    log "Copied $file to $host:/tmp/"
}

cmd_scp_remote() {
    local host=$1
    local file=$2
    scp "$host:$file" ./
    log "Copied $file from $host"
}

cmd_sftp() {
    local host=$1
    sftp "$host"
}

cmd_keygen() {
    local comment=${1:-"$USER@$(hostname)"}
    local key_path="$SSH_DIR/id_ed25519"
    
    if [ -f "$key_path" ]; then
        error "Key already exists at $key_path"
        exit 1
    fi
    
    ssh-keygen -t ed25519 -C "$comment" -f "$key_path"
    chmod 600 "$key_path"
    chmod 644 "${key_path}.pub"
    log "Generated key: $key_path"
}

cmd_key_list() {
    echo -e "${BLUE}=== SSH Keys ===${NC}"
    ls -la "$SSH_DIR"/id_* 2>/dev/null || echo "No keys found"
}

cmd_pubkey() {
    local key=$1
    if [ -f "${SSH_DIR}/${key}.pub" ]; then
        cat "${SSH_DIR}/${key}.pub"
    elif [ -f "${key}.pub" ]; then
        cat "${key}.pub"
    else
        error "Public key not found"
    fi
}

cmd_copy_id() {
    local host=$1
    local user=${2:-$USER}
    
    if [ ! -f "$SSH_DIR/id_ed25519.pub" ]; then
        error "No public key found. Generate one first."
        exit 1
    fi
    
    ssh-copy-id -i "$SSH_DIR/id_ed25519.pub" "${user}@${host}"
    log "Key copied to $host"
}

cmd_config_add() {
    local host=$1
    local user=$2
    local port=${3:-22}
    
    cat >> "$CONFIG_FILE" << EOF

Host $host
    HostName $host
    User $user
    Port $port
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
    ServerAliveInterval 60
EOF
    
    chmod 600 "$CONFIG_FILE"
    log "Added config for $host"
}

cmd_config_list() {
    echo -e "${BLUE}=== SSH Config ===${NC}"
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    else
        echo "No config file found"
    fi
}

cmd_config_rm() {
    local host=$1
    
    if [ -f "$CONFIG_FILE" ]; then
        sed -i "/^Host $host$/,/^$/d" "$CONFIG_FILE"
        log "Removed config for $host"
    fi
}

cmd_tunnel() {
    local local_port=$1
    local host=$2
    local remote_port=$3
    
    log "Creating tunnel: localhost:$local_port -> $host:$remote_port"
    ssh -L "$local_port:localhost:$remote_port" "$host"
}

cmd_tunnel_local() {
    local host=$1
    local port=$2
    
    log "Creating local forward: localhost:$port -> $host:$port"
    ssh -L "$port:localhost:$port" "$host"
}

cmd_tunnel_remote() {
    local host=$1
    local port=$2
    
    log "Creating remote forward: $host:$port -> localhost:$port"
    ssh -R "$port:localhost:$port" "$host"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        connect) cmd_connect "$1" ;;
        exec) cmd_exec "$1" "${@:2}" ;;
        scp-local) cmd_scp_local "$1" "$2" ;;
        scp-remote) cmd_scp_remote "$1" "$2" ;;
        sftp) cmd_sftp "$1" ;;
        keygen) cmd_keygen "${1:-}" ;;
        key-list) cmd_key_list ;;
        pubkey) cmd_pubkey "$1" ;;
        copy-id) cmd_copy_id "$1" "${2:-}" ;;
        config-add) cmd_config_add "$1" "$2" "${3:-}" ;;
        config-list) cmd_config_list ;;
        config-rm) cmd_config_rm "$1" ;;
        tunnel) cmd_tunnel "$1" "$2" "$3" ;;
        tunnel-local) cmd_tunnel_local "$1" "$2" ;;
        tunnel-remote) cmd_tunnel_remote "$1" "$2" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
