#!/bin/bash
# Stack 9 Solution: Input/Output & Redirection

# ================ FILE DESCRIPTORS ================
# 0: stdin (standard input)
# 1: stdout (standard output)
# 2: stderr (standard error)

# ================ OUTPUT REDIRECTION ================

# Redirect stdout to file (overwrite)
echo "Hello, World!" > output.txt

# Redirect stdout to file (append)
echo "Another line" >> output.txt

# Redirect stderr to file
ls /nonexistent 2> error.txt

# Redirect both stdout and stderr
ls /nonexistent &> all_output.txt

# ================ INPUT REDIRECTION ================

# Read from file
echo "=== Reading from file ==="
while read -r line; do
    echo "Line: $line"
done < lessons/01_fundamentals.md

# ================ PIPES ================

echo ""
echo "=== Pipeline Examples ==="

# Chain commands
echo "Files in lessons:" | tee /tmp/pipe_demo.txt
ls lessons/*.md | head -3 | cat -n

# ================ HERE DOCUMENTS ================

echo ""
echo "=== Here Document ==="

# Create file with here document
cat > /tmp/here_doc_example.txt << 'EOF'
This is a here document.
Variables won't expand: $HOME
But this will: $(date)
EOF

cat /tmp/here_doc_example.txt

# With variable expansion
cat > /tmp/here_doc_expanded.txt << EOF
User: $USER
Home: $HOME
Date: $(date)
EOF

cat /tmp/here_doc_expanded.txt

# Here strings
echo ""
echo "=== Here String ==="
read -r a b c <<< "hello world test"
echo "a=$a, b=$b, c=$c"

# ================ PROCESS SUBSTITUTION ================

echo ""
echo "=== Process Substitution ==="

# Compare two directory listings
diff <(ls lessons) <(ls solutions) || true

# Read from command output
while read -r line; do
    echo "Lesson: $line"
done < <(ls lessons/*.md | head -3)

# ================ ADVANCED REDIRECTION ================

# Suppress output
echo "This won't show" > /dev/null 2>&1

# Redirect to multiple destinations
echo "Test" | tee /tmp/log1.txt /tmp/log2.txt

# Custom file descriptor
exec 3> /tmp/custom_fd.txt
echo "This goes to fd 3" >&3
exec 3>&-

# ================ PRACTICAL EXAMPLES ================

# Logging function
log_message() {
    local level=$1
    local message=$2
    echo "[$(date)] [$level] $message" | tee -a /var/log/app.log
}

log_message "INFO" "Application started"
log_message "ERROR" "Configuration missing"

# Error handling with redirection
command_that_fails() {
    echo "Running command..." 
    ls /nonexistent_directory
}

echo ""
echo "=== Capturing Exit Status ==="
command_that_fails > /tmp/output.log 2> /tmp/error.log
exit_code=$?

echo "Exit code: $exit_code"
echo "Output:"
cat /tmp/output.log
echo "Errors:"
cat /tmp/error.log