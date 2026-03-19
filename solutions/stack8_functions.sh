#!/bin/bash
# Stack 8 Solution: Functions

# ================ BASIC FUNCTIONS ================

# Function without parameters
greet() {
    echo "Hello! Welcome to Bash Functions!"
}

greet

# Function with parameters
say_hello() {
    local name=$1
    local age=${2:-25}
    echo "Hello, $name! You are $age years old."
}

say_hello "John" 30
say_hello "Jane"

# Function with return
get_sum() {
    local a=$1
    local b=$2
    echo $((a + b))
}

result=$(get_sum 5 10)
echo "Sum: $result"

# ================ RETURN VALUES ================

# Return string via global variable
get_date() {
    current_date=$(date +'%Y-%m-%d')
}

get_date
echo "Date: $current_date"

# Return via echo (capture output)
get_timestamp() {
    date +'%s'
}

timestamp=$(get_timestamp)
echo "Timestamp: $timestamp"

# ================ FUNCTION LIBRARY ================

# Logger function
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*"
}

log "INFO" "Application started"
log "ERROR" "Connection failed"
log "WARN" "Low disk space"

# File checker
check_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo "File exists: $file"
        return 0
    else
        echo "File not found: $file"
        return 1
    fi
}

check_file "lessons/01_fundamentals.md"
check_file "nonexistent.txt"

# Calculator
calc() {
    local op=$1
    local a=$2
    local b=$3
    
    case $op in
        add)
            echo $((a + b))
            ;;
        sub)
            echo $((a - b))
            ;;
        mul)
            echo $((a * b))
            ;;
        div)
            if [ $b -eq 0 ]; then
                echo "Error: Division by zero"
                return 1
            fi
            echo $((a / b))
            ;;
        *)
            echo "Unknown operation"
            return 1
            ;;
    esac
}

echo "5 + 3 = $(calc add 5 3)"
echo "10 - 4 = $(calc sub 10 4)"
echo "6 * 7 = $(calc mul 6 7)"
echo "20 / 4 = $(calc div 20 4)"

# ================ RECURSIVE FUNCTION ================

factorial() {
    local n=$1
    if [ $n -le 1 ]; then
        echo 1
    else
        local prev=$(factorial $((n - 1)))
        echo $((n * prev))
    fi
}

echo "Factorial of 5: $(factorial 5)"

# ================ PASSING ARRAY TO FUNCTION ================

sum_array() {
    local arr=("$@")
    local sum=0
    for num in "${arr[@]}"; do
        sum=$((sum + num))
    done
    echo $sum
}

numbers=(1 2 3 4 5)
total=$(sum_array "${numbers[@]}")
echo "Sum of array: $total"

# ================ SCOPE DEMONSTRATION ================

demo_scope() {
    local local_var="I'm local"
    global_var="I'm global"
    echo "Inside function - local: $local_var, global: $global_var"
}

demo_scope
echo "Outside function - local: $local_var (empty), global: $global_var"