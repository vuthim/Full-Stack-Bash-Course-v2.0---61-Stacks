# 🔝 STACK 45: ADVANCED BASH PATTERNS
## Pro-Level Scripting Techniques

---

## 🔰 Advanced Concepts

### What You'll Learn
- State machines in Bash
- Advanced functions
- Process substitution
- Complex pipelines
- Performance optimization

---

## 🤖 State Machines

### Basic State Machine
```bash
#!/bin/bash
# state_machine.sh

STATE="START"

while [ "$STATE" != "DONE" ]; do
    case "$STATE" in
        START)
            echo "Starting..."
            # Do startup tasks
            STATE="RUNNING"
            ;;
        RUNNING)
            echo "Running main loop..."
            # Process data
            if [ "$TASK_DONE" = "true" ]; then
                STATE="CLEANUP"
            fi
            ;;
        CLEANUP)
            echo "Cleaning up..."
            STATE="DONE"
            ;;
    esac
done

echo "Complete!"
```

### Event-Driven State Machine
```bash
#!/bin/bash
# event_machine.sh

EVENT="$1"
STATE_FILE="/tmp/state"

get_state() { cat "$STATE_FILE" 2>/dev/null || echo "idle"; }
set_state() { echo "$1" > "$STATE_FILE"; }

case "$(get_state)" in
    idle)
        case "$EVENT" in
            start) set_state "running" ;;
        fi
        ;;
    running)
        case "$EVENT" in
            stop) set_state "stopping" ;;
            pause) set_state "paused" ;;
        fi
        ;;
esac
```

---

## 🔄 Advanced Functions

### Return Values
```bash
#!/bin/bash
# functions.sh

# Return string using stdout
get_message() {
    echo "Hello, $1!"
}

result=$(get_message "World")
echo "$result"

# Return status (0-255)
is_even() {
    if [ $(( $1 % 2)) -eq 0 ]; then
        return 0  # Success (true)
    else
        return 1  # Failure (false)
    fi
}

if is_even 4; then
    echo "Even"
fi
```

### Local Variables and Recursion
```bash
#!/bin/bash
# recursion.sh

factorial() {
    local n=$1
    if [ $n -le 1 ]; then
        echo 1
    else
        local prev=$(factorial $((n-1)))
        echo $((n * prev))
    fi
}

echo "Factorial of 5: $(factorial 5)"
```

---

## 🔗 Process Substitution

### Compare Files
```bash
# Compare output of two commands
diff <(ls -la /bin) <(ls -la /usr/bin)

# While reading from process
while read -r line; do
    echo "Processing: $line"
done < <(grep "ERROR" /var/log/syslog)
```

### Join Files
```bash
# Join two sorted files
join <(sort file1.txt) <(sort file2.txt)
```

---

## ⚡ Performance Optimization

### Use Built-ins vs External Commands
```bash
# Slower (fork external process)
for i in $(seq 1 1000); do
    # ...
done

# Faster (bash built-in)
for i in {1..1000}; do
    # ...
done
```

### Use Arrays Instead of Pipes
```bash
# Slower
result=$(echo "$text" | tr '[:upper:]' '[:lower:]')

# Faster
result="${text,,}"
```

### Cache Expensive Operations
```bash
#!/bin/bash
# cache.sh

# Cache system info
CACHE_FILE="/tmp/sysinfo.cache"
CACHE_TTL=300  # 5 minutes

get_sysinfo() {
    if [ -f "$CACHE_FILE" ]; then
        cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
        if [ "$cache_age" -lt "$CACHE_TTL" ]; then
            cat "$CACHE_FILE"
            return
        fi
    fi
    
    # Generate fresh info
    uname -a > "$CACHE_FILE"
    cat "$CACHE_FILE"
}
```

---

## 📦 Dry Run Mode

### Implement Dry Run
```bash
#!/bin/bash
# dryrun.sh

DRY_RUN=false

log_action() {
    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY RUN] Would: $*"
    else
        echo "[EXECUTING] $*"
        "$@"
    fi
}

# Test with -n flag
if [ "${1:-}" = "-n" ]; then
    DRY_RUN=true
    shift
fi

log_action rm -rf /tmp/test
log_action cp file.txt /backup/
```

---

## 🏗️ Advanced Script Structure

### Modular Script Template
```bash
#!/bin/bash
# app.sh

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="$SCRIPT_DIR/config.sh"

# Source files
source "$CONFIG_FILE"

# Globals
declare ACTION=""

# Functions
usage() { ...; }
check_prereqs() { ...; }
action_create() { ...; }
action_delete() { ...; }
action_list() { ...; }
main() { ...; }

# Entry point
main "$@"
```

---

## 📋 Best Practices Summary

### Code Organization
```bash
# Constants first
readonly MAX_RETRIES=3
readonly TIMEOUT=30

# Functions second
function do_something() { ...; }

# Main logic last
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    main "$@"
fi
```

---

## 🏆 Practice Exercises

### Exercise 1: Create State Machine
```bash
# Implement a simple state machine
# START -> PROCESS -> END
# With events: next, error
```

### Exercise 2: Performance Test
```bash
# Compare timing of external vs built-in
time for i in $(seq 1 10000); do echo $i > /dev/null; done
time for i in {1..10000}; do echo $i > /dev/null; done
```

### Exercise 3: Add Dry Run
```bash
# Add -n flag to previous scripts
# Test both modes
```

---

## ✅ Stack 45 Complete!

You learned:
- ✅ State machines in Bash
- ✅ Advanced functions
- ✅ Process substitution
- ✅ Performance optimization
- ✅ Dry run mode
- ✅ Best practices

### Next: Stack 46 - Career & Production →

---

*End of Stack 45*