#!/bin/bash
# Stack 28 Solution: Package Management - Package Manager

set -euo pipefail

NAME="Package Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

PKG_MGR=$(detect_pkg_manager)

show_usage() {
    cat << EOF
$NAME v$VERSION - Package Management Tool
Detected: $PKG_MGR

Usage: $0 [COMMAND] [OPTIONS]

PACKAGES:
    install PKG         Install package
    remove PKG          Remove package
    update              Update package lists
    upgrade             Upgrade all packages
    search TERM         Search for package
    info PKG            Show package info

SYSTEM:
    clean                Clean package cache
    autoremove          Remove unused packages
    list                List installed packages
    list-updates        List packages with updates

EXAMPLES:
    $0 install nginx
    $0 search python
    $0 update
EOF
}

cmd_install() {
    local pkg=$1
    
    case $PKG_MGR in
        apt)    sudo apt install -y "$pkg" ;;
        yum)    sudo yum install -y "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        zypper) sudo zypper install -y "$pkg" ;;
        *)      error "Unknown package manager" ;;
    esac
    
    log "Installed: $pkg"
}

cmd_remove() {
    local pkg=$1
    
    case $PKG_MGR in
        apt)    sudo apt remove -y "$pkg" ;;
        yum)    sudo yum remove -y "$pkg" ;;
        dnf)    sudo dnf remove -y "$pkg" ;;
        pacman) sudo pacman -R --noconfirm "$pkg" ;;
        zypper) sudo zypper remove -y "$pkg" ;;
        *)      error "Unknown package manager" ;;
    esac
    
    log "Removed: $pkg"
}

cmd_update() {
    case $PKG_MGR in
        apt)    sudo apt update ;;
        yum)    sudo yum check-update ;;
        dnf)    sudo dnf check-update ;;
        pacman) sudo pacman -Sy ;;
        zypper) sudo zypper refresh ;;
    esac
    
    log "Package lists updated"
}

cmd_upgrade() {
    case $PKG_MGR in
        apt)    sudo apt upgrade -y ;;
        yum)    sudo yum update -y ;;
        dnf)    sudo dnf upgrade -y ;;
        pacman) sudo pacman -Syu --noconfirm ;;
        zypper) sudo zypper update -y ;;
    esac
    
    log "System upgraded"
}

cmd_search() {
    local term=$1
    
    case $PKG_MGR in
        apt)    apt search "$term" ;;
        yum)    yum search "$term" ;;
        dnf)    dnf search "$term" ;;
        pacman) pacman -Ss "$term" ;;
        zypper) zypper search "$term" ;;
    esac
}

cmd_info() {
    local pkg=$1
    
    case $PKG_MGR in
        apt)    apt show "$pkg" ;;
        yum)    yum info "$pkg" ;;
        dnf)    dnf info "$pkg" ;;
        pacman) pacman -Qi "$pkg" ;;
        zypper) zypper info "$pkg" ;;
    esac
}

cmd_clean() {
    case $PKG_MGR in
        apt)    sudo apt clean ;;
        yum)    sudo yum clean all ;;
        dnf)    sudo dnf clean all ;;
        pacman) sudo pacman -Scc --noconfirm ;;
        zypper) sudo zypper clean ;;
    esac
    
    log "Cache cleaned"
}

cmd_autoremove() {
    case $PKG_MGR in
        apt)    sudo apt autoremove -y ;;
        yum)    sudo yum autoremove -y ;;
        dnf)    sudo dnf autoremove -y ;;
        pacman) sudo pacman -Rscn $(pacman -Qtdq 2>/dev/null) --noconfirm ;;
        zypper) sudo zypper remove --clean-deps -y ;;
    esac
    
    log "Unused packages removed"
}

cmd_list() {
    case $PKG_MGR in
        apt)    dpkg -l ;;
        yum)    rpm -qa ;;
        dnf)    rpm -qa ;;
        pacman) pacman -Q ;;
        zypper) rpm -qa ;;
    esac | head -30
}

cmd_list_updates() {
    case $PKG_MGR in
        apt)    apt list --upgradable 2>/dev/null ;;
        yum)    yum list updates ;;
        dnf)    dnf list updates ;;
        pacman) checkupdates 2>/dev/null || echo "checkupdates not installed" ;;
        zypper) zypper list-updates ;;
    esac
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        install) cmd_install "$1" ;;
        remove) cmd_remove "$1" ;;
        update) cmd_update ;;
        upgrade) cmd_upgrade ;;
        search) cmd_search "$1" ;;
        info) cmd_info "$1" ;;
        clean) cmd_clean ;;
        autoremove) cmd_autoremove ;;
        list) cmd_list ;;
        list-updates) cmd_list_updates ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
