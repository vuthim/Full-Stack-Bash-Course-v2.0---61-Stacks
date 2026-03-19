#!/bin/bash
################################################################################
# DevOps Toolkit - Full Stack Bash Implementation
# A comprehensive server management and automation system
# Version: 1.0.0
################################################################################

set -o pipefail

################################################################################
# CONFIGURATION
################################################################################

readonly SCRIPT_NAME="DevOps Toolkit"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_AUTHOR="DevOps Team"
readonly CONFIG_DIR="${HOME}/.devops-toolkit"
readonly LOG_DIR="${CONFIG_DIR}/logs"
readonly CACHE_DIR="${CONFIG_DIR}/cache"
readonly BACKUP_DIR="${CONFIG_DIR}/backups"

declare -A CONFIG=(
    [log_level]="INFO"
    [log_rotation]="7"
    [parallel_tasks]="4"
    [timeout]="300"
    [retry_count]="3"
    [color_enabled]="true"
    [backup_enabled]="true"
)

declare -A STATUS=(
    [services]="unknown"
    [backups]="unknown"
    [monitoring]="unknown"
    [security]="unknown"
)

################################################################################
# COLOR CODES
################################################################################

enable_colors() {
    if [[ -n "$FORCE_COLORS" ]]; then
        return 0
    elif [[ -n "$NO_COLOR" ]]; then
        return 1
    elif [[ -t 1 ]]; then
        return 0
    elif [[ "$TERM" == *"color"* ]] || [[ "$TERM" == "xterm" ]] || [[ "$TERM" == "screen" ]]; then
        return 0
    fi
    return 1
}

if enable_colors; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly MAGENTA='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly WHITE='\033[0;37m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly MAGENTA=''
    readonly CYAN=''
    readonly WHITE=''
    readonly BOLD=''
    readonly NC=''
    COLORS_ENABLED=false
fi

################################################################################
# GLOBAL VARIABLES
################################################################################

VERBOSE=false
DRY_RUN=false
FORCE=false
OUTPUT_FORMAT="text"

################################################################################
# UTILITY FUNCTIONS
################################################################################

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    
    local color=$NC
    case $level in
        DEBUG)   [[ "$VERBOSE" == true ]] && color=$WHITE ;;
        INFO)    color=$BLUE ;;
        SUCCESS) color=$GREEN ;;
        WARN)    color=$YELLOW ;;
        ERROR)   color=$RED ;;
        FATAL)   color=$RED ;;
    esac
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\"}"
    else
        echo -e "${color}[$timestamp] [$level]${NC} $message"
    fi
    
    [[ "$level" == "FATAL" ]] && exit 1
}

debug()   { log DEBUG "$@"; }
info()    { log INFO "$@"; }
success() { log SUCCESS "$@"; }
warn()    { log WARN "$@"; }
error()   { log ERROR "$@"; }
fatal()   { log FATAL "$@"; }

trap_cleanup() {
    local exit_code=$?
    info "Cleaning up..."
    rm -f "${TMPDIR:-/tmp}/devops_$$"*
    exit $exit_code
}

trap trap_cleanup EXIT INT TERM

################################################################################
# FILE SYSTEM FUNCTIONS
################################################################################

ensure_directories() {
    local dirs=("$CONFIG_DIR" "$LOG_DIR" "$CACHE_DIR" "$BACKUP_DIR")
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" || fatal "Failed to create directory: $dir"
            debug "Created directory: $dir"
        fi
    done
}

file_exists() {
    [[ -f "$1" ]]
}

dir_exists() {
    [[ -d "$1" ]]
}

is_readable() {
    [[ -r "$1" ]]
}

is_writable() {
    [[ -w "$1" ]]
}

get_file_size() {
    stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null
}

get_file_age() {
    local file=$1
    local now=$(date +%s)
    local modified=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null)
    echo $((now - modified))
}

backup_file() {
    local file=$1
    local backup_name="${BACKUP_DIR}/$(basename "$file").$(date +%Y%m%d_%H%M%S).bak"
    
    if file_exists "$file"; then
        cp -p "$file" "$backup_name" || {
            error "Failed to backup: $file"
            return 1
        }
        success "Backed up: $file -> $backup_name"
    fi
}

restore_file() {
    local backup=$1
    local original=${1%.bak.*}
    
    if file_exists "$backup"; then
        cp -p "$backup" "$original" || {
            error "Failed to restore: $backup"
            return 1
        }
        success "Restored: $backup -> $original"
    fi
}

################################################################################
# ARRAY AND DATA STRUCTURE FUNCTIONS
################################################################################

array_contains() {
    local element=$1
    shift
    local array=("$@")
    
    for item in "${array[@]}"; do
        [[ "$item" == "$element" ]] && return 0
    done
    return 1
}

array_join() {
    local delimiter=$1
    shift
    local array=("$@")
    
    local result=""
    for item in "${array[@]}"; do
        result+="${result:+$delimiter}$item"
    done
    echo "$result"
}

assoc_array_to_json() {
    local -n arr=$1
    local first=true
    
    echo -n "{"
    for key in "${!arr[@]}"; do
        [[ "$first" == false ]] && echo -n ", "
        first=false
        echo -n "\"$key\": \"${arr[$key]}\""
    done
    echo "}"
}

parse_csv_line() {
    local line=$1
    local delimiter=${2:-","}
    
    IFS="$delimiter" read -ra fields <<< "$line"
    echo "${fields[@]}"
}

################################################################################
# STRING FUNCTIONS
################################################################################

trim() {
    local var="$*"
    echo "$var" | xargs
}

to_lowercase() {
    echo "$*" | tr '[:upper:]' '[:lower:]'
}

to_uppercase() {
    echo "$*" | tr '[:lower:]' '[:upper:]'
}

starts_with() {
    local string=$1
    local prefix=$2
    [[ "$string" == "$prefix"* ]]
}

ends_with() {
    local string=$1
    local suffix=$2
    [[ "$string" == *"$suffix" ]]
}

contains() {
    local string=$1
    local substring=$2
    [[ "$string" == *"$substring"* ]]
}

generate_uuid() {
    if command -v uuidgen &>/dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    else
        cat /proc/sys/kernel/random/uuid
    fi
}

hash_string() {
    echo -n "$1" | sha256sum | awk '{print $1}'
}

################################################################################
# NUMERIC FUNCTIONS
################################################################################

is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

is_decimal() {
    [[ "$1" =~ ^[0-9]*\.?[0-9]+$ ]]
}

is_positive() {
    is_number "$1" && [[ $1 -gt 0 ]]
}

clamp() {
    local value=$1
    local min=$2
    local max=$3
    
    ((value < min)) && value=$min
    ((value > max)) && value=$max
    echo $value
}

min() {
    local a=$1 b=$2
    ((a < b)) && echo $a || echo $b
}

max() {
    local a=$1 b=$2
    ((a > b)) && echo $a || echo $b
}

################################################################################
# COMMAND EXECUTION FUNCTIONS
################################################################################

command_exists() {
    command -v "$1" &>/dev/null
}

run_command() {
    local cmd=("$@")
    local description=${cmd[0]}
    
    debug "Executing: ${cmd[*]}"
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would execute: ${cmd[*]}"
        return 0
    fi
    
    if ! "${cmd[@]}" 2>&1; then
        error "Command failed: $description"
        return 1
    fi
    
    return 0
}

run_command_output() {
    local cmd=("$@")
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would execute: ${cmd[*]}"
        return 0
    fi
    
    "${cmd[@]}" 2>/dev/null
}

run_command_with_retry() {
    local max_attempts=${CONFIG[retry_count]}
    local attempt=1
    local cmd=("$@")
    
    while [[ $attempt -le $max_attempts ]]; do
        debug "Attempt $attempt/$max_attempts: ${cmd[*]}"
        
        if "${cmd[@]}" 2>/dev/null; then
            return 0
        fi
        
        warn "Attempt $attempt failed, retrying..."
        ((attempt++))
        sleep 2
    done
    
    error "Command failed after $max_attempts attempts: ${cmd[*]}"
    return 1
}

run_parallel() {
    local max_jobs=${CONFIG[parallel_tasks]}
    local pids=()
    local tasks=("$@")
    
    for task in "${tasks[@]}"; do
        while [[ $(jobs -r | wc -l) -ge $max_jobs ]]; do
            sleep 0.1
        done
        
        eval "$task" &
        pids+=($!)
    done
    
    for pid in "${pids[@]}"; do
        wait $pid
    done
}

################################################################################
# SYSTEM INFORMATION FUNCTIONS
################################################################################

get_os_type() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        CYGWIN*)    echo "windows" ;;
        MINGW*)     echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

get_os_version() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID $VERSION_ID"
    elif [[ -f /etc/redhat-release ]]; then
        cat /etc/redhat-release
    else
        uname -r
    fi
}

get_kernel_version() {
    uname -r
}

get_hostname() {
    hostname
}

get_ip_address() {
    ip route get 1 2>/dev/null | grep -oP 'src \K[^ ]+' || \
    hostname -I | awk '{print $1}'
}

get_uptime() {
    if command_exists uptime; then
        uptime -p 2>/dev/null || uptime
    else
        cat /proc/uptime | awk '{print $1}'
    fi
}

get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | sed 's/ //'
}

get_cpu_count() {
    nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "1"
}

get_memory_info() {
    local mem_total mem_used mem_free
    
    if [[ "$(uname -s)" == "Linux" ]]; then
        read -r mem_total mem_available <<< $(grep MemTotal /proc/meminfo | awk '{print $2, $7}')
        mem_free=$mem_available
        mem_used=$((mem_total - mem_free))
        
        echo "total:$((mem_total / 1024)) used:$((mem_used / 1024)) free:$((mem_free / 1024))"
    else
        echo "total:unknown used:unknown free:unknown"
    fi
}

get_disk_info() {
    df -h / | awk 'NR==2 {print "total:"$2" used:"$3" free:"$4" percent:"$5}'
}

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
}

get_memory_usage() {
    free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}'
}

get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
}

################################################################################
# SERVICE MANAGEMENT FUNCTIONS
################################################################################

service_status() {
    local service=$1
    
    if command_exists systemctl; then
        systemctl is-active "$service" 2>/dev/null
    elif command_exists service; then
        service "$service" status 2>/dev/null | grep -q "running" && echo "running" || echo "stopped"
    else
        echo "unknown"
    fi
}

service_start() {
    local service=$1
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would start service: $service"
        return 0
    fi
    
    if command_exists systemctl; then
        sudo systemctl start "$service"
    elif command_exists service; then
        sudo service "$service" start
    fi
    
    [[ $(service_status "$service") == "active" ]]
}

service_stop() {
    local service=$1
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would stop service: $service"
        return 0
    fi
    
    if command_exists systemctl; then
        sudo systemctl stop "$service"
    elif command_exists service; then
        sudo service "$service" stop
    fi
    
    [[ $(service_status "$service") != "active" ]]
}

service_restart() {
    local service=$1
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would restart service: $service"
        return 0
    fi
    
    if command_exists systemctl; then
        sudo systemctl restart "$service"
    elif command_exists service; then
        sudo service "$service" restart
    fi
}

service_enable() {
    local service=$1
    
    if command_exists systemctl; then
        sudo systemctl enable "$service"
    fi
}

list_services() {
    if command_exists systemctl; then
        systemctl list-units --type=service --state=running --no-pager | \
            awk '{print $1}' | grep -v UNIT
    fi
}

################################################################################
# NETWORK FUNCTIONS
################################################################################

check_port() {
    local host=$1
    local port=$2
    local timeout=${3:-5}
    
    if timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

check_http() {
    local url=$1
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    [[ "$status" == "200" ]]
}

check_dns() {
    local domain=$1
    
    if command -v dig &>/dev/null; then
        dig +short "$domain" A
    else
        host "$domain" 2>/dev/null | grep "has address" | awk '{print $4}'
    fi
}

get_ssl_expiry() {
    local domain=$1
    local expiry=$(echo | openssl s_client -servername "$domain" -connect "$domain":443 2>/dev/null | \
        openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    
    echo "$expiry"
}

scan_ports() {
    local host=$1
    local start_port=${2:-1}
    local end_port=${3:-1024}
    
    for port in $(seq $start_port $end_port); do
        if check_port "$host" "$port" 1>/dev/null 2>&1; then
            echo "Port $port is open"
        fi
    done
}

################################################################################
# PACKAGE MANAGEMENT FUNCTIONS
################################################################################

detect_package_manager() {
    if command_exists apt; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists zypper; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

package_install() {
    local package=$1
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        apt)
            sudo apt-get install -y "$package" ;;
        yum)
            sudo yum install -y "$package" ;;
        dnf)
            sudo dnf install -y "$package" ;;
        pacman)
            sudo pacman -S --noconfirm "$package" ;;
        zypper)
            sudo zypper install -y "$package" ;;
        *)
            error "Unknown package manager"
            return 1
            ;;
    esac
}

package_update() {
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        apt)
            sudo apt-get update ;;
        yum)
            sudo yum check-update ;;
        dnf)
            sudo dnf check-update ;;
        pacman)
            sudo pacman -Sy ;;
    esac
}

package_list_installed() {
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        apt)
            dpkg -l | grep ^ii | awk '{print $2, $3}' ;;
        yum|dnf)
            rpm -qa --queryformat '%{NAME} %{VERSION}\n' ;;
        pacman)
            pacman -Q ;;
    esac
}

################################################################################
# DOCKER FUNCTIONS
################################################################################

docker_ps() {
    docker ps --format "{{.Names}}\t{{.Status}}\t{{.Ports}}"
}

docker_ps_all() {
    docker ps -a --format "{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"
}

docker_images_list() {
    docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
}

docker_start() {
    local container=$1
    docker start "$container"
}

docker_stop() {
    local container=$1
    docker stop "$container"
}

docker_remove() {
    local container=$1
    docker rm -f "$container"
}

docker_logs() {
    local container=$1
    local lines=${2:-50}
    docker logs --tail "$lines" "$container"
}

docker_stats() {
    docker stats --no-stream --format "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
}

docker_cleanup() {
    docker system prune -af
}

docker_build() {
    local tag=$1
    local path=${2:-.}
    
    docker build -t "$tag" "$path"
}

docker_exec() {
    local container=$1
    shift
    docker exec -it "$container" "$@"
}

################################################################################
# GIT FUNCTIONS
################################################################################

git_is_repo() {
    git rev-parse --git-dir &>/dev/null
}

git_current_branch() {
    git branch --show-current
}

git_remote_branches() {
    git branch -r
}

git_stash_changes() {
    git stash
}

git_stash_pop() {
    git stash pop
}

git_add_all() {
    git add -A
}

git_commit() {
    local message=$1
    git commit -m "$message"
}

git_push() {
    local remote=${1:-origin}
    local branch=${2:-main}
    git push "$remote" "$branch"
}

git_pull() {
    local remote=${1:-origin}
    local branch=${2:-main}
    git pull "$remote" "$branch"
}

git_log() {
    local count=${1:-10}
    git log --oneline -n "$count"
}

git_diff() {
    git diff --stat
}

git_create_branch() {
    local branch=$1
    git checkout -b "$branch"
}

git_delete_branch() {
    local branch=$1
    git branch -d "$branch"
}

git_merge_branch() {
    local branch=$1
    git merge "$branch"
}

################################################################################
# BACKUP AND RESTORE FUNCTIONS
################################################################################

backup_directory() {
    local source=$1
    local destination=${2:-$BACKUP_DIR}
    local name=$(basename "$source")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${destination}/${name}_${timestamp}.tar.gz"
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would backup: $source -> $backup_file"
        return 0
    fi
    
    tar -czf "$backup_file" -C "$(dirname "$source")" "$(basename "$source")" 2>/dev/null
    
    if [[ -f "$backup_file" ]]; then
        success "Backup created: $backup_file"
        echo "$backup_file"
    else
        error "Backup failed"
        return 1
    fi
}

backup_mysql() {
    local database=$1
    local user=${2:-root}
    local password=${3:-}
    local destination=${4:-$BACKUP_DIR}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${destination}/${database}_${timestamp}.sql"
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would backup database: $database"
        return 0
    fi
    
    if [[ -n "$password" ]]; then
        mysqldump -u "$user" -p"$password" "$database" > "$backup_file"
    else
        mysqldump -u "$user" "$database" > "$backup_file"
    fi
    
    gzip "$backup_file"
    success "Database backup created: ${backup_file}.gz"
}

backup_postgres() {
    local database=$1
    local user=${2:-postgres}
    local destination=${3:-$BACKUP_DIR}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${destination}/${database}_${timestamp}.sql"
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would backup database: $database"
        return 0
    fi
    
    PGPASSWORD="$password" pg_dump -U "$user" "$database" > "$backup_file"
    gzip "$backup_file"
    success "Database backup created: ${backup_file}.gz"
}

restore_directory() {
    local backup_file=$1
    local destination=${2:-.}
    
    if [[ ! -f "$backup_file" ]]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would restore: $backup_file -> $destination"
        return 0
    fi
    
    tar -xzf "$backup_file" -C "$destination"
    success "Restored from: $backup_file"
}

restore_mysql() {
    local backup_file=$1
    local database=$2
    local user=${3:-root}
    
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would restore database: $database"
        return 0
    fi
    
    if [[ "$backup_file" == *.gz ]]; then
        gunzip -c "$backup_file" | mysql -u "$user" "$database"
    else
        mysql -u "$user" "$database" < "$backup_file"
    fi
    
    success "Database restored: $database"
}

rotate_backups() {
    local directory=$1
    local days=${2:-7}
    
    find "$directory" -name "*.tar.gz" -mtime +"$days" -delete
    find "$directory" -name "*.sql.gz" -mtime +"$days" -delete
    
    success "Old backups removed (older than $days days)"
}

################################################################################
# MONITORING FUNCTIONS
################################################################################

check_system_health() {
    local cpu_usage=$(get_cpu_usage)
    local mem_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    
    echo "=== System Health Check ==="
    echo "CPU Usage: ${cpu_usage}%"
    echo "Memory Usage: ${mem_usage}%"
    echo "Disk Usage: ${disk_usage}%"
    
    if (( $(echo "$cpu_usage > 80" | bc -l 2>/dev/null || echo 0) )); then
        warn "High CPU usage detected!"
    fi
    
    if (( $(echo "$mem_usage > 80" | bc -l 2>/dev/null || echo 0) )); then
        warn "High memory usage detected!"
    fi
    
    if [[ ${disk_usage%?} -gt 80 ]]; then
        warn "High disk usage detected!"
    fi
}

check_service_health() {
    local service=$1
    
    if [[ $(service_status "$service") == "active" ]]; then
        success "$service is running"
    else
        error "$service is not running"
    fi
}

check_endpoint_health() {
    local url=$1
    local name=${2:-$url}
    
    if check_http "$url"; then
        success "$name is healthy"
    else
        error "$name is unreachable"
    fi
}

monitor_resources() {
    local interval=${1:-5}
    local count=${2:-10}
    
    for i in $(seq 1 $count); do
        clear
        echo "=== Resource Monitor (Sample $i/$count) ==="
        echo "Time: $(date)"
        echo ""
        check_system_health
        echo ""
        echo "Top Processes:"
        ps aux --sort=-%cpu | head -6 | tail -5 | awk '{print $11, $3"%"CPU, $4"%"MEM}'
        echo ""
        
        sleep "$interval"
    done
}

get_process_info() {
    local process=$1
    
    ps aux | grep "$process" | grep -v grep
}

kill_process() {
    local process=$1
    
    pkill -9 "$process"
    success "Killed process: $process"
}

################################################################################
# SECURITY FUNCTIONS
################################################################################

check_open_ports() {
    ss -tlnp 2>/dev/null | grep LISTEN || netstat -tlnp 2>/dev/null | grep LISTEN
}

check_failed_logins() {
    lastb | head -20
}

check_suid_files() {
    find / -perm -4000 -type f 2>/dev/null | head -20
}

check_listening_ports() {
    ss -tuln | grep LISTEN
}

scan_security() {
    echo "=== Security Scan ==="
    echo ""
    echo "Open Ports:"
    check_open_ports
    echo ""
    echo "Failed Logins:"
    check_failed_logins
    echo ""
    echo "SUID Files:"
    check_suid_files
}

secure_ssh() {
    local config_file="/etc/ssh/sshd_config"
    
    backup_file "$config_file"
    
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$config_file"
    sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$config_file"
    sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' "$config_file"
    
    sudo systemctl restart sshd
    
    success "SSH secured"
}

check_firewall_status() {
    if command_exists ufw; then
        sudo ufw status verbose
    elif command_exists firewall-cmd; then
        sudo firewall-cmd --list-all
    else
        echo "No firewall management tool found"
    fi
}

enable_firewall() {
    if command_exists ufw; then
        sudo ufw --force enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        success "UFW firewall enabled"
    elif command_exists firewall-cmd; then
        sudo firewall-cmd --set-default-zone=drop
        sudo firewall-cmd --reload
        success "firewalld enabled"
    else
        error "No firewall found"
    fi
}

################################################################################
# CONFIGURATION FUNCTIONS
################################################################################

load_config() {
    local config_file="${CONFIG_DIR}/config"
    
    if [[ -f "$config_file" ]]; then
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^#.*$ ]] && continue
            [[ -z "$key" ]] && continue
            CONFIG["$key"]="$value"
        done < "$config_file"
        
        debug "Configuration loaded from: $config_file"
    fi
}

save_config() {
    local config_file="${CONFIG_DIR}/config"
    
    {
        echo "# DevOps Toolkit Configuration"
        echo "# Generated: $(date)"
        echo ""
        for key in "${!CONFIG[@]}"; do
            echo "$key=${CONFIG[$key]}"
        done
    } > "$config_file"
    
    success "Configuration saved to: $config_file"
}

set_config() {
    local key=$1
    local value=$2
    
    CONFIG["$key"]="$value"
    save_config
}

get_config() {
    local key=$1
    echo "${CONFIG[$key]}"
}

################################################################################
# API AND HTTP FUNCTIONS
################################################################################

api_get() {
    local url=$1
    local headers=${2:-}
    
    curl -s -H "$headers" "$url"
}

api_post() {
    local url=$1
    local data=$2
    local headers=${3:-"Content-Type: application/json"}
    
    curl -s -X POST -H "$headers" -d "$data" "$url"
}

api_put() {
    local url=$1
    local data=$2
    local headers=${3:-"Content-Type: application/json"}
    
    curl -s -X PUT -H "$headers" -d "$data" "$url"
}

api_delete() {
    local url=$1
    
    curl -s -X DELETE "$url"
}

parse_json() {
    local json=$1
    local key=$2
    
    echo "$json" | grep -oP "\"$key\"\s*:\s*\K[^,}\"]*" | tr -d '"'
}

################################################################################
# KUBERNETES FUNCTIONS
################################################################################

k8s_check_connection() {
    if kubectl cluster-info &>/dev/null; then
        success "Connected to Kubernetes cluster"
        return 0
    else
        error "Cannot connect to Kubernetes cluster"
        return 1
    fi
}

k8s_get_pods() {
    local namespace=${1:-default}
    kubectl get pods -n "$namespace" --no-headers
}

k8s_get_services() {
    local namespace=${1:-default}
    kubectl get svc -n "$namespace" --no-headers
}

k8s_get_nodes() {
    kubectl get nodes --no-headers
}

k8s_deploy() {
    local name=$1
    local image=$2
    local namespace=${3:-default}
    
    kubectl create deployment "$name" --image="$image" -n "$namespace"
    success "Deployed: $name"
}

k8s_scale() {
    local name=$1
    local replicas=$2
    local namespace=${3:-default}
    
    kubectl scale deployment "$name" --replicas="$replicas" -n "$namespace"
    success "Scaled $name to $replicas replicas"
}

k8s_delete() {
    local name=$1
    local namespace=${2:-default}
    
    kubectl delete deployment "$name" -n "$namespace"
    success "Deleted: $name"
}

k8s_logs() {
    local name=$1
    local namespace=${2:-default}
    local lines=${3:-50}
    
    kubectl logs -n "$namespace" --tail="$lines" deployment/"$name"
}

k8s_exec() {
    local name=$1
    shift
    local namespace=${2:-default}
    
    kubectl exec -it "$name" -n "$namespace" -- "$@"
}

k8s_port_forward() {
    local name=$1
    local local_port=$2
    local pod_port=$3
    local namespace=${4:-default}
    
    kubectl port-forward "$name" "$local_port:$pod_port" -n "$namespace"
}

k8s_get_status() {
    echo "=== Kubernetes Cluster Status ==="
    echo ""
    echo "Nodes:"
    k8s_get_nodes
    echo ""
    echo "Namespaces:"
    kubectl get namespaces --no-headers
}

################################################################################
# PROGRESS BAR AND UI FUNCTIONS
################################################################################

show_progress() {
    local current=$1
    local total=$2
    local message=${3:-"Progress"}
    local width=50
    
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r${message}: ["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' '-'
    printf "] %d%%" "$percent"
    
    [[ $current -eq $total ]] && echo ""
}

show_spinner() {
    local message=$1
    local delay=0.1
    local spinstr='|/-\'
    
    printf "%s" "$message "
    
    for i in {1..20}; do
        local temp=${spinstr#?}
        printf "\b%c" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    
    printf "\bDone!\n"
}

show_table() {
    local -a headers=("$@")
    local width=15
    
    printf "%-${width}s" "${headers[@]}"
    echo ""
    printf "%${width}s" | tr ' ' '-'
    echo ""
}

################################################################################
# PARSING AND VALIDATION FUNCTIONS
################################################################################

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -o|--output)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -*)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done
    
    COMMAND=${1:-}
    shift || true
    COMMAND_ARGS=("$@")
}

validate_arguments() {
    [[ -n "$COMMAND" ]] || {
        error "No command specified"
        show_help
        exit 1
    }
}

################################################################################
# MAIN COMMANDS
################################################################################

cmd_info() {
    echo "============================================"
    echo "  $SCRIPT_NAME v$SCRIPT_VERSION"
    echo "============================================"
    echo ""
    echo "OS: $(get_os_type) $(get_os_version)"
    echo "Kernel: $(get_kernel_version)"
    echo "Hostname: $(get_hostname)"
    echo "IP: $(get_ip_address)"
    echo "Uptime: $(get_uptime)"
    echo "CPU Cores: $(get_cpu_count)"
    echo "Load: $(get_load_average)"
    echo ""
    echo "Memory: $(get_memory_info)"
    echo "Disk: $(get_disk_info)"
    echo ""
    echo "Package Manager: $(detect_package_manager)"
    echo "Docker: $(command_exists docker && echo 'available' || echo 'not installed')"
    echo "Kubernetes: $(command_exists kubectl && echo 'available' || echo 'not installed')"
}

cmd_status() {
    echo "=== Service Status ==="
    echo ""
    echo "Services:"
    for service in nginx docker sshd postgresql mysql; do
        local status=$(service_status "$service")
        if [[ "$status" == "active" ]]; then
            success "$service: running"
        else
            error "$service: stopped"
        fi
    done
    echo ""
    
    check_system_health
}

cmd_backup() {
    local source=${COMMAND_ARGS[0]}
    local destination=${COMMAND_ARGS[1]}
    
    [[ -z "$source" ]] && {
        error "Usage: $0 backup <source> [destination]"
        return 1
    }
    
    backup_directory "$source" "$destination"
}

cmd_restore() {
    local backup_file=${COMMAND_ARGS[0]}
    local destination=${COMMAND_ARGS[1]}
    
    [[ -z "$backup_file" ]] && {
        error "Usage: $0 restore <backup_file> [destination]"
        return 1
    }
    
    restore_directory "$backup_file" "$destination"
}

cmd_monitor() {
    local interval=${COMMAND_ARGS[0]:-5}
    local count=${COMMAND_ARGS[1]:-10}
    
    monitor_resources "$interval" "$count"
}

cmd_security() {
    scan_security
}

cmd_docker() {
    local action=${COMMAND_ARGS[0]}
    local target=${COMMAND_ARGS[1]}
    
    case $action in
        ps)
            docker_ps ;;
        ps-all)
            docker_ps_all ;;
        images)
            docker_images_list ;;
        start)
            [[ -z "$target" ]] && { error "Container name required"; return 1; }
            docker_start "$target" ;;
        stop)
            [[ -z "$target" ]] && { error "Container name required"; return 1; }
            docker_stop "$target" ;;
        logs)
            [[ -z "$target" ]] && { error "Container name required"; return 1; }
            docker_logs "$target" ;;
        stats)
            docker_stats ;;
        cleanup)
            docker_cleanup ;;
        *)
            echo "Usage: docker <ps|ps-all|images|start|stop|logs|stats|cleanup> [container]"
            ;;
    esac
}

cmd_git() {
    local action=${COMMAND_ARGS[0]}
    shift
    local args=("$@")
    
    case $action in
        status)
            git status ;;
        branch)
            git branch ;;
        log)
            git_log "${args[0]:-10}" ;;
        push)
            git_push "${args[0]:-origin}" "${args[1]:-main}" ;;
        pull)
            git_pull "${args[0]:-origin}" "${args[1]:-main}" ;;
        stash)
            git_stash_changes ;;
        *)
            echo "Usage: git <status|branch|log|push|pull|stash> [args...]"
            ;;
    esac
}

cmd_k8s() {
    k8s_check_connection || return 1
    
    local action=${COMMAND_ARGS[0]}
    shift
    local args=("$@")
    
    case $action in
        pods)
            k8s_get_pods "${args[0]:-default}" ;;
        services|svc)
            k8s_get_services "${args[0]:-default}" ;;
        nodes)
            k8s_get_nodes ;;
        deploy)
            [[ ${#args[@]} -lt 2 ]] && { error "Usage: k8s deploy <name> <image> [namespace]"; return 1; }
            k8s_deploy "${args[0]}" "${args[1]}" "${args[2]:-default}" ;;
        scale)
            [[ ${#args[@]} -lt 2 ]] && { error "Usage: k8s scale <name> <replicas> [namespace]"; return 1; }
            k8s_scale "${args[0]}" "${args[1]}" "${args[2]:-default}" ;;
        delete)
            [[ ${#args[@]} -lt 1 ]] && { error "Usage: k8s delete <name> [namespace]"; return 1; }
            k8s_delete "${args[0]}" "${args[1]:-default}" ;;
        logs)
            [[ ${#args[@]} -lt 1 ]] && { error "Usage: k8s logs <name> [namespace] [lines]"; return 1; }
            k8s_logs "${args[0]}" "${args[1]:-default}" "${args[2]:-50}" ;;
        status)
            k8s_get_status ;;
        *)
            echo "Usage: k8s <pods|services|nodes|deploy|scale|delete|logs|status> [args...]"
            ;;
    esac
}

cmd_help() {
    show_help
}

show_help() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION
A comprehensive DevOps toolkit for system administration

Usage: $(basename "$0") [OPTIONS] COMMAND [ARGS...]

OPTIONS:
    -h, --help           Show this help message
    -v, --verbose       Enable verbose output
    -n, --dry-run       Show what would be done
    -f, --force         Force execution
    -o, --output FORMAT Output format (text|json)

COMMANDS:
    info                 Show system information
    status               Show service status
    backup <src> [dst]   Backup directory or database
    restore <file> [dst] Restore from backup
    monitor [n] [c]     Monitor resources
    security             Run security scan
    
    docker <action> [args...]  Docker management
    git <action> [args...]     Git operations
    k8s <action> [args...]     Kubernetes operations

EXAMPLES:
    $(basename "$0") info
    $(basename "$0") backup /home
    $(basename "$0") docker ps
    $(basename "$0") k8s pods

For more information, visit: https://github.com/devops/toolkit
EOF
}

################################################################################
# MAIN FUNCTION
################################################################################

main() {
    ensure_directories
    load_config
    
    parse_arguments "$@"
    validate_arguments
    
    case "$COMMAND" in
        info)      cmd_info ;;
        status)    cmd_status ;;
        backup)    cmd_backup ;;
        restore)   cmd_restore ;;
        monitor)   cmd_monitor ;;
        security)  cmd_security ;;
        docker)    cmd_docker ;;
        git)       cmd_git ;;
        k8s|kube)  cmd_k8s ;;
        help|--help|-h)
            cmd_help
            ;;
        *)
            error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
