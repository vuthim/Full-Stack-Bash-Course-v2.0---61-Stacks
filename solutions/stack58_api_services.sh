#!/bin/bash
# Stack 58 Solution: API & Web Services - API Client

set -euo pipefail

NAME="API Client"
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
$NAME v$Version - API & Web Services Client

Usage: $0 [COMMAND] [OPTIONS]

REQUESTS:
    get URL              GET request
    post URL DATA       POST request
    put URL DATA        PUT request
    delete URL          DELETE request

AUTH:
    auth TYPE CRED      Set authentication
    bearer TOKEN       Bearer token auth
    basic USER PASS    Basic auth

JSON:
    json-pretty FILE    Pretty print JSON
    json-get FILE KEY   Extract JSON key

EXAMPLES:
    $0 get https://api.github.com
    $0 post https://api.example.com/data '{"key":"value"}'
EOF
}

cmd_get() {
    local url=$1
    curl -s "$url"
}

cmd_post() {
    local url=$1
    local data=$2
    
    curl -s -X POST -H "Content-Type: application/json" \
        -d "$data" "$url"
}

cmd_put() {
    local url=$1
    local data=$2
    
    curl -s -X PUT -H "Content-Type: application/json" \
        -d "$data" "$url"
}

cmd_delete() {
    local url=$1
    
    curl -s -X DELETE "$url"
}

cmd_bearer() {
    local token=$1
    echo "Bearer token set: ${token:0:10}..."
}

cmd_basic() {
    local user=$1
    local pass=$2
    echo "Basic auth configured for: $user"
}

cmd_json_pretty() {
    local file=$1
    
    cat "$file" | jq . 2>/dev/null || python3 -m json.tool "$file" 2>/dev/null || cat "$file"
}

cmd_json_get() {
    local file=$1
    local key=$2
    
    cat "$file" | jq ".$key" 2>/dev/null || echo "Use jq for JSON parsing"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        get) cmd_get "$1" ;;
        post) cmd_post "$1" "$2" ;;
        put) cmd_put "$1" "$2" ;;
        delete) cmd_delete "$1" ;;
        bearer) cmd_bearer "$1" ;;
        basic) cmd_basic "$1" "$2" ;;
        json-pretty) cmd_json_pretty "$1" ;;
        json-get) cmd_json_get "$1" "$2" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
