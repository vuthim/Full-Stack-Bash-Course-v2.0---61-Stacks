#!/bin/bash
# Stack 2 Solution: File Operations Utility

# Create directory structure
mkdir -p projects/{src,docs,tests,build}

# Create some sample files
touch projects/src/main.c
touch projects/src/utils.c
touch projects/docs/README.md
touch projects/tests/test_main.c

# List with tree-like output
echo "=== Directory Structure ==="
ls -R projects/

# Copy with pattern
cp projects/src/*.c projects/build/

# Find and list all .c files
echo ""
echo "=== C Source Files ==="
find projects -name "*.c"

# Count files
echo ""
echo "File counts:"
echo "Source files: $(find projects -name '*.c' | wc -l)"
echo "All files: $(find projects -type f | wc -l)"
echo "Directories: $(find projects -type d | wc -l)"