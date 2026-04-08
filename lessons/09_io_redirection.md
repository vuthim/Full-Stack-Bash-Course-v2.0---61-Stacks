# 🔀 STACK 9: INPUT/OUTPUT & REDIRECTION
## Controlling Where Data Goes and Comes From

Think of data flow like plumbing in your house - you can redirect water (data) to go where you want it to go, instead of just letting it flow to the default places.

---

## 🎯 Standard File Descriptors

| Descriptor | Name | Description |
|------------|------|-------------|
| 0 | stdin | Standard input (keyboard) |
| 1 | stdout | Standard output (screen) |
| 2 | stderr | Standard error (screen) |

---

## 📤 Output Redirection

### Basic Redirection
```bash
# Redirect stdout to file (overwrite)
command > output.txt

# Redirect stdout to file (append)
command >> output.txt

# Redirect stderr to file
command 2> errors.txt

# Redirect both stdout and stderr
command &> all_output.txt
command > output.txt 2>&1     # Old style

# Redirect stderr to where stdout goes
command > output.txt 2>&1

# Discard output
command > /dev/null
command &> /dev/null
```

### Examples
```bash
# Save directory listing
ls -l > files.txt

# Append to log
echo "$(date): Script ran" >> app.log

# Save errors only
grep "error" *.log 2> errors.txt

# Save both to one file
make &> build.log
```

---

## 📥 Input Redirection

### Basic Input
```bash
# Read from file
command < input.txt

# Here document (inline input)
command << 'EOF'
line 1
line 2
line 3
EOF

# Here string
command <<< "input string"
```

### Here Document Examples
```bash
# Create file with cat
cat > newfile.txt << 'EOF'
Line 1
Line 2
Line 3
EOF

# Input to command
ftp -n << 'EOF'
open server.com
user myuser mypass
get file.txt
quit
EOF

# Disable variable expansion
cat << 'EOF'
Variable: $HOME
EOF
# Output: Variable: $HOME (literal)

# Enable variable expansion
cat << EOF
Variable: $HOME
EOF
# Output: Variable: /home/user (expanded)
```

### Here String
```bash
# Pass string as input
read -r word <<< "hello world"
echo $word          # hello

# Process string with command
tr 'a-z' 'A-Z' <<< "hello"
# Output: HELLO

# wc with here string
wc -w <<< "one two three"
# Output: 3
```

---

## 🔗 Pipes

### Connect Commands
```bash
# Pipe stdout to another command
command1 | command2

# Chain multiple commands
command1 | command2 | command3

# Examples
ls -1 | grep ".txt"          # List only .txt files
cat file.txt | sort | uniq   # Sort and remove duplicates
ps aux | grep nginx          # Find nginx process
du -h | sort -h              # Sort by human-readable size
```

### tee - Write & Pass Through
```bash
# Save output AND display on screen
command | tee output.txt

# Append to file
command | tee -a output.txt

# Example: Install with log
apt install package | tee install.log

# Multiple tees
command | tee file1.txt | tee file2.txt
```

---

## 🔄 Process Substitution

### Using >( ) and <( )
```bash
# Compare two command outputs
diff <(ls dir1) <(ls dir2)

# Read from process
while IFS= read -r line; do
    echo "Line: $line"
done < <(grep "pattern" file.txt)

# Feed multiple sources
cat <(echo "header") file.txt <(echo "footer")

# With while loop
while IFS= read -r line; do
    echo "$line"
done < <(curl -s https://example.com)
```

### Safe File Reading Patterns
```bash
# Read every line exactly as-is
while IFS= read -r line; do
    echo "Processing: $line"
done < input.txt

# Keep the last line even if it has no trailing newline
while IFS= read -r line || [ -n "$line" ]; do
    echo "Processing: $line"
done < input.txt
```

### Safe Filename Handling with Null Delimiters
```bash
# Best practice for filenames that may contain spaces/newlines
find . -type f -name '*.log' -print0 |
while IFS= read -r -d '' file; do
    printf 'Found: %s\n' "$file"
done

# xargs version
find . -type f -name '*.log' -print0 | xargs -0 ls -l
```

---

## 📊 Advanced Redirection

### Named Pipes (FIFO)
```bash
# Create named pipe
mkfifo mypipe

# Terminal 1: Read from pipe
cat < mypipe

# Terminal 2: Write to pipe
echo "Hello through pipe" > mypipe

# Cleanup
rm mypipe
```

### File Descriptor Manipulation
```bash
# Save stdout to file descriptor 3
exec 3>&1

# Restore stdout from fd 3
exec 1>&3

# Close file descriptor
exec 3>&-

# Example: Temporarily redirect
echo "Screen output"
exec > output.txt
echo "This goes to file"
echo "This too"
exec > /dev/tty
echo "Back to screen"
```

---

## ✅ Examples

### Example 1: Logging Function
```bash
#!/bin/bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a app.log
}

log "Starting backup"
log "Backing up files..."
log "Backup complete"
```

### Example 2: Silent Installation
```bash
#!/bin/bash

# Run command, suppress all output
silent() {
    "$@" > /dev/null 2>&1
}

# Check if command exists, install if not
if ! silent command -v curl; then
    echo "Installing curl..."
    sudo apt install curl
fi
```

### Example 3: Dual Output (Screen + Log)
```bash
#!/bin/bash

logfile="script.log"

log() {
    echo "$*" | tee -a "$logfile"
}

log "Starting process"

# Both appear on screen and in log
ls -l
cat /etc/hostname
```

### Example 4: Error Handling with Redirection
```bash
#!/bin/bash

# Redirect errors to separate file
command 2> errors.log

# Check for errors
if [ -s errors.log ]; then
    echo "Errors occurred:"
    cat errors.log
    exit 1
fi
```

### Example 5: Pipeline Debugging
```bash
#!/bin/bash
# Debug pipeline

set -x          # Enable debug

cat log.txt | grep ERROR | sort | uniq

set +x          # Disable debug
```

---

## 🏆 Practice Exercises

### Exercise 1: Create a Log System
```bash
#!/bin/bash

logfile="app.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$$] $*" | tee -a "$logfile"
}

# Test
log "INFO: Application started"
log "ERROR: Connection failed"
log "INFO: Reconnected"
```

### Example 2: Capture All Output
```bash
#!/bin/bash

output="run.log"

# All output goes to log and terminal
exec > >(tee "$output") 2>&1

echo "This appears everywhere"
ls /nonexistent 2>&1  # This too
```

### Exercise 3: Input from User or File
```bash
#!/bin/bash

if [ -n "$1" ]; then
    input="$1"
else
    input="/dev/stdin"
fi

process() {
    while IFS= read -r line; do
        echo "Processing: $line"
    done < "$input"
}
```

---

## 📋 Redirection Cheat Sheet

| Symbol | Meaning |
|--------|---------|
| `>` | Redirect stdout (overwrite) |
| `>>` | Redirect stdout (append) |
| `2>` | Redirect stderr |
| `&>` | Redirect both |
| `<` | Redirect stdin |
| `\|` | Pipe |
| `<<` | Here document |
| `<<<` | Here string |
| `>&n` | Redirect to fd n |
| `<&n` | Read from fd n |

---

## ✅ Stack 9 Complete!

You learned:
- ✅ Standard file descriptors (stdin, stdout, stderr)
- ✅ Output redirection (> and >>)
- ✅ Error redirection (2>)
- ✅ Combining stdout and stderr (&>, 2>&1)
- ✅ Input redirection (<)
- ✅ Here documents and here strings
- ✅ Pipes and command chaining
- ✅ tee command
- ✅ Process substitution
- ✅ Safe line reading with `IFS= read -r`
- ✅ Null-delimited filename handling (`-print0`, `-d ''`, `xargs -0`)
- ✅ Named pipes
- ✅ File descriptor manipulation

- **Previous:** [Stack 08 → Functions](08_functions.md)
- **Next:** [Stack 10 - Regular Expressions](10_regular_expressions.md) 
