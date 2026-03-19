#!/bin/bash
# Stack 25 Solution: Zsh Essentials - Zsh Config Manager

set -euo pipefail

NAME="Zsh Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ZSH_DIR="$HOME/.oh-my-zsh"
ZSHRC="$HOME/.zshrc"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Zsh Configuration Manager

Usage: $0 [COMMAND] [OPTIONS]

INSTALL:
    install              Install Oh My Zsh
    install-plugins      Install popular plugins

CONFIG:
    theme [NAME]        Set or show theme
    plugin-add NAME     Add a plugin
    plugin-remove NAME  Remove a plugin

ALIASES:
    aliases              Show custom aliases
    alias-add NAME CMD   Add custom alias

EXAMPLES:
    $0 install
    $0 theme powerlevel10k
    $0 plugin-add zsh-autosuggestions
EOF
}

cmd_install() {
    if [ -d "$ZSH_DIR" ]; then
        log "Oh My Zsh already installed"
        return
    fi
    
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log "Oh My Zsh installed"
}

cmd_install_plugins() {
    local plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "zsh-completions"
    )
    
    for plugin in "${plugins[@]}"; do
        if [ ! -d "$ZSH_DIR/custom/plugins/$plugin" ]; then
            log "Installing $plugin..."
            git clone "https://github.com/zsh-users/$plugin.git" "$ZSH_DIR/custom/plugins/$plugin"
        fi
    done
    
    log "Plugins installed"
}

cmd_theme() {
    local theme=${1:-}
    
    if [ -z "$theme" ]; then
        grep "^ZSH_THEME" "$ZSHRC" 2>/dev/null || echo "No theme set"
        return
    fi
    
    if grep -q "^ZSH_THEME=" "$ZSHRC"; then
        sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"$theme\"/" "$ZSHRC"
    else
        echo "ZSH_THEME=\"$theme\"" >> "$ZSHRC"
    fi
    
    log "Theme set to: $theme"
}

cmd_plugin_add() {
    local plugin=$1
    
    if ! grep -q "plugins=(" "$ZSHRC"; then
        echo "plugins=(git)" >> "$ZSHRC"
    fi
    
    sed -i "s/plugins=(\(.*\))/plugins=(\1 $plugin)/" "$ZSHRC"
    log "Added plugin: $plugin"
}

cmd_plugin_remove() {
    local plugin=$1
    
    sed -i "s/ $plugin//" "$ZSHRC"
    log "Removed plugin: $plugin"
}

cmd_aliases() {
    echo -e "${BLUE}=== Custom Aliases ===${NC}"
    grep "^alias " "$ZSHRC" 2>/dev/null || echo "No custom aliases"
}

cmd_alias_add() {
    local name=$1
    local cmd=$2
    
    echo "alias $name='$cmd'" >> "$ZSHRC"
    log "Added alias: $name"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        install) cmd_install ;;
        install-plugins) cmd_install_plugins ;;
        theme) cmd_theme "${1:-}" ;;
        plugin-add) cmd_plugin_add "$1" ;;
        plugin-remove) cmd_plugin_remove "$1" ;;
        aliases) cmd_aliases ;;
        alias-add) cmd_alias_add "$1" "$2" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
