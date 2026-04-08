# 🔄 STACK 54: IPC & INTER-PROCESS COMMUNICATION
## Advanced Process Communication in Bash

**What is IPC?** Think of IPC (Inter-Process Communication) like different ways people can communicate: face-to-face (pipes), leaving notes (files), phone calls (sockets), or signals (hand gestures). Processes need to talk to each other too, and IPC is how they do it!

**Why This Matters:** Understanding IPC lets you build complex systems where multiple scripts work together - like a team of specialists collaborating on a project.

---

## 🔰 What You'll Learn

| Concept | What It Is | Real-World Analogy |
|---------|------------|-------------------|
| **Named pipes (FIFOs)** | Persistent communication channel | A dedicated phone line between two offices |
| **Shared memory** | Multiple processes read/write same memory | A shared whiteboard everyone can see |
| **Signal handling** | Sending notifications between processes | Tapping someone on the shoulder |
| **Process synchronization** | Coordinating timing between processes | Traffic lights coordinating flow |
| **Unix domain sockets** | Local inter-process communication | An internal phone system within a building |

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

## 🎓 Final Project: The Bash IPC Manager

Now that you've mastered how processes talk to each other, let's see how a professional systems engineer might build a tool to manage these communications. We'll examine the "IPC Manager" — a script that demonstrates several Inter-Process Communication (IPC) techniques, including named pipes, signal handling, and file locking.

### What the Bash IPC Manager Does:
1. **Creates Named Pipes (FIFOs)** to send data between two completely separate terminal windows.
2. **Implements Signal Traps** to gracefully handle interruptions like `Ctrl+C` (SIGINT).
3. **Uses File Locking** (`flock`) to prevent two scripts from trying to edit the same file at once.
4. **Utilizes Shared Memory** (`/dev/shm`) for high-speed data exchange between processes.
5. **Provides a Modular CLI** to test each communication method independently.
6. **Automates Cleanup** by removing temporary pipes and lock files when finished.

### Key Snippet: Named Pipe Communication
A named pipe allows one script to "write" and another to "read" even if they weren't started together. The manager automates the creation and cleanup of this "virtual tunnel".

```bash
pipe_example() {
    local pipe_path="/tmp/my_tunnel_$$"
    
    # mkfifo: Create the special "pipe" file
    mkfifo "$pipe_path"
    
    echo "Writing data to the tunnel..."
    # The '&' runs the write in the background so we can read it below
    echo "Secret Message from Process A" > "$pipe_path" &
    
    echo "Reading data from the tunnel..."
    cat "$pipe_path"
    
    # Always clean up your pipes!
    rm "$pipe_path"
}
```

### Key Snippet: Preventing Conflicts with flock
The manager uses `flock` to ensure that only one instance of a script can perform a "protected" action at a time.

```bash
lock_example() {
    local lockfile="/tmp/script.lock"
    
    # 9: A file descriptor for the lock
    (
        # -n: non-blocking (fail if lock is already held)
        flock -n 9 || { echo "ERROR: Another process is already running!"; exit 1; }
        
        echo "Lock acquired. Performing safe operation..."
        sleep 5
    ) 9>"$lockfile"
}
```

**Pro Tip:** Using IPC mechanisms is how you turn a collection of individual scripts into a unified "Distributed System" that works together!

---

## ✅ Stack 54 Complete!

Congratulations! You've successfully taught your scripts how to "talk" to each other! You can now:
- ✅ **Use Named Pipes (FIFOs)** for cross-script communication
- ✅ **Handle System Signals** (SIGINT, SIGTERM) like a professional
- ✅ **Implement File Locking** to prevent data corruption and race conditions
- ✅ **Utilize Shared Memory** for high-performance data exchange
- ✅ **Master Process Substitution** for advanced data piping
- ✅ **Build coordinated systems** where multiple scripts work in harmony

### What's Next?
In the next stack, we'll dive into **Advanced Debugging & Profiling**. You'll learn the secret techniques for finding impossible bugs and optimizing your code for maximum speed!

**Next: Stack 55 - Advanced Debugging & Profiling →**

---

*End of Stack 54*