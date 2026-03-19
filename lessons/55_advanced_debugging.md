# 🔍 STACK 55: ADVANCED DEBUGGING & PROFILING
## Master Script Troubleshooting

---

## 🔰 What You'll Learn
- Advanced debugging techniques
- Performance profiling
- Memory analysis
- Tracing system calls
- Memory leak detection

---

## 🐛 Debug Modes

### Set Debug Options
```bash
#!/bin/bash
# debug_modes.sh

# Display all commands before execution
set -x          # Or: set -o xtrace

# Exit on error
set -e          # Or: set -o errexit

# Unset variables are errors
set -u          # Or: set -o nounset

# Pipe failures cause exit
set -o pipefail

# Combine all for strict debugging
set -euo pipefail -x

# Disable debugging
set +x
```

### Debug Function
```bash
#!/bin/bash
# debug_function.sh

DEBUG=false
VERBOSE=false

debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $*"
    fi
}

verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "[VERBOSE] $*"
    fi
}

# Conditional debug
debug "Processing file: $filename"

# With timestamp
debug() {
    [ "$DEBUG" = true ] && echo "[$(date '+%H:%M:%S')] DEBUG: $*"
}
```

---

## 📊 Tracing Execution

### PS4 - Prompt String
```bash
#!/bin/bash
# trace_with_line.sh

# Custom trace output with line numbers
export PS4='+${BASH_SOURCE}:${LINENO}> '

set -x

function my_function {
    local var="hello"
    echo "$var"
}

my_function

set +x
```

### Execution Trace
```bash
#!/bin/bash
# execution_trace.sh

# Log all commands to file
exec 3>&2 2>/tmp/trace_$$.log

set -x

# Your script here
ls -la /tmp
echo "Hello"

set +x

exec 2>&3 3>&-

echo "Trace saved to /tmp/trace_$$.log"
```

---

## ⏱️ Time Measurement

### Simple Timing
```bash
#!/bin/bash
# timing.sh

# Using time builtin
time ls -la

# Using date
start=$(date +%s)
# ... do work ...
end=$(date +%s)
echo "Elapsed: $((end - start)) seconds"

# High precision
start=$(date +%s.%N)
# ... work ...
end=$(date +%s.%N)
echo "Elapsed: $(echo "$end - $start" | bc) seconds"
```

### Function Timing
```bash
#!/bin/bash
# function_timing.sh

# Time each function
time_function() {
    local func=$1
    shift
    
    local start=$(date +%s.%N)
    "$func" "$@"
    local end=$(date +%s.%N)
    
    local elapsed=$(echo "$end - $start" | bc)
    echo "Function $func took $elapsed seconds"
}

slow_function() {
    sleep 2
    echo "Done"
}

time_function slow_function
```

---

## 📈 Performance Profiling

### Line-by-Line Profiling
```bash
#!/bin/bash
# profiler.sh

# Bash profiler - measure execution time per line
declare -A LINE_TIMES

profile_line() {
    local line=$1
    local start=$2
    local end=$(date +%s.%N)
    local elapsed=$(echo "$end - $start" | bc)
    
    LINE_TIMES["$line"]=$(echo "${LINE_TIMES[$line]:-0} + $elapsed" | bc)
}

# Instrument your script
PROFILE=false

if [ "$PROFILE" = true ]; then
    trap 'profile_line "LINENUM" "$(date +%s.%N)"' DEBUG
fi

# Your code
echo "Line 1"
sleep 0.1
echo "Line 2"
sleep 0.2
echo "Line 3"

if [ "$PROFILE" = true ]; then
    for line in "${!LINE_TIMES[@]}"; do
        echo "Line $line: ${LINE_TIMES[$line]}s"
    done
fi
```

### Using built-in TIMEFORMAT
```bash
#!/bin/bash
# builtin_timing.sh

# Configure time output
TIMEFORMAT='Real: %3R | User: %3U | System: %3S | CPU: %P'

time {
    # Your code block
    for i in {1..1000}; do
        echo "$i" > /dev/null
    done
}
```

---

## 🔎 Bash Debugger

### trap DEBUG
```bash
#!/bin/bash
# trap_debug.sh

# Execute before each command
trap 'echo "EXECUTING: $BASH_COMMAND (Line $LINENO)"' DEBUG

# Execute on error
trap 'echo "ERROR at line $LINENO: $BASH_COMMAND"' ERR

echo "Starting script"
ls /nonexistent
echo "This wont run"
```

### Conditional Debug
```bash
#!/bin/bash
# conditional_debug.sh

DEBUG=false

if [ "$DEBUG" = true ]; then
    trap 'echo "CMD: $BASH_COMMAND | ARGS: $*"' DEBUG
    
    # Verbose error reporting
    trap 'echo "Error on line $LINENO"' ERR
fi

set -u

# Your script
echo "Starting..."
missing_var=$nonexistent
echo "Done"
```

---

## 🐛 Common Issues & Solutions

### Variable Scope Issues
```bash
#!/bin/bash
# scope_debug.sh

# Debug subshell variables
outer_var="original"

# Without seeing subshell changes
(
    inner_var="inside subshell"
    outer_var="changed"
    echo "Subshell: outer_var = $outer_var"
)

echo "Parent: outer_var = $outer_var"
# Shows: original (unchanged because subshell)

# Debug with explicit output
(
    inner_var="inside subshell"
    echo "DEBUG: inner_var = $inner_var"
) | tee /dev/stderr
```

### Array Issues
```bash
#!/bin/bash
# array_debug.sh

# Debug array issues
arr=(one two three)

# Check array contents
echo "All elements: ${arr[@]}"
echo "Array length: ${#arr[@]}"
echo "Indices: ${!arr[@]}"

# Debug expansion
set -x
echo ${arr[0]}
set +x

# Proper array access
for i in "${!arr[@]}"; do
    echo "$i: ${arr[$i]}"
done
```

---

## 📊 Resource Monitoring

### Memory Usage
```bash
#!/bin/bash
# memory_debug.sh

# Get memory usage of current process
get_memory() {
    if [ -f /proc/$$/status ]; then
        grep VmRSS /proc/$$/status
    else
        ps -o rss= -p $$
    fi
}

# Monitor during execution
echo "Initial memory: $(get_memory)"

# Create large array
large_array=()
for i in {1..10000}; do
    large_array+=("data_$i")
done

echo "After allocation: $(get_memory)"

# Clear array
unset large_array

echo "After cleanup: $(get_memory)"
```

### CPU Profiling
```bash
#!/bin/bash
# cpu_profile.sh

# Monitor CPU during execution
pid=$$
interval=0.1

monitor_cpu() {
    while kill -0 $pid 2>/dev/null; do
        cpu=$(ps -p $pid -o %cpu= | tr -d ' ')
        echo "CPU: $cpu%"
        sleep $interval
    done
}

# Run CPU monitor in background
monitor_cpu &
MONITOR_PID=$!

# Your code to profile
for i in {1..100}; do
    result=$((i * i))
done

# Stop monitoring
kill $MONITOR_PID 2>/dev/null
wait 2>/dev/null
```

---

## 🔍 ShellCheck Integration

### Running ShellCheck
```bash
#!/bin/bash
# shellcheck_analysis.sh

# Check script for issues
shellcheck -s bash myscript.sh

# With all options
shellcheck -x -S error -s bash myscript.sh

# CI/CD integration
if ! shellcheck -s bash -x myscript.sh; then
    echo "ShellCheck failed!"
    exit 1
fi

# Ignore specific rules
# shellcheck disable=SC1090,SC1091
source mylib.sh
```

### Common Warnings
```bash
#!/bin/bash
# common_warnings.sh

# SC2086: Quote variables
name="John Doe"
# Wrong: echo $name
# Right: echo "$name"

# SC2166: Use [ -o ] instead of [[ ]]
# Wrong: [[ $a == "x" || $a == "y" ]]
# Right: [[ $a == "x" || $a == "y" ]]

# SC2128: Expanding array without index
# Wrong: arr=(1 2 3); echo $arr
# Right: echo "${arr[0]}" or echo "${arr[@]}"

# SC2145: Embed variables in strings
# Wrong: echo "Value: $arr"
# Right: echo "Value: ${arr[@]}"
```

---

## 🏆 Practice Exercises

### Exercise 1: Debug Your Script
Add debugging to find bugs in a complex script

### Exercise 2: Create Profiler
Build a simple profiler that times each line

### Exercise 3: Memory Analysis
Find memory leaks in a script

---

## ✅ Stack 55 Complete!

You learned:
- ✅ Debug modes (set -x, set -e, etc.)
- ✅ Execution tracing
- ✅ Performance profiling
- ✅ Function timing
- ✅ trap DEBUG
- ✅ Memory and CPU monitoring
- ✅ ShellCheck integration

### Next: Stack 56 - Security Auditing & Forensics →

---

*End of Stack 55*