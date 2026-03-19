#!/bin/sh
# Stack 12B: Bash Portability & POSIX - Solutions

# Exercise 1: Convert to POSIX
echo "=== Exercise 1: POSIX Arrays ==="

# BASH VERSION (not portable):
# #!/bin/bash
# declare -A config
# config[name]="app"
# config[version]="1.0"
# for key in "${!config[@]}"; do
#     echo "$key: ${config[$key]}"
# done

# POSIX VERSION (portable):
# Use separate variables or colon-separated string
config_name="app"
config_version="1.0"
config_database="mydb"

echo "name: $config_name"
echo "version: $config_version"
echo "database: $config_database"

# Or use colon-separated string
config="name=app:version=1.0:database=mydb"

echo ""
echo "Using colon-separated config:"
echo "$config" | tr ':' '\n'

# Exercise 2: Write Portable Script
echo ""
echo "=== Exercise 2: Portable Script Template ==="

# This script works on both POSIX sh and bash

set -e  # Exit on error
set -u  # Unset variables are errors

# Detect if we have bash features
if [ -n "${BASH_VERSION:-}" ]; then
    echo "Running in Bash: $BASH_VERSION"
else
    echo "Running in POSIX shell"
fi

# Check for required commands
has() {
    command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
    missing=""
    for cmd in sed grep awk; do
        if ! has "$cmd"; then
            missing="$missing $cmd"
        fi
    done
    if [ -n "$missing" ]; then
        echo "Error: Missing required commands:$missing" >&2
        exit 1
    fi
}

check_dependencies
echo "All dependencies satisfied!"

# Exercise 3: Test with Different Shells
echo ""
echo "=== Exercise 3: Shell Testing ==="

# Save this script and test with different shells:
# dash -n script.sh    # Syntax check with dash
# bash -n script.sh   # Syntax check with bash
# sh -n script.sh     # Syntax check with /bin/sh

# Run with shellcheck for portability warnings
# shellcheck -s sh script.sh

echo "To test portability:"
echo "  1. Run: dash -n $0"
echo "  2. Run: bash -n $0"
echo "  3. Run: sh -n $0"
echo "  4. Run: shellcheck -s sh $0"

echo ""
echo "All exercises complete!"
