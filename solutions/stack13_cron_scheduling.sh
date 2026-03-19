#!/bin/bash
# Stack 13 Solution: Cron & Scheduling - Task Scheduler

set -euo pipefail

NAME="Task Scheduler"
VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CRON_DIR="$HOME/.cron_jobs"
mkdir -p "$CRON_DIR"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Cron Job Management

Usage: $0 [COMMAND] [OPTIONS]

COMMANDS:
    list              List all scheduled tasks
    add NAME SCHEDULE COMMAND   Add a new cron job
    remove NAME       Remove a cron job
    enable NAME       Enable a cron job
    disable NAME      Disable a cron job
    next              Show next scheduled run times
    backup            Backup all cron jobs
    restore FILE      Restore cron jobs from backup

SCHEDULE FORMAT:
    * * * * *         (min hour day month weekday)
    @daily            Daily at midnight
    @hourly           Every hour
    @weekly           Every week

EXAMPLES:
    $0 add mytask "0 * * * *" "echo 'Hourly task'"
    $0 list
    $0 next
EOF
}

list_crons() {
    log "Scheduled Tasks:"
    echo "================"
    crontab -l 2>/dev/null || echo "No crontab configured"
    echo ""
    log "Custom Scripts in $CRON_DIR:"
    ls -la "$CRON_DIR/" 2>/dev/null || echo "None"
}

add_cron() {
    local name=$1
    local schedule=$2
    shift 2
    local command="$*"

    local script_path="$CRON_DIR/${name}.sh"
    
    cat > "$script_path" << EOF
#!/bin/bash
# Cron job: $name
# Schedule: $schedule
$command
EOF
    chmod +x "$script_path"

    (crontab -l 2>/dev/null; echo "$schedule $script_path") | crontab -
    log "Added cron job '$name' with schedule '$schedule'"
}

remove_cron() {
    local name=$1
    local script_path="$CRON_DIR/${name}.sh"
    
    if [ -f "$script_path" ]; then
        crontab -l 2>/dev/null | grep -v "$script_path" | crontab -
        rm -f "$script_path"
        log "Removed cron job '$name'"
    else
        error "Cron job '$name' not found"
    fi
}

enable_cron() {
    local name=$1
    local script_path="$CRON_DIR/${name}.sh"
    
    if [ -f "${script_path}.disabled" ]; then
        mv "${script_path}.disabled" "$script_path"
        crontab -l 2>/dev/null | sed "s|#.*$script_path|$script_path|" | crontab -
        log "Enabled cron job '$name'"
    else
        error "Cron job '$name' is not disabled"
    fi
}

disable_cron() {
    local name=$1
    local script_path="$CRON_DIR/${name}.sh"
    
    if [ -f "$script_path" ]; then
        mv "$script_path" "${script_path}.disabled"
        crontab -l 2>/dev/null | sed "s|$script_path|#$script_path|" | crontab -
        log "Disabled cron job '$name'"
    else
        error "Cron job '$name' not found"
    fi
}

next_runs() {
    log "Next scheduled runs:"
    crontab -l 2>/dev/null | while read -r schedule cmd; do
        [[ -z "$schedule" || "$schedule" == "#"* ]] && continue
        echo "  $schedule -> $cmd"
    done
}

backup_crons() {
    local backup_file="$CRON_DIR/backup_$(date +%Y%m%d).cron"
    crontab -l > "$backup_file" 2>/dev/null
    log "Backed up to $backup_file"
}

restore_crons() {
    local backup_file=$1
    if [ -f "$backup_file" ]; then
        crontab "$backup_file"
        log "Restored from $backup_file"
    else
        error "Backup file not found"
    fi
}

main() {
    local cmd=${1:-}
    case $cmd in
        list) list_crons ;;
        add) 
            if [ $# -lt 3 ]; then
                error "Usage: $0 add NAME SCHEDULE COMMAND"
                exit 1
            fi
            add_cron "$2" "$3" "${@:4}" ;;
        remove) remove_cron "$2" ;;
        enable) enable_cron "$2" ;;
        disable) disable_cron "$2" ;;
        next) next_runs ;;
        backup) backup_crons ;;
        restore) restore_crons "$2" ;;
        -h|--help) show_usage ;;
        *) show_usage ;;
    esac
}

main "$@"
