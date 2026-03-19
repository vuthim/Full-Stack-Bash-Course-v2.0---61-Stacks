#!/bin/bash
# Stack 11 Solution: Process Management

# ================ VIEWING PROCESSES ================

echo "=== Viewing Processes ==="

# Basic process list
echo "Current processes (top 5 by memory):"
ps aux --sort=-%mem | head -6

echo ""
echo "Current shell PID: $$"
echo "Parent PID: $PPID"

# Find specific process
echo ""
echo "Looking for bash processes:"
ps aux | grep bash | grep -v grep

# ================ PROCESS SIGNALS ================

echo ""
echo "=== Process Signals ==="

# Create a background process
(sleep 30) &
bg_pid=$!
echo "Started background process: $bg_pid"

# Send signal to process
kill -0 $bg_pid 2>/dev/null && echo "Process $bg_pid is running"
kill -TERM $bg_pid 2>/dev/null && echo "Sent TERM to $bg_pid"

# List common signals
echo ""
echo "Common signals:"
echo "  SIGTERM (15) - Graceful termination"
echo "  SIGKILL (9)  - Force kill"
echo "  SIGHUP (1)   - Hangup - reload config"
echo "  SIGINT (2)   - Interrupt (Ctrl+C)"

# ================ JOB CONTROL ================

echo ""
echo "=== Job Control ==="

# List jobs
jobs -l

# Background a process
echo "Starting background task..."
sleep 5 &
sleep 3 &
echo "Jobs:"
jobs -l

# Bring to foreground
fg %1 2>/dev/null &
sleep 1

# ================ PROCESS MONITORING ================

echo ""
echo "=== Process Monitoring ==="

# Top processes
echo "Top 5 CPU processes:"
ps aux --sort=-%cpu | head -6

echo ""
echo "Top 5 memory processes:"
ps aux --sort=-%mem | head -6

# Find process by name
echo ""
echo "Finding processes by name:"
pgrep -la bash

# Watch command (simulate with loop)
echo ""
echo "Memory usage snapshot:"
free -h | grep Mem

# ================ KILLING PROCESSES ================

echo ""
echo "=== Killing Processes ==="

# Kill by PID
# kill $(pgrep process_name)

# Kill all by name
# pkill process_name

# Force kill
# kill -9 $(pgrep process_name)

# Kill processes by user
# pkill -u username

# Example: kill zombie processes
echo "Finding zombie processes:"
ps aux | grep -w Z

# ================ PRIORITY AND NICE ================

echo ""
echo "=== Priority (Nice) ==="

# Run with nice priority (lower priority = nicer to others)
# nice -n 10 ./script.sh

# Change priority of running process
# renice 5 -p PID

echo "Current nice value:"
nice

# ================ TIMEOUT ================

echo ""
echo "=== Timeout ==="

# Run command with timeout
echo "Running 'sleep 2' with timeout 1..."
timeout 1 sleep 2 && echo "Completed" || echo "Timed out!"

# ================ WAIT FOR PROCESS ================

echo ""
echo "=== Wait for Process ==="

# Start background process
sleep 2 &
pid=$!
echo "Waiting for process $pid..."
wait $pid
echo "Process completed!"

# ================ PROCESS SUBSTITUTION ================

echo ""
echo "=== Process Substitution ==="

# Compare outputs
diff <(ps aux | head -5) <(ps aux | head -5) && echo "Same output"

# ================ REAL-WORLD EXAMPLES ================

echo ""
echo "=== Practical Examples ==="

# Monitor process until it exits
monitor_process() {
    local pid=$1
    while kill -0 $pid 2>/dev/null; do
        echo "Process $pid is still running..."
        sleep 2
    done
    echo "Process $pid finished"
}

# Process monitoring script
echo "Simple process monitor:"
ps aux | awk 'NR<=3 {printf "%-10s %s\n", $2, $11}'

# Find top CPU consuming processes
echo ""
echo "Top CPU consumers:"
ps -eo pid,pcpu,comm --no-headers | sort -k2 -rn | head -3