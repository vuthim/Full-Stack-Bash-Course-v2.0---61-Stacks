#!/bin/bash
# Stack 1 Solution: Hello Bash Script
# Challenge: Create a script that displays:
# 1. A greeting with your name
# 2. Current date and time
# 3. Current working directory
# 4. Number of files in current directory

echo "=============================="
echo "  Hello, Bash Master! 🐚"
echo "=============================="
echo ""
echo "📅 Date: $(date)"
echo "📁 Directory: $(pwd)"
echo "📂 Files: $(ls | wc -l)"
echo ""
echo "=============================="

# Alternative with more detail:
echo ""
echo "--- Detailed Version ---"
echo "Today is: $(date +'%A, %B %d, %Y')"
echo "Time is: $(date +'%H:%M:%S')"
echo "Current user: $(whoami)"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"