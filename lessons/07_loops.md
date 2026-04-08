# 🔁 STACK 7: LOOPS
## Automating Repetitive Tasks

**What Are Loops?** Think of loops like an assembly line in a factory. Instead of manually processing each item one by one, you set up a machine that handles ALL of them automatically. "Do this thing, for every item in this list, until there are no more items."

**Why This Matters?** Loops are the foundation of automation. Need to resize 100 images? Restart 50 services? Process 1000 log files? Loops turn hours of manual work into a 10-second script!

---

## 🔄 For Loops

The `for` loop is the most common loop in bash. It goes through a list of items and does something with each one.

### Classic C-style For Loop (Counting)
```bash
for ((i=0; i<5; i++)); do
    echo "Counter: $i"
done

# Output:
# Counter: 0
# Counter: 1
# Counter: 2
# Counter: 3
# Counter: 4
```

### For...in Loop (Going Through a List)
```bash
# Loop through words
for color in red green blue; do
    echo "Color: $color"
done

# Loop through files
for file in *.txt; do
    echo "File: $file"
done

# Loop through directory
for item in /home/user/*; do
    echo "$item"
done
```

### For Loop with Range
```bash
# Simple range
for i in {1..5}; do
    echo $i
done

# Range with step
for i in {0..10..2}; do
    echo $i    # 0, 2, 4, 6, 8, 10
done

# Reverse range
for i in {5..1}; do
    echo $i    # 5, 4, 3, 2, 1
done
```

---

## ⏳ While Loops

### Basic While
```bash
count=0

while [ $count -lt 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

### While Read File
```bash
# Line by line
while read line; do
    echo "Line: $line"
done < file.txt

# Using file descriptor
while IFS= read -r line; do
    echo "$line"
done < "file.txt"

# Skip empty lines
while IFS= read -r line || [ -n "$line" ]; do
    echo "$line"
done < file.txt
```

### Infinite While Loop
```bash
while true; do
    echo "Press Ctrl+C to stop"
    sleep 2
done

# Or
while :; do
    echo "Running..."
    sleep 1
done
```

### Condition at End (do-while equivalent)
```bash
# Read at least once
while true; do
    read -p "Enter 'quit' to exit: " input
    [ "$input" == "quit" ] && break
done
```

---

## ⏲️ Until Loops

Execute until condition is TRUE (opposite of while)

```bash
count=0

until [ $count -ge 5 ]; do
    echo "Count: $count"
    ((count++))
done
# Same as while [ $count -lt 5 ]

# Until with command
until ping -c 1 google.com > /dev/null 2>&1; do
    echo "Waiting for network..."
    sleep 2
done
echo "Network is available!"
```

---

## 🔀 Loop Control

### Break - Exit the Loop
```bash
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        break    # Exit loop at i=5
    fi
    echo $i
done

# Break with condition
for file in *.txt; do
    [ "$file" == "stop.txt" ] && break
    echo "Processing $file"
done
```

### Continue - Skip Iteration
```bash
for i in {1..5}; do
    if [ $i -eq 3 ]; then
        continue    # Skip 3
    fi
    echo "Number: $i"
done
# Output: 1, 2, 4, 5 (skips 3)
```

### Labeled Loops (Breaking Nested Loops)
```bash
outer: for i in {1..3}; do
    for j in {1..3}; do
        echo "i=$i, j=$j"
        if [ $j -eq 2 ]; then
            break 2    # Break outer loop
        fi
    done
done
```

---

## 📖 Real-World Examples

### Example 1: Backup Files
```bash
#!/bin/bash
# Backup all .txt files

backup_dir="backup_$(date +%Y%m%d)"
mkdir -p "$backup_dir"

for file in *.txt; do
    if [ -f "$file" ]; then
        cp "$file" "$backup_dir/"
        echo "Backed up: $file"
    fi
done

echo "Backup complete! Files: $(ls $backup_dir | wc -l)"
```

### Example 2: Process List
```bash
#!/bin/bash
# Find and count processes

read -p "Enter process name: " proc_name

count=0
for pid in /proc/[0-9]*; do
    cmd=$(cat "$pid/comm" 2>/dev/null)
    if [[ "$cmd" == *"$proc_name"* ]]; then
        echo "PID: $(basename $pid) - $cmd"
        ((count++))
    fi
done

echo "Total: $count processes"
```

### Example 3: Menu System with Loop
```bash
#!/bin/bash

while true; do
    clear
    echo "====== Menu ======"
    echo "1. Show date"
    echo "2. Show users"
    echo "3. Show uptime"
    echo "4. Exit"
    echo "================="
    
    read -p "Choose: " choice
    
    case $choice in
        1) date ;;
        2) who ;;
        3) uptime ;;
        4) echo "Goodbye!"; break ;;
        *) echo "Invalid option" ;;
    esac
    
    read -p "Press Enter to continue..."
done
```

### Example 4: Read File Line by Line
```bash
#!/bin/bash
# Count lines and words in a file

if [ -z "$1" ]; then
    echo "Usage: $s <filename>"
    exit 1
fi

lines=0
words=0

while IFS= read -r line || [ -n "$line" ]; do
    ((lines++))
    # Count words
    for word in $line; do
        ((words++))
    done
done < "$1"

echo "Lines: $lines"
echo "Words: $words"
```

### Example 5: Interactive User Input
```bash
#!/bin/bash
# Add users from input

users=()

while true; do
    read -p "Enter username (or 'done'): " username
    [ "$username" == "done" ] && break
    [ -z "$username" ] && continue
    users+=("$username")
done

echo "Users to add: ${#users[@]}"
for user in "${users[@]}"; do
    echo "  - $user"
done
```

---

## 🔗 Arrays with Loops

### Loop Through Array
```bash
fruits=("apple" "banana" "cherry")

# Classic
for i in "${!fruits[@]}"; do
    echo "$i: ${fruits[$i]}"
done

# Simple
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done
```

### Sum Array Elements
```bash
numbers=(10 20 30 40 50)
sum=0

for num in "${numbers[@]}"; do
    ((sum += num))
done

echo "Sum: $sum"
```

---

## 🚀 One-Liner Loops

```bash
# Process files
for f in *.txt; do echo "$f"; done

# Quick iteration
for i in {1..5}; do ping -c 1 host$i; done

# Parallel commands (background)
for i in {1..5}; do ./script.sh $i & done; wait
```

---

## 🏆 Practice Exercises

### Exercise 1: Number Sequences
```bash
# Print 1 to 10
for i in {1..10}; do echo $i; done

# Print even numbers 2-20
for i in {2..20..2}; do echo $i; done

# Countdown
for i in {10..1}; do echo $i; done
```

### Exercise 2: File Operations
```bash
# Rename all .txt to .bak
for f in *.txt; do mv "$f" "${f%.txt}.bak"; done

# Delete files older than 7 days
for f in *.log; do [ $(find "$f" -mtime +7) ] && rm "$f"; done

# Create links
for f in *.txt; do ln -sf "$f" "link_$f"; done
```

### Exercise 3: Monitor Loop
```bash
#!/bin/bash
# Monitor disk space

threshold=90

while true; do
    usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
    
    if [ $usage -gt $threshold ]; then
        echo "ALERT: Disk usage at ${usage}%"
    fi
    
    sleep 60
done
```

---

## 📋 Loop Cheat Sheet

| Loop Type | Best For |
|-----------|----------|
| `for` | Known iterations, lists |
| `for ((;;))` | C-style counting |
| `while` | Condition-based, reading files |
| `until` | Wait until something happens |

### Loop Keywords
- `break` - Exit loop completely
- `continue` - Skip to next iteration
- `true` - Infinite loop condition
- `:` - No-op (true in shell)

---

## ✅ Stack 7 Complete!

You learned:
- ✅ for loops (classic, in, range)
- ✅ while loops (condition, read file)
- ✅ until loops
- ✅ Loop control (break, continue)
- ✅ Labeled loops (nested breaking)
- ✅ Real-world examples
- ✅ Array iteration
- ✅ Infinite loops

- **Previous:** [Stack 06 → Control Flow](06_control_flow.md)
- **Next:** [Stack 08 - Functions](08_functions.md) 