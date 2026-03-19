#!/bin/bash
# Stack 33 Solution: LVM - Logical Volume Manager

set -euo pipefail

NAME="LVM Manager"
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
$NAME v$VERSION - LVM Management Tool

Usage: $0 [COMMAND] [OPTIONS]

INFO:
    pvs                  Show physical volumes
    vgs                  Show volume groups
    lvs                  Show logical volumes
    status               Show full LVM status

CREATE:
    pv-create DEVICE     Create physical volume
    vg-create VG PVS     Create volume group
    lv-create VG NAME SIZE  Create logical volume

MANAGE:
    extend VG LV SIZE   Extend logical volume
    reduce VG LV SIZE   Reduce logical volume
    remove LV           Remove logical volume
    remove-vg VG        Remove volume group

SNAPSHOT:
    snap-create LV NAME  Create snapshot
    snap-restore LV SNAP  Restore snapshot
    snap-remove SNAP    Remove snapshot

EXAMPLES:
    $0 status
    $0 pvs
    $0 lv-create vg_data data 10G
EOF
}

cmd_pvs() {
    echo -e "${BLUE}=== Physical Volumes ===${NC}"
    sudo pvs
}

cmd_vgs() {
    echo -e "${BLUE}=== Volume Groups ===${NC}"
    sudo vgs
}

cmd_lvs() {
    echo -e "${BLUE}=== Logical Volumes ===${NC}"
    sudo lvs
}

cmd_status() {
    cmd_pvs
    echo ""
    cmd_vgs
    echo ""
    cmd_lvs
}

cmd_pv_create() {
    local device=$1
    
    sudo pvcreate "$device"
    log "Created PV: $device"
}

cmd_vg_create() {
    local vg=$1
    shift
    local pvs="$*"
    
    sudo vgcreate "$vg" $pvs
    log "Created VG: $vg"
}

cmd_lv_create() {
    local vg=$1
    local name=$2
    local size=$3
    
    sudo lvcreate -L "$size" -n "$name" "$vg"
    log "Created LV: $vg/$name"
}

cmd_extend() {
    local vg=$1
    local lv=$2
    local size=$3
    
    sudo lvextend -L +"$size" "/dev/$vg/$lv"
    sudo resize2fs "/dev/$vg/$lv"
    log "Extended LV: $vg/$lv"
}

cmd_reduce() {
    local vg=$1
    local lv=$2
    local size=$3
    
    sudo umount "/dev/$vg/$lv"
    sudo e2fsck -f "/dev/$vg/$lv"
    sudo lvreduce -L -"$size" "/dev/$vg/$lv"
    sudo resize2fs "/dev/$vg/$lv"
    log "Reduced LV: $vg/$lv"
}

cmd_remove() {
    local vg=$1
    local lv=$2
    
    sudo lvremove "/dev/$vg/$lv"
    log "Removed LV: $vg/$lv"
}

cmd_remove_vg() {
    local vg=$1
    
    sudo vgremove "$vg"
    log "Removed VG: $vg"
}

cmd_snap_create() {
    local lv=$1
    local name=$2
    
    sudo lvcreate -s -n "$name" -L 1G "/dev/$lv"
    log "Created snapshot: $name"
}

cmd_snap_restore() {
    local lv=$1
    local snap=$2
    
    sudo lvconvert --merge "$snap"
    log "Restored from snapshot: $snap"
}

cmd_snap_remove() {
    local snap=$1
    
    sudo lvremove "$snap"
    log "Removed snapshot: $snap"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        pvs) cmd_pvs ;;
        vgs) cmd_vgs ;;
        lvs) cmd_lvs ;;
        status) cmd_status ;;
        pv-create) cmd_pv_create "$1" ;;
        vg-create) cmd_vg_create "$1" "${@:2}" ;;
        lv-create) cmd_lv_create "$1" "$2" "$3" ;;
        extend) cmd_extend "$1" "$2" "$3" ;;
        reduce) cmd_reduce "$1" "$2" "$3" ;;
        remove) cmd_remove "$1" "$2" ;;
        remove-vg) cmd_remove_vg "$1" ;;
        snap-create) cmd_snap_create "$1" "$2" ;;
        snap-restore) cmd_snap_restore "$1" "$2" ;;
        snap-remove) cmd_snap_remove "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
