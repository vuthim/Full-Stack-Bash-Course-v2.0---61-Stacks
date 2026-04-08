# 🏆 STACK 12: ADVANCED SCRIPTING
## Professional Level Techniques

---

## 🛡️ The Holy Grail: set -euo pipefail

This is the **most important** safety combination for production scripts.

### What Each Flag Does

```bash
#!/bin/bash
set -euo pipefail

# -e: Exit immediately if a command exits with non-zero
# -u: Treat unset variables as errors (replaced with "")
# -o pipefail: Pipeline fails if any command fails (not just the last)
```

### The Problem Without These Flags

```bash
#!/bin/bash
# WITHOUT set -euo pipefail

# Problem 1: Unset variables silently expand to empty
rm -rf $UNDEFINED_VAR/logs     # DELETES /logs if UNDEFINED_VAR is empty!

# Problem 2: Failed commands continue silently
grep nonexistent file          # grep returns 1, but script continues
echo "Script continues..."     # This runs even though grep failed

# Problem 3: Pipelines hide failures
grep pattern file | head       # If grep fails, pipeline returns 0!
false | true                   # Without pipefail: returns 0 (success!)
```

### The Solution

```bash
#!/bin/bash
set -euo pipefail

# Now:
rm -rf "${UNDEFINED_VAR:?}/logs"   # Error: UNDEFINED_VAR is unset

grep nonexistent file              # Script exits immediately

grep pattern file | head           # Script exits if grep fails
```

### When to Use Each Flag

| Flag | Use In | Don't Use In |
|------|--------|--------------|
| `set -e` | Production scripts | Interactive scripts, loops that handle errors |
| `set -u` | Almost all scripts | Scripts that intentionally use unset variables |
| `set -o pipefail` | All scripts with pipelines | Rare edge cases |

### Caveats and How to Handle Them

```bash
#!/bin/bash
set -euo pipefail

# Problem: 'set -e' exits on commands that return non-zero
# But sometimes we WANT to handle errors gracefully

# Solution 1: Use '|| true' for expected failures
if grep pattern file || true; then
    echo "Found or not found, continue anyway"
fi

# Solution 2: Use conditional execution
cd /some/dir && do_something

# Solution 3: Use error handling in functions
run_or_continue() {
    "$@" || return 0   # Don't exit on failure
}

# Problem: 'set -e' exits in loops sometimes
# Solution: Use || true inside loops
for item in "${items[@]}"; do
    process "$item" || true   # Continue even if one fails
done

# Problem: Pipelines with head/tail/take first
# grep errors are masked by head succeeding
# Solution: Use explicit checks
output=$(grep pattern file) || true
echo "$output" | head -n 5
```

### Recommended Script Template

```bash
#!/bin/bash
#==============================================================================
# Script: my_script.sh
# Purpose: Description here
# Author: Your Name
#==============================================================================

set -euo pipefail
IFS=$'\n\t'

# Script directory for includes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors (optional)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Error handler
on_error() {
    local exit_code=$?
    error "Error on line $LINENO (exit code: $exit_code)"
    exit "$exit_code"
}
trap on_error ERR

# Cleanup handler
cleanup() {
    # Add cleanup code here
    rm -f "$tmpfile"
}
trap cleanup EXIT

# Main
main() {
    log "Starting..."
    # Your code here
    log "Done!"
}

main "$@"
```

---

## 🎯 Comprehensive trap Usage

`trap` lets you execute code when signals are received or when errors occur.

### trap Syntax
```bash
trap 'commands' signals
trap 'commands' EXIT
trap 'commands' ERR
trap 'commands' RETURN
```

### Available Signals

```bash
# Common signals:
EXIT    # When script exits (any reason)
ERR     # When any command returns non-zero
INT     # Interrupt (Ctrl+C)
HUP     # Hangup (terminal closed)
TERM    # Termination signal
KILL    # Cannot be caught (force kill)
```

### trap ERR - Error Handling

```bash
#!/bin/bash
set -euo pipefail

on_error() {
    echo "=========================================="
    echo "ERROR: Command failed at line $LINENO"
    echo "Last command: $BASH_COMMAND"
    echo "Exit code: $?"
    echo "=========================================="
    echo "Stack trace:"
    local i=0
    while caller $i; do
        ((i++))
    done
}

trap on_error ERR

# Now any error will trigger on_error
```

### trap EXIT - Cleanup

```bash
#!/bin/bash
set -euo pipefail

tmpfile=$(mktemp)
tmpdir=$(mktemp -d)

# Cleanup on ANY exit
cleanup() {
    local exit_status=$?
    
    echo "Cleaning up..."
    rm -rf "$tmpfile" "$tmpdir" 2>/dev/null || true
    
    if [ $exit_status -eq 0 ]; then
        echo "Script completed successfully"
    else
        echo "Script failed with exit code $exit_status"
    fi
}

trap cleanup EXIT

# Now even if script crashes, cleanup runs
```

### trap INT - Handle Ctrl+C

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo ""
    echo "Interrupted! Cleaning up..."
    # Kill background jobs
    jobs -p | xargs -r kill 2>/dev/null || true
    exit 130  # 128 + 2 (SIGINT)
}

trap cleanup INT

# Long running process
sleep 1000
```

### trap RETURN - Debug Function Calls

```bash
#!/bin/bash
set -euo pipefail

log_function() {
    echo "[TRACE] Entering: ${FUNCNAME[1]}()"
}

trap 'log_function' RETURN

my_function() {
    echo "Inside my_function"
}

my_function
```

### Multiple Traps

```bash
#!/bin/bash
set -euo pipefail

# Set multiple traps
trap 'echo "EXIT trap"' EXIT
trap 'echo "ERR trap"' ERR
trap 'echo "INT trap"' INT

# Can have different commands for different signals
# EXIT always runs, others run conditionally
```

### Dynamic trap

```bash
#!/bin/bash
set -euo pipefail

# Update trap dynamically
setup_temp() {
    export TMPFILE=$(mktemp)
    trap 'rm -f "$TMPFILE"' EXIT
}

# Change trap later
trap 'echo "New cleanup"' EXIT
```

### Practical Example: Temp File with PID

```bash
#!/bin/bash
set -euo pipefail

# Use PID in temp file name to avoid conflicts
TMPFILE="/tmp/myapp.$$.tmp"

# Cleanup function
cleanup() {
    local exit_status=$?
    
    # Remove temp file if exists
    rm -f "$TMPFILE"
    
    # Remove lock file if we created it
    [ -f "/tmp/myapp.lock" ] && rm -f "/tmp/myapp.lock"
    
    exit "$exit_status"
}

trap cleanup EXIT
```

### Practical Example: Database Transaction

```bash
#!/bin/bash
set -euo pipefail

rollback_db() {
    echo "Rolling back transaction..."
    mysql -u root -e "ROLLBACK"
}

# Start transaction
mysql -u root -e "BEGIN"
trap rollback_db ERR

# Do work
mysql -u root -e "INSERT INTO logs VALUES ('started')"
mysql -u root -e "COMMIT"

# If we reach here, ERR trap is cleared
trap - ERR
```

---

## 📋 Professional getopts Parsing

`getopts` is the POSIX-standard way to parse command-line options.

### getopts vs getopt

| Feature | getopts | getopt |
|---------|---------|--------|
| POSIX | Yes | No (external) |
| Handles spaces | Yes | Needs special syntax |
| Handles empty args | Yes | Complicated |
| Auto-generates help | No | No |
| Shell built-in | Yes | No (external command) |

### Basic getopts Usage

```bash
#!/bin/bash

# Usage: script.sh -n name -a age -v

# Reset in case called multiple times
OPTIND=1

while getopts "n:a:v" opt; do
    case $opt in
        n)  name="$OPTARG"
            ;;
        a)  age="$OPTARG"
            ;;
        v)  verbose=true
            ;;
        \?) echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)  echo "Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "Name: $name, Age: $age, Verbose: $verbose"
echo "Remaining args: $*"
```

### Option Types

```bash
#!/bin/bash

# Option string format: "n:a:v"
# - n: flag with REQUIRED argument (followed by :)
# - a: another flag with argument
# - v: flag without argument

# Boolean flag (no colon)
# Flag with required argument (single colon)
# Flag with optional argument (double colon: :)

# Example with optional argument
OPTIND=1
while getopts "n:a::v" opt; do
    case $opt in
        n)  echo "Name: $OPTARG" ;;
        a)  echo "Age: ${OPTARG:-unknown}" ;;
        v)  echo "Verbose mode" ;;
    esac
done
```

### Long Options (Bash 4+)

```bash
#!/bin/bash
# Use getopt for long options, or parse manually

# Manual long option parsing
while [ $# -gt 0 ]; do
    case "$1" in
        --name)
            name="$2"
            shift 2
            ;;
        --age=*)
            age="${1#*=}"
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done
```

### Professional Help Generator

```bash
#!/bin/bash

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] FILE

Description:
    Process FILE and output results.

Options:
    -n, --name NAME     Set the name (required)
    -a, --age AGE       Set the age (optional, default: 0)
    -v, --verbose       Enable verbose output
    -h, --help          Show this help message

Examples:
    $(basename "$0") -n John -a 25 file.txt
    $(basename "$0") --name=Jane --verbose data.csv

Exit codes:
    0   Success
    1   General error
    2   Invalid arguments
EOF
}

# Option string: n: (requires arg), a: (optional arg), v (no arg)
# Long options: name:, age::, verbose, help
OPTIND=1
while getopts ":n:a::vh" opt; do
    case $opt in
        n|name)
            name="$OPTARG"
            ;;
        a|age)
            age="${OPTARG:-0}"
            ;;
        v|verbose)
            verbose=true
            ;;
        h|help)
            show_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help >&2
            exit 2
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            show_help >&2
            exit 2
            ;;
    esac
done
shift $((OPTIND - 1))

# Validate required arguments
if [ -z "${name:-}" ]; then
    echo "Error: --name is required" >&2
    show_help >&2
    exit 2
fi

# Remaining argument is the file
FILE="${1:-}"
if [ -z "$FILE" ]; then
    echo "Error: FILE argument is required" >&2
    show_help >&2
    exit 2
fi

echo "Processing: name=$name, age=$age, file=$FILE"
```

### Validating Arguments

```bash
#!/bin/bash

validate_number() {
    local var="$1"
    # Check if it's a positive integer
    [[ "$var" =~ ^[0-9]+$ ]]
}

validate_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
}

OPTIND=1
while getopts "n:f:" opt; do
    case $opt in
        n)  
            if ! validate_number "$OPTARG"; then
                echo "Error: -n must be a positive integer" >&2
                exit 1
            fi
            number="$OPTARG"
            ;;
        f)
            if ! validate_file "$OPTARG"; then
                exit 1
            fi
            file="$OPTARG"
            ;;
    esac
done
```

### Combining getopts with set -euo pipefail

```bash
#!/bin/bash
# Complete professional script template

set -euo pipefail
IFS=$'\n\t'

cleanup() {
    rm -f "$tmpfile" 2>/dev/null || true
}
trap cleanup EXIT

on_error() {
    echo "Error at line $LINENO" >&2
    exit 1
}
trap on_error ERR

usage() {
    cat << EOF
Usage: $(basename "$0") [-h] [-v] -n NAME -a AGE FILE

Options:
    -h          Show help
    -v          Verbose mode
    -n NAME     Name (required)
    -a AGE      Age (required)
    FILE        Input file (required)

EOF
}

OPTIND=1
verbose=false
name=""
age=""

while getopts "hvn:a:" opt; do
    case $opt in
        h)  usage; exit 0 ;;
        v)  verbose=true ;;
        n)  name="$OPTARG" ;;
        a)  age="$OPTARG" ;;
        \?) usage >&2; exit 1 ;;
        :)  echo "Option -$OPTARG requires an argument" >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Validate
: "${name:?--name is required}"
: "${age:?--age is required}"

if [ $# -eq 0 ]; then
    echo "Error: FILE is required" >&2
    usage >&2
    exit 1
fi

FILE="$1"

$verbose && echo "Processing $FILE for $name, age $age"
echo "Done!"
```

---

## 🔍 Debugging Scripts

### Debug Options
```bash
#!/bin/bash
set -x              # Print commands before execution
set -v              # Print input lines as read
set -e              # Exit on error
set -u              # Exit on undefined variable
set -o pipefail    # Pipe fails if any command fails
set -n              # Check syntax without executing
```

### Using Debug Flags
```bash
# At script start
#!/bin/bash
set -x             # Everything debugged

# Or run with debug
bash -x script.sh

# Check syntax
bash -n script.sh
```

### Selective Debugging
```bash
#!/bin/bash

echo "Normal execution"
set -x
echo "This will be debugged"
set +x

echo "Normal again"
```

### Custom Debug Function
```bash
debug() {
    if [ "$DEBUG" = "1" ]; then
        echo "[DEBUG] $*"
    fi
}

DEBUG=1 ./script.sh
```

---

## ⚠️ Error Handling

### Exit on Error
```bash
#!/bin/bash
set -e

# Script stops if any command fails
cd /some/directory
ls
cp file1 file2   # If this fails, script exits
```

### Exit Codes
```bash
# Exit with status
exit 0     # Success
exit 1     # General error
exit 2     # Misuse
exit 126  # Not executable
exit 127  # Command not found

# Check exit code
command
if [ $? -eq 0 ]; then
    echo "Success"
fi

# Or use &&
command && echo "Success"
```

---

## ✅ Input Validation

### Validating Arguments
```bash
#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $s <input> <output>"
    exit 1
fi

input=$1
output=$2

# Validate input exists
if [ ! -f "$input" ]; then
    echo "Error: Input file not found"
    exit 1
fi

# Validate not empty
if [ -z "$input" ]; then
    echo "Error: Empty input"
    exit 1
fi
```

### Validating Numbers
```bash
is_number() {
    re='^[0-9]+$'
    [[ $1 =~ $re ]]
}

if ! is_number "$age"; then
    echo "Invalid age"
fi
```

---

## 📦 Libraries & Includes

### Source External Files
```bash
# file: helpers.sh
log() {
    echo "[$(date)] $*"
}

# file: main.sh
#!/bin/bash
source helpers.sh
# or
. helpers.sh

log "Starting"
```

### Library Best Practice
```bash
# Check if already sourced
[[ -n "$_LIB_LOADED" ]] && return
_LIB_LOADED=1

# Rest of library
log() { ... }
```

---

## 📚 Advanced Patterns

### Command Substitution Elegantly
```bash
# Simple
result=$(command)

# With error handling
result=$(command) || { echo "Failed"; exit 1; }

# Capture output and status
result=$(command); status=$?

# Multiple captures
read -r name version <<< $(grep "VERSION" file | cut -d= -f2)
```

### Ternary Operator
```bash
# If else in one line
[ $status -eq 0 ] && echo "OK" || echo "Failed"

# More complex with else
result=$([ $status -eq 0 ] && echo "OK" || echo "Failed")

# Using arithmetic
(( $x > 0 )) && (( y = x * 2 )) || (( y = 0 ))
```

### Null Coalescing
```bash
# Use default if variable unset/empty
dir=${dir:-"/tmp"}

# Set if not set
dir=${dir:="/tmp"}
```

---

## 🚀 Real-World Project Examples

### Example 1: System Backup Script
```bash
#!/bin/bash
# Advanced backup script with validation, logging, error handling

set -euo pipefail

# Configuration
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup.log"
RETENTION_DAYS=30

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" | tee -a "$LOG_FILE" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}" | tee -a "$LOG_FILE"
}

# Validate running as root
if [ "$EUID" -ne 0 ]; then
    error "Run as root"
    exit 1
fi

# Validate backup directory
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Create backup
log "Starting backup..."

# Backup function
backup_directory() {
    local source=$1
    local dest=$2
    
    if [ -d "$source" ]; then
        tar -czf "$dest" "$source" 2>/dev/null && \
            success "Backed up $source" || \
            error "Failed to backup $source"
    fi
}

# Run backups
backup_directory "/home" "$BACKUP_DIR/home_$DATE.tar.gz"
backup_directory "/etc" "$BACKUP_DIR/etc_$DATE.tar.gz"

# Cleanup old backups
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

log "Backup complete!"
success "Backup finished successfully"
```

### Example 2: Interactive Menu System
```bash
#!/bin/bash
# Professional menu-driven system admin script

set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

trap 'echo -e "\n\n${RED}Exiting...${NC}"; exit 0' INT

show_header() {
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}     System Admin Tool${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

show_menu() {
    show_header
    echo -e "${GREEN}1.${NC} System Information"
    echo -e "${GREEN}2.${NC} User Management"
    echo -e "${GREEN}3.${NC} Service Management"
    echo -e "${GREEN}4.${NC} Log Viewer"
    echo -e "${GREEN}5.${NC} Disk Usage"
    echo -e "${GREEN}6.${NC} Network Status"
    echo -e "${RED}Q.${NC} Quit"
    echo
    echo -n "Select option: "
}

system_info() {
    show_header
    echo -e "${YELLOW}System Information${NC}"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo
    read -p "Press Enter to continue..."
}

disk_usage() {
    show_header
    echo -e "${YELLOW}Disk Usage${NC}"
    df -h | grep -v tmpfs
    echo
    read -p "Press Enter to continue..."
}

network_status() {
    show_header
    echo -e "${YELLOW}Network Status${NC}"
    echo "IP Addresses:"
    ip -brief addr show | grep UP
    echo
    echo "Connections:"
    ss -tun | grep ESTAB | wc -l | xargs echo "Active connections:"
    echo
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    read -rn1 choice
    echo
    
    case $choice in
        1) system_info ;;
        2) echo "Not implemented"; sleep 1 ;;
        3) echo "Not implemented"; sleep 1 ;;
        4) echo "Not implemented"; sleep 1 ;;
        5) disk_usage ;;
        6) network_status ;;
        q|Q) echo -e "${GREEN}Goodbye!${NC}"; break ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
done
```

### Example 3: CLI Tool with Options
```bash
#!/bin/bash
# Professional CLI with getopts

VERSION="1.0.0"

usage() {
    cat << EOF
Usage: $s [OPTIONS]

Description of the tool

OPTIONS:
    -h          Show this help message
    -v          Show version
    -n NAME     Set name (required)
    -a AGE      Set age (optional)
    -q          Quiet mode
    -d          Debug mode

EXAMPLES:
    $s -n John -a 25
    $s -n Jane -q

EOF
}

# Default values
NAME=""
AGE=""
VERBOSE=true
DEBUG=false

# Parse options
while getopts "hvn:a:qd" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        v)
            echo "Version: $VERSION"
            exit 0
            ;;
        n)
            NAME=$OPTARG
            ;;
        a)
            AGE=$OPTARG
            ;;
        q)
            VERBOSE=false
            ;;
        d)
            DEBUG=true
            ;;
        \?)
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

# Validate
if [ -z "$NAME" ]; then
    echo "Error: Name is required"
    echo "Use -h for help"
    exit 1
fi

# Debug mode
if [ "$DEBUG" = true ]; then
    set -x
fi

# Main logic
$VERBOSE && echo "Starting with name: $NAME"
[ -n "$AGE" ] && $VERBOSE && echo "Age: $AGE"

echo "Processing complete!"
```

---

## 📋 Best Practices Checklist

- [ ] Use `#!/bin/bash` (not sh)
- [ ] Use `set -euo pipefail`
- [ ] Use quotes around variables
- [ ] Check required arguments
- [ ] Validate input data
- [ ] Use descriptive variable names
- [ ] Add comments for complex logic
- [ ] Use functions for reusable code
- [ ] Use exit codes properly
- [ ] Log important actions
- [ ] Handle signals (Ctrl+C)
- [ ] Test edge cases

---

## 🎓 Final Project: Complete Admin Script

```bash
#!/bin/bash
# Complete System Admin Toolbox
# Save as: sysadmin.sh
# chmod +x sysadmin.sh

NAME="System Admin Toolbox"
VERSION="1.0.0"

# Options
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

die() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

usage() {
    cat << EOF
$NAME v$VERSION

Usage: $s [COMMAND] [OPTIONS]

COMMANDS:
    sysinfo      Show system information
    disks        Show disk usage
    memory       Show memory usage  
    processes    Show top processes
    network      Show network status
    services     Manage system services
    backup       Backup directories
    log [file]   View system logs
    
OPTIONS:
    -h, --help   Show this help
    -v, --version Show version

EOF
}

main() {
    local cmd=${1:-}
    
    case $cmd in
        sysinfo)
            echo -e "${CYAN}=== System Information ===${NC}"
            echo "Hostname: $(hostname)"
            echo "OS: $(uname -s)"
            echo "Kernel: $(uname -r)"
            echo "Uptime: $(uptime -p)"
            echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
            ;;
        disks)
            echo -e "${CYAN}=== Disk Usage ===${NC}"
            df -h | grep -v tmpfs
            ;;
        memory)
            echo -e "${CYAN}=== Memory Usage ===${NC}"
            free -h
            ;;
        processes)
            echo -e "${CYAN}=== Top Processes (Memory) ===${NC}"
            ps aux --sort=-%mem | head -11
            ;;
        network)
            echo -e "${CYAN}=== Network Status ===${NC}"
            ip -brief addr show | grep UP
            echo
            netstat -tun 2>/dev/null | grep ESTAB || ss -tun | grep ESTAB
            ;;
        -h|--help|help)
            usage
            ;;
        -v|--version)
            echo "$VERSION"
            ;;
        "")
            usage
            ;;
        *)
            die "Unknown command: $cmd"
            ;;
    esac
}

main "$@"
```

---

## 🏆 CORE BASH MILESTONE REACHED

You have completed the **first 12 stacks** of the Bash course.

---

## 📋 Core Summary: 12 STACKS COMPLETED

| Stack | Topic | Status |
|-------|-------|--------|
| 1 | Bash Fundamentals | ✅ |
| 2 | File & Directory Operations | ✅ |
| 3 | File Viewing & Editing | ✅ |
| 4 | Text Processing | ✅ |
| 5 | Variables & Data Types | ✅ |
| 6 | Control Flow (if/else, case) | ✅ |
| 7 | Loops (for, while, until) | ✅ |
| 8 | Functions | ✅ |
| 9 | Input/Output & Redirection | ✅ |
| 10 | Regular Expressions | ✅ |
| 11 | Process Management | ✅ |
| 12 | Advanced Scripting | ✅ |

---

## 🎯 What's Next?

### Practice Projects to Build
1. ✅ System monitoring dashboard
2. ✅ Automated backup system
3. ✅ Log analysis tool
4. ✅ User management system
5. ✅ Network scanner
6. ✅ File organizer

### Resources for Continued Learning
- `man bash` - Full bash manual
- `help set` - Shell options
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [Advanced Bash Scripting Guide](https://tldp.org/LDP/abs/html/)

---

## ✅ Stack 12 Complete!

Congratulations! You've successfully completed the core foundation of professional Bash scripting! You can now:
- ✅ **Write robust scripts** with strict error handling (`set -euo pipefail`)
- ✅ **Manage system signals** and clean up resources using `trap`
- ✅ **Parse complex arguments** like a professional CLI using `getopts`
- ✅ **Implement logging** and auditing for production environments
- ✅ **Structure large projects** using modular functions and source files
- ✅ **Debug complex issues** using tracing and dry-run modes

### What's Next?
Before we dive into scheduling and automation, we'll take a short detour into **Stack 12B: Bash Portability & POSIX**. You'll learn how to write scripts that work on any Linux or Unix system, not just those with modern Bash!

**Next: Stack 12B - Bash Portability & POSIX →**

---

*End of Stack 12 milestone*
