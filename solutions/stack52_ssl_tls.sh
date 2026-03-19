#!/bin/bash
# Stack 52 Solution: SSL/TLS - Certificate Manager

set -euo pipefail

NAME="SSL/TLS Manager"
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
$NAME v$VERSION - SSL/TLS Certificate Management

Usage: $0 [COMMAND] [OPTIONS]

CERTIFICATES:
    create DOMAIN        Create self-signed cert
    info FILE            Show cert info
    verify FILE          Verify certificate
    expire FILE          Check expiration

LETSENCRYPT:
    certbot DOMAIN       Get Let's Encrypt cert
    renew                Renew certificates

TEST:
    test DOMAIN          Test SSL configuration
    grade DOMAIN         Show SSL grade

EXAMPLES:
    $0 create example.com
    $0 test example.com
EOF
}

cmd_create() {
    local domain=$1
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${domain}.key" -out "${domain}.crt" \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$domain"
    
    log "Created certificate for $domain"
}

cmd_info() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        error "Certificate not found: $file"
        exit 1
    fi
    
    openssl x509 -in "$file" -noout -text | head -20
}

cmd_verify() {
    local file=$1
    local key=${2:-}
    
    if [ -n "$key" ]; then
        openssl verify -CAfile "$file" "$key"
    else
        openssl x509 -in "$file" -noout -text
    fi
}

cmd_expire() {
    local file=$1
    
    local expiry=$(openssl x509 -in "$file" -noout -enddate | cut -d= -f2)
    echo "Expires: $expiry"
}

cmd_certbot() {
    local domain=$1
    
    if ! command -v certbot &>/dev/null; then
        error "Certbot not installed"
        exit 1
    fi
    
    sudo certbot certonly --standalone -d "$domain"
    log "Certificate obtained for $domain"
}

cmd_renew() {
    if command -v certbot &>/dev/null; then
        sudo certbot renew
    else
        error "Certbot not installed"
    fi
}

cmd_test() {
    local domain=$1
    
    echo | openssl s_client -connect "$domain":443 2>/dev/null | \
        openssl x509 -noout -subject -issuer -dates
}

cmd_grade() {
    local domain=$1
    
    echo "Testing SSL for $domain..."
    curl -s "https://api.ssllabs.com/api/v3/analyze?host=$domain" | \
        jq -r '.endpoints[] | .grade' 2>/dev/null || echo "Manual check required"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        create) cmd_create "$1" ;;
        info) cmd_info "$1" ;;
        verify) cmd_verify "$1" "${2:-}" ;;
        expire) cmd_expire "$1" ;;
        certbot) cmd_certbot "$1" ;;
        renew) cmd_renew ;;
        test) cmd_test "$1" ;;
        grade) cmd_grade "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
