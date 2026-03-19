#!/bin/bash
# Stack 21 Solution: Web Scraping - Web Scraper

set -euo pipefail

NAME="Web Scraper"
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
$NAME v$VERSION - Web Scraping Tool

Usage: $0 [COMMAND] [OPTIONS]

SCRAPING:
    get URL              Fetch page content
    json URL             Fetch and parse JSON
    extract URL PATTERN  Extract pattern from page
    title URL            Get page title
    links URL            Extract all links
    images URL           Extract all images

API:
    api URL              Call API endpoint
    api-json URL         Pretty print JSON

EXAMPLES:
    $0 get https://example.com
    $0 json https://api.github.com/users/octocat
    $0 links https://example.com
EOF
}

cmd_get() {
    local url=$1
    curl -s "$url"
}

cmd_json() {
    local url=$1
    curl -s "$url" | python3 -m json.tool 2>/dev/null || \
    curl -s "$url" | jq . 2>/dev/null || \
    curl -s "$url"
}

cmd_extract() {
    local url=$1
    local pattern=$2
    curl -s "$url" | grep -oE "$pattern" | head -20
}

cmd_title() {
    local url=$1
    curl -s "$url" | grep -oE '<title>(.*?)</title>' | sed 's/<title>//;s/<\/title>//'
}

cmd_links() {
    local url=$1
    curl -s "$url" | grep -oE 'href="[^"]*"' | sed 's/href="//;s/"//' | sort -u
}

cmd_images() {
    local url=$1
    curl -s "$url" | grep -oE '<img[^>]+src="[^"]*"' | sed 's/.*src="//;s/".*//' | sort -u
}

cmd_api() {
    local url=$1
    curl -s -H "Accept: application/json" "$url"
}

cmd_api_json() {
    local url=$1
    curl -s "$url" | jq .
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        get) cmd_get "$1" ;;
        json) cmd_json "$1" ;;
        extract) cmd_extract "$1" "$2" ;;
        title) cmd_title "$1" ;;
        links) cmd_links "$1" ;;
        images) cmd_images "$1" ;;
        api) cmd_api "$1" ;;
        api-json) cmd_api_json "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
