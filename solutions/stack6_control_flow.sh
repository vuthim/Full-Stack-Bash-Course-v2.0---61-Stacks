#!/bin/bash
# Stack 6 Solution: Control Flow

# ================ IF/ELSE ================
echo "=== If/Else Examples ==="

number=10

if [ $number -gt 0 ]; then
    echo "$number is positive"
elif [ $number -lt 0 ]; then
    echo "$number is negative"
else
    echo "$number is zero"
fi

# String comparison
echo ""
name="Bash"
if [ "$name" == "Bash" ]; then
    echo "Hello, Bash!"
elif [ "$name" == "Shell" ]; then
    echo "Hello, Shell!"
else
    echo "Hello, Stranger!"
fi

# File test operators
echo ""
file="solutions/stack1_hello_bash.sh"
if [ -f "$file" ]; then
    echo "$file exists and is a regular file"
fi

if [ -d "lessons" ]; then
    echo "lessons directory exists"
fi

# ================ CASE STATEMENT ================
echo ""
echo "=== Case Statement ==="

day=$(date +%A)

case $day in
    Monday)
        echo "Start of work week!"
        ;;
    Tuesday|Wednesday|Thursday)
        echo "Midweek grind"
        ;;
    Friday)
        echo " TGIF! "
        ;;
    Saturday|Sunday)
        echo "Weekend fun! 🎉"
        ;;
    *)
        echo "Unknown day: $day"
        ;;
esac

# Menu example
echo ""
echo "=== Menu Example ==="
echo "Select an option:"
echo "1. View date"
echo "2. View calendar"
echo "3. View disk usage"
echo "4. Exit"

read -p "Choice: " choice

case $choice in
    1)
        echo "Date: $(date)"
        ;;
    2)
        cal
        ;;
    3)
        df -h
        ;;
    4)
        echo "Goodbye!"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac