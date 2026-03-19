#!/bin/bash
# Stack 34 Solution: Network File Systems - NFS & Samba

set -euo pipefail

NAME="NFS & Samba Manager"
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
$NAME v$VERSION - Network File Systems Management

Usage: $0 [COMMAND] [OPTIONS]

NFS SERVER:
    nfs-start            Start NFS server
    nfs-stop             Stop NFS server
    nfs-status           Show NFS status
    nfs-export DIR       Export directory
    nfs-show             Show exports

NFS CLIENT:
    nfs-mount HOST:DIR   Mount NFS share
    nfs-umount           Unmount NFS share

SAMBA:
    smb-start            Start Samba
    smb-stop             Stop Samba
    smb-users            List Samba users
    smb-adduser USER     Add Samba user

SHARES:
    smb-share-add NAME PATH  Add SMB share

EXAMPLES:
    $0 nfs-export /data
    $0 nfs-mount server:/share /mnt
    $0 smb-adduser john
EOF
}

cmd_nfs_start() {
    sudo systemctl start nfs-server
    log "NFS server started"
}

cmd_nfs_stop() {
    sudo systemctl stop nfs-server
    log "NFS server stopped"
}

cmd_nfs_status() {
    sudo systemctl status nfs-server --no-pager
}

cmd_nfs_export() {
    local dir=$1
    
    if [ ! -d "$dir" ]; then
        sudo mkdir -p "$dir"
    fi
    
    echo "$dir *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
    sudo exportfs -a
    log "Exported: $dir"
}

cmd_nfs_show() {
    showmount -e localhost 2>/dev/null || sudo exportfs -v
}

cmd_nfs_mount() {
    local host_dir=$1
    local mount_point=$2
    
    sudo mkdir -p "$mount_point"
    sudo mount "$host_dir" "$mount_point"
    log "Mounted: $host_dir -> $mount_point"
}

cmd_nfs_umount() {
    local mount_point=$1
    
    sudo umount "$mount_point"
    log "Unmounted: $mount_point"
}

cmd_smb_start() {
    sudo systemctl start smbd
    log "Samba started"
}

cmd_smb_stop() {
    sudo systemctl stop smbd
    log "Samba stopped"
}

cmd_smb_users() {
    sudo pdbedit -L 2>/dev/null || echo "No Samba users"
}

cmd_smb_adduser() {
    local user=$1
    
    sudo smbpasswd -a "$user"
    sudo smbpasswd -e "$user"
    log "Added Samba user: $user"
}

cmd_smb_share_add() {
    local name=$1
    local path=$2
    
    if [ ! -d "$path" ]; then
        sudo mkdir -p "$path"
    fi
    
    cat >> /etc/samba/smb.conf << EOF

[$name]
   path = $path
   browsable = yes
   writable = yes
   guest ok = no
EOF
    
    sudo systemctl restart smbd
    log "Added SMB share: $name"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        nfs-start) cmd_nfs_start ;;
        nfs-stop) cmd_nfs_stop ;;
        nfs-status) cmd_nfs_status ;;
        nfs-export) cmd_nfs_export "$1" ;;
        nfs-show) cmd_nfs_show ;;
        nfs-mount) cmd_nfs_mount "$1" "$2" ;;
        nfs-umount) cmd_nfs_umount "$1" ;;
        smb-start) cmd_smb_start ;;
        smb-stop) cmd_smb_stop ;;
        smb-users) cmd_smb_users ;;
        smb-adduser) cmd_smb_adduser "$1" ;;
        smb-share-add) cmd_smb_share_add "$1" "$2" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
