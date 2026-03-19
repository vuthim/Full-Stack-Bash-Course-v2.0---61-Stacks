#!/bin/bash
# Stack 3B: Quoting, Expansion & Safe File Handling - Solutions

# Exercise 1: Quoting Test
echo "=== Exercise 1: Quoting Test ==="
VAR="hello world"
echo "Without quotes: $VAR"
echo "With quotes: $VAR"
echo 'Without quotes: $VAR'  # Single quotes are literal

# Exercise 2: Fix This Script
echo ""
echo "=== Exercise 2: Fix the broken script ==="

# WRONG (broken script):
# for file in $(ls *.log); do
#     tail -n 10 $file >> all_logs.txt
# done

# CORRECT (fixed script):
for file in *.log; do
    [ -e "$file" ] || continue
    tail -n 10 "$file" >> all_logs.txt
done

# Exercise 3: Safe File Loop with Spaces
echo ""
echo "=== Exercise 3: Safe File Loop ==="

# Create test files with spaces
touch "my file 1.log" "my file 2.log" 2>/dev/null || true

# CORRECT - use glob, not ls
for file in *.log; do
    [ -e "$file" ] || continue
    echo "Processing: $file"
done

# EVEN BETTER - use nullglob
shopt -s nullglob
for file in *.log; do
    echo "Processing: $file"
done
shopt -u nullglob

# Exercise 4: Implement Safe Arguments
echo ""
echo "=== Exercise 4: Safe Arguments ==="
echo "Script arguments:"
for arg in "$@"; do
    echo "  Argument: $arg"
done

# Demonstrate "$@" vs "$*"
echo ""
echo "Difference between \"\$@\" and \"\$*\":"
echo "With \"\$@\":"
for arg in "$@"; do
    echo "  $arg"
done

echo "With \"\$*\":"
for arg in "$*"; do
    echo "  $arg"
done

echo ""
echo "All exercises complete!"
