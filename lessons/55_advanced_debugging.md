# 🔍 STACK 55: ADVANCED DEBUGGING & PROFILING
## Master Script Troubleshooting

**What is Debugging?** Think of debugging like being a detective. Your script isn't working as expected, and you need to gather clues (error messages, outputs, traces) to figure out WHY. Good debugging skills mean you solve mysteries in minutes instead of hours!

**Why This Matters:** Every developer spends MORE time debugging than writing code. Master these skills and you'll save hundreds of hours over your career.

---

## 🔰 What You'll Learn

| Skill | What It Does | When You Need It |
|-------|--------------|------------------|
| **Advanced debugging** | Step through scripts, inspect variables | Script behaving weirdly |
| **Performance profiling** | Find slow parts of your script | "Why is this taking so long?" |
| **Memory analysis** | Track memory usage and leaks | Script consuming too much RAM |
| **Tracing system calls** | See what your script is doing at OS level | "What files is it accessing?" |
| **Memory leak detection** | Find resources that aren't freed | Script gets slower over time |

### The Debugging Mindset
```
Beginner: "It's broken! I don't know why!" → Stuck
Expert:   "It's broken. Let me gather evidence..." → Solves it

The difference isn't knowledge - it's METHOD.
1. Reproduce the problem consistently
2. Isolate where it happens (which line/section)
3. Inspect what's actually happening vs what should happen
4. Fix and verify
```

**Pro Tip:** The most powerful debugging tool isn't a tool at all - it's EXPLAINING your code out loud (rubber duck debugging). Half the time, you'll find the bug while explaining!

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

## 🎓 Final Project: The Bash Debugging & Profiling Toolbox

Now that you've mastered the secret art of debugging, let's see how a professional systems engineer might build a "Diagnostic Command Center." We'll examine the "Debug Tools" — a comprehensive script that automates tracing, performance timing, and system-level analysis for your Bash code.

### What the Bash Debugging Toolbox Does:
1. **Automates Execution Tracing** using `set -x` to show you every line as it runs.
2. **Performs Precision Timing** to identify exactly which part of your script is slow.
3. **Audits Memory Usage** using the advanced `/usr/bin/time` utility for verbose reports.
4. **Simplifies System Tracing** (`strace`) to monitor how your script interacts with the Linux kernel.
5. **Audits Library Calls** (`ltrace`) to see which shared libraries are being used.
6. **Analyzes CPU Performance** using the professional `perf` profiler for deep-dive stats.

### Key Snippet: Automated Execution Tracing
Instead of manually editing your scripts to add `set -x`, you can run them through the toolbox to get an instant "trace" of their behavior.

```bash
cmd_trace() {
    local script_to_test=$1
    echo "=== Starting Full Execution Trace ==="
    
    # bash -x: Start a new bash shell with 'xtrace' (tracing) enabled
    # This allows you to debug ANY script without changing its code!
    bash -x "$script_to_test"
}
```

### Key Snippet: Kernel-Level Debugging with Strace
Sometimes the bug isn't in your code, but in how it talks to the system. The toolbox uses `strace -c` to provide a "summary" of all system calls.

```bash
cmd_strace() {
    shift # Remove the 'strace' command from the arguments
    local cmd_to_run="$*"
    
    echo "=== System Call Summary for: $cmd_to_run ==="
    # -c: Count and summarize system calls (reads, writes, opens, etc.)
    strace -c $cmd_to_run
    
    # Pro Tip: If you see thousands of 'open' calls, your script 
    # might be inefficiently searching for files!
}
```

**Pro Tip:** Advanced debugging is what separates "Junior" developers from "Senior" engineers. Knowing how to use these tools means you can fix in minutes what takes others hours!

---

## ✅ Stack 55 Complete!

Congratulations! You've successfully mastered the "X-Ray Vision" of the Linux world! You can now:
- ✅ **Debug any script** using advanced tracing (`set -x`, `bash -x`)
- ✅ **Identify performance bottlenecks** with precision timing and profiling
- ✅ **Monitor memory usage** and identify resource-heavy operations
- ✅ **Perform kernel-level auditing** using `strace` and `ltrace`
- ✅ **Use Trap DEBUG** to create your own custom step-through debuggers
- ✅ **Optimize your code** for maximum speed and efficiency

### What's Next?
In the next stack, we'll dive into **Security Auditing & Forensics**. You'll learn how to investigate system breaches, audit logs for "hacker" activity, and protect your servers from advanced threats!

**Next: Stack 56 - Security Auditing & Forensics →**

---

*End of Stack 55*
-- **Previous:** [Stack 54 → IPC Mechanisms](54_ipc_mechanisms.md)
-- **Next:** [Stack 56 - Security Auditing & Forensics](56_security_forensics.md)