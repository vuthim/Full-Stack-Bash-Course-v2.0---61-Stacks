# 🔄 STACK 54: IPC & INTER-PROCESS COMMUNICATION
## Advanced Process Communication in Bash

---

## 🔰 What You'll Learn
- Named pipes (FIFOs)
- Shared memory concepts
- Signal handling
- Process synchronization
- Unix domain sockets

---

## � Named Pipes (FIFOs)

### Creating & Using FIFOs
```bash
#!/bin/bash
# fifo_basics.sh

# Create a named pipe
FIFO_PATH="/tmp/my_fifo"
mkfifo "$FIFO_PATH"

# In another terminal, read from the pipe
# cat /tmp/my_fifo

# Write to the pipe
echo "Hello from process 1" > "$FIFO_PATH"

# Cleanup
rm -f "$FIFO_PATH"
```

### Producer-Consumer Pattern
```bash
#!/bin/bash
# producer_consumer.sh

FIFO="/tmp/data_pipe"
mkfifo "$FIFO"

# Producer process
producer() {
    for i in {1..10}; do
        echo "Item $i" > "$FIFO"
        echo "Produced: Item $i"
        sleep 1
    done
    echo "DONE" > "$FIFO"
}

# Consumer process  
consumer() {
    while true; do
        read -r data < "$FIFO"
        if [ "$data" = "DONE" ]; then
            break
        fi
        echo "Consumed: $data"
    done
}

# Run both
producer &
consumer &

wait
rm -f "$FIFO"
```

### Multi-Process Data Processing
```bash
#!/bin/bash
# parallel_processing.sh

INPUT_FIFO="/tmp/input"
OUTPUT_FIFO="/tmp/output"
mkfifo "$INPUT_FIFO" "$OUTPUT_FIFO"

# Start workers
worker() {
    local id=$1
    while true; do
        read -r line < "$INPUT_FIFO"
        if [ "$line" = "STOP" ]; then
            echo "Worker $id stopping" > "$OUTPUT_FIFO"
            break
        fi
        # Process data
        result=$(echo "$line" | tr '[:lower:]' '[:upper:]')
        echo "Worker $id: $result" > "$OUTPUT_FIFO"
    done
}

# Start 3 workers
worker 1 &
worker 2 &
worker 3 &

# Send data
for item in apple banana cherry date; do
    echo "$item" > "$INPUT_FIFO"
done

# Signal workers to stop
for w in {1..3}; do
    echo "STOP" > "$INPUT_FIFO"
done

# Collect results
for w in {1..3}; do
    read -r result < "$OUTPUT_FIFO"
    echo "$result"
done

wait
rm -f "$INPUT_FIFO" "$OUTPUT_FIFO"
```

---

## 📡 Process Substitution Advanced

### Real-Time Processing
```bash
#!/bin/bash
# process_sub.sh

# Monitor multiple log files in real-time
tail -f /var/log/syslog /var/log/auth.log 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "error\|failed"; then
        echo -e "\033[0;31m[ALERT]\033[0m $line"
    else
        echo "$line"
    fi
done

# Compare directories
diff -rq <(ls -1 /dir1 | sort) <(ls -1 /dir2 | sort)

# Join operations
join <(awk -F: '{print $1,$3}' /etc/passwd | sort) \
     <(awk -F: '{print $1,$3}' /etc/group | sort)
```

---

## 🔔 Signal Handling

### Basic Signal Handling
```bash
#!/bin/bash
# signal_handling.sh

# Handle SIGINT (Ctrl+C)
trap 'echo "Caught SIGINT!"; exit 1' SIGINT

# Handle SIGTERM
trap 'echo "Cleaning up..."; rm -f /tmp/*.tmp; exit 0' SIGTERM

# Handle EXIT (cleanup on any exit)
trap 'echo "Final cleanup"' EXIT

# Custom signal
trap 'echo "Got USR1"' SIGUSR1

echo "PID: $$"
echo "Press Ctrl+C to test, or: kill -USR1 $$"

# Long-running task
for i in {1..1000}; do
    echo "Working... $i"
    sleep 1
done
```

### Graceful Shutdown
```bash
#!/bin/bash
# graceful_shutdown.sh

PID_FILE="/tmp/myapp.pid"
RUNNING=true

# Cleanup function
cleanup() {
    echo "Shutting down gracefully..."
    RUNNING=false
    
    # Kill child processes
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi
    
    echo "Cleanup complete"
    exit 0
}

trap cleanup SIGTERM SIGINT SIGHUP

# Save PID
echo $$ > "$PID_FILE"

echo "Server started (PID: $$)"
echo "Send SIGTERM to stop"

# Main loop
while $RUNNING; do
    echo "Processing..."
    sleep 1
done
```

---

## 🔒 File Locking

### Using flock
```bash
#!/bin/bash
# file_locking.sh

LOCK_FILE="/tmp/myapp.lock"

# Lock with timeout
acquire_lock() {
    exec 200>"$LOCK_FILE"
    flock -w 30 200 || {
        echo "Could not acquire lock"
        exit 1
    }
    echo "Lock acquired by PID $$"
}

release_lock() {
    flock -u 200
    rm -f "$LOCK_FILE"
    echo "Lock released"
}

# Usage
acquire_lock

# Critical section
echo "Performing critical operation..."
sleep 10

release_lock
```

### Advisory Locking
```bash
#!/bin/bash
# advisory_lock.sh

# Simple lock using lockfile
lockfile="/tmp/app.lock"

acquire() {
    while [ -f "$lockfile" ]; do
        echo "Waiting for lock..."
        sleep 1
    done
    touch "$lockfile"
    echo "$$" > "$lockfile"
}

release() {
    rm -f "$lockfile"
}

acquire
# Do work
cp /source /dest
release
```

---

## ⚡ Using /dev Filesystem

### Process Communication via /dev
```bash
#!/bin/bash
# dev_filesystem.sh

# Write to /dev/tty for user input
echo "Special prompt" > /dev/tty
read response < /dev/tty

# Read from /dev/urandom
# Get random data
head -c 32 /dev/urandom | base64

# Zero device (fast wipe)
# dd if=/dev/zero of=/dev/sdb bs=1M  # DANGEROUS!

# Null device uses
# Silence output
command > /dev/null 2>&1

# Read empty input
while read line < /dev/null; do
    echo "$line"
done

# Using /dev/fd
echo "File descriptor: /dev/fd/1"
```

---

## 🔗 IPC with Temporary Files

### Queue Implementation
```bash
#!/bin/bash
# queue.sh

QUEUE_DIR="/tmp/queue_$$"
mkdir -p "$QUEUE_DIR/enqueued" "$QUEUE_DIR/dequeued"

enqueue() {
    local item=$1
    local timestamp=$(date +%s%N)
    echo "$item" > "$QUEUE_DIR/enqueued/${timestamp}_${item}"
}

dequeue() {
    local item=$(ls -1 "$QUEUE_DIR/enqueued/" 2>/dev/null | head -1)
    if [ -n "$item" ]; then
        mv "$QUEUE_DIR/enqueued/$item" "$QUEUE_DIR/dequeued/"
        cat "$QUEUE_DIR/dequeued/$item"
    fi
}

# Producer
for i in {1..5}; do
    enqueue "task_$i"
done

# Consumer
for i in {1..5}; do
    echo "Processing: $(dequeue)"
done

# Cleanup
rm -rf "$QUEUE_DIR"
```

---

## 🔄 Inter-Process Communication Patterns

### Message Passing
```bash
#!/bin/bash
# message_passing.sh

# Simple message queue using files
MSG_DIR="/tmp/messages_$$"
mkdir -p "$MSG_DIR"

send_message() {
    local to=$1
    local msg=$2
    local from=$3
    local id=$(date +%s%N)
    
    cat > "$MSG_DIR/$to" << EOF
FROM: $from
TIME: $(date)
MSG: $msg
ID: $id
EOF
    echo "Message sent to $to"
}

read_message() {
    local user=$1
    if [ -f "$MSG_DIR/$user" ]; then
        cat "$MSG_DIR/$user"
        rm -f "$MSG_DIR/$user"
    else
        echo "No messages"
    fi
}

# Send messages
send_message "user1" "Hello from admin" "admin"
send_message "admin" "Report complete" "user1"

# Check messages
echo "=== user1 mailbox ==="
read_message "user1"

echo "=== admin mailbox ==="
read_message "admin"

rm -rf "$MSG_DIR"
```

### Event System
```bash
#!/bin/bash
# event_system.sh

EVENT_DIR="/tmp/events_$$"
mkdir -p "$EVENT_DIR"

publish() {
    local event=$1
    local data=$2
    echo "$data" > "$EVENT_DIR/$event"
    echo "Event published: $event"
}

subscribe() {
    local event=$1
    inotifywait -m -e create "$EVENT_DIR" 2>/dev/null | \
    while read -r path action file; do
        if [ "$file" = "$event" ]; then
            echo "Event triggered: $(cat "$EVENT_DIR/$event")"
        fi
    done
}

# Publish events (in one terminal)
# publish "deploy" "Starting deployment..."
# publish "deploy" "Build complete"

# Subscribe (in another terminal)
# subscribe "deploy"

# Cleanup
rm -rf "$EVENT_DIR"
```

---

## 🏆 Practice Exercises

### Exercise 1: Chat System
Create a simple chat using named pipes

### Exercise 2: Process Pool
Implement a worker pool using FIFOs

### Exercise 3: Lock Manager
Create a locking mechanism for multiple processes

---

## ✅ Stack 54 Complete!

You learned:
- ✅ Named pipes (FIFOs)
- ✅ Process substitution
- ✅ Signal handling
- ✅ File locking (flock)
- ✅ /dev filesystem
- ✅ Message queues
- ✅ Event systems

### Next: Stack 55 - Advanced Debugging & Profiling →

---

*End of Stack 54*