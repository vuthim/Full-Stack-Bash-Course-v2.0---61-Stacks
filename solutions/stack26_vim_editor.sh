#!/bin/bash
# Stack 26 Solution: Vim for Scripters - Vim Config Manager

set -euo pipefail

NAME="Vim Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VIMRC="$HOME/.vimrc"
VIM_DIR="$HOME/.vim"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Vim Configuration Manager

Usage: $0 [COMMAND] [OPTIONS]

CONFIG:
    install              Install vim configuration
    update               Update vim config
    show                 Show current config

PLUGINS:
    plugin-install       Install plugins
    plugin-update        Update plugins

KEYMAPS:
    keymaps              Show custom keymaps

EXAMPLES:
    $0 install
    $0 plugin-install
EOF
}

cmd_install() {
    log "Installing Vim configuration..."
    
    cat > "$VIMRC" << 'EOF'
" Vim Configuration
syntax on
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set hlsearch
set incsearch
set wildmenu
set laststatus=2

" Leader
let mapleader = " "

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Save & quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa!<CR>

" Split
nnoremap <leader>h :split<CR>
nnoremap <leader>v :vsplit<CR>

" Plugins (vim-plug)
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
call plug#end()
EOF
    
    mkdir -p "$VIM_DIR/autoload" "$VIM_DIR/plugged"
    
    log "Vim configuration installed"
}

cmd_update() {
    if [ -f "$VIMRC" ]; then
        log "Updating vim configuration..."
        cmd_install
    else
        error "No configuration found. Run 'install' first."
    fi
}

cmd_show() {
    if [ -f "$VIMRC" ]; then
        cat "$VIMRC"
    else
        error "No configuration found"
    fi
}

cmd_plugin_install() {
    log "Installing plugins..."
    if command -v vim &>/dev/null; then
        vim +PlugInstall +qall 2>/dev/null || true
        log "Plugins installed"
    else
        error "Vim not installed"
    fi
}

cmd_plugin_update() {
    log "Updating plugins..."
    vim +PlugUpdate +qall 2>/dev/null || true
    log "Plugins updated"
}

cmd_keymaps() {
    echo -e "${BLUE}=== Custom Keymaps ===${NC}"
    grep -E "^nnoremap|^inoremap" "$VIMRC" 2>/dev/null || echo "No custom keymaps"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        install) cmd_install ;;
        update) cmd_update ;;
        show) cmd_show ;;
        plugin-install) cmd_plugin_install ;;
        plugin-update) cmd_plugin_update ;;
        keymaps) cmd_keymaps ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
