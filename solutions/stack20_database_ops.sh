#!/bin/bash
# Stack 20 Solution: Database Operations - Database Manager

set -euo pipefail

NAME="Database Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DB_HOST=${DB_HOST:-localhost}
DB_USER=${DB_USER:-root}
DB_PASS=${DB_PASS:-}
DB_NAME=${DB_NAME:-}

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Database Operations Tool

Usage: $0 [COMMAND] [OPTIONS]

ENVIRONMENT:
    DB_HOST, DB_USER, DB_PASS, DB_NAME

MYSQL:
    mysql-query SQL      Execute MySQL query
    mysql-tables         List tables
    mysql-backup         Backup database
    mysql-restore FILE   Restore database

POSTGRESQL:
    psql-query SQL       Execute PostgreSQL query
    psql-tables          List tables
    psql-backup          Backup database

BACKUP:
    backup               Backup all databases
    restore FILE         Restore from backup

EXAMPLES:
    DB_NAME=mydb DB_USER=root $0 mysql-query "SELECT * FROM users"
    DB_NAME=mydb $0 mysql-backup
EOF
}

mysql_exec() {
    if [ -n "$DB_PASS" ]; then
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$1"
    else
        mysql -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" -e "$1"
    fi
}

psql_exec() {
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "$1"
}

cmd_mysql_query() {
    local sql=$1
    if [ -z "$DB_NAME" ]; then
        error "DB_NAME not set"
        exit 1
    fi
    mysql_exec "$sql"
}

cmd_mysql_tables() {
    if [ -z "$DB_NAME" ]; then
        error "DB_NAME not set"
        exit 1
    fi
    echo -e "${BLUE}=== Tables in $DB_NAME ===${NC}"
    mysql_exec "SHOW TABLES;"
}

cmd_mysql_backup() {
    if [ -z "$DB_NAME" ]; then
        error "DB_NAME not set"
        exit 1
    fi
    
    local backup_file="mysql_${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"
    
    if [ -n "$DB_PASS" ]; then
        mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$backup_file"
    else
        mysqldump -h "$DB_HOST" -u "$DB_USER" "$DB_NAME" > "$backup_file"
    fi
    
    gzip "$backup_file"
    log "Backed up to: ${backup_file}.gz"
}

cmd_mysql_restore() {
    local file=$1
    
    if [ -z "$DB_NAME" ]; then
        error "DB_NAME not set"
        exit 1
    fi
    
    if [ -f "${file}.gz" ]; then
        gunzip -c "${file}.gz" | mysql -h "$DB_HOST" -u "$DB_USER" "${DB_PASS:+-p$DB_PASS}" "$DB_NAME"
    else
        mysql -h "$DB_HOST" -u "$DB_USER" "${DB_PASS:+-p$DB_PASS}" "$DB_NAME" < "$file"
    fi
    
    log "Restored from: $file"
}

cmd_psql_query() {
    local sql=$1
    if [ -z "$DB_NAME" ]; then
        error "DB_NAME not set"
        exit 1
    fi
    psql_exec "$sql"
}

cmd_psql_tables() {
    if [ -z "$DB_NAME" ]; then
        error "DB_NAME not set"
        exit 1
    fi
    echo -e "${BLUE}=== Tables in $DB_NAME ===${NC}"
    psql_exec "\dt"
}

cmd_psql_backup() {
    if [ -z "$DB_NAME" ]; then
        error "DB_NAME not set"
        exit 1
    fi
    
    local backup_file="psql_${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"
    
    PGPASSWORD="$DB_PASS" pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" > "$backup_file"
    gzip "$backup_file"
    log "Backed up to: ${backup_file}.gz"
}

cmd_backup() {
    local backup_dir="db_backups_$(date +%Y%m%d)"
    mkdir -p "$backup_dir"
    
    if command -v mysqldump &>/dev/null; then
        for db in $(mysql -h "$DB_HOST" -u "$DB_USER" "${DB_PASS:+-p$DB_PASS}" -e "SHOW DATABASES;" 2>/dev/null | grep -v Database); do
            if [ "$db" != "information_schema" ] && [ "$db" != "performance_schema" ]; then
                mysqldump -h "$DB_HOST" -u "$DB_USER" "${DB_PASS:+-p$DB_PASS}" "$db" | gzip > "$backup_dir/${db}.sql.gz"
                log "Backed up: $db"
            fi
        done
    fi
    
    log "Backup complete: $backup_dir"
}

cmd_restore() {
    local file=$1
    
    if [[ "$file" == *.sql.gz ]]; then
        gunzip -c "$file" | mysql -h "$DB_HOST" -u "$DB_USER" "${DB_PASS:+-p$DB_PASS}"
    else
        mysql -h "$DB_HOST" -u "$DB_USER" "${DB_PASS:+-p$DB_PASS}" < "$file"
    fi
    
    log "Restored from: $file"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        mysql-query) cmd_mysql_query "$1" ;;
        mysql-tables) cmd_mysql_tables ;;
        mysql-backup) cmd_mysql_backup ;;
        mysql-restore) cmd_mysql_restore "$1" ;;
        psql-query) cmd_psql_query "$1" ;;
        psql-tables) cmd_psql_tables ;;
        psql-backup) cmd_psql_backup ;;
        backup) cmd_backup ;;
        restore) cmd_restore "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
