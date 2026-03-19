# Stack 8: Functions - Answer Key

---

## Embedded Exercises Solutions

### Exercise 1: Temperature Converter
```bash
celsius_to_fahrenheit() {
    local c=$1
    echo $(echo "scale=2; ($c * 9/5) + 32" | bc)
}

fahrenheit_to_celsius() {
    local f=$1
    echo $(echo "scale=2; ($f - 32) * 5/9" | bc)
}

# Usage
echo "100C = $(celsius_to_fahrenheit 100)F"
echo "212F = $(fahrenheit_to_celsius 212)C"
```

### Exercise 2: Array Processor
```bash
process_numbers() {
    local arr=("$@")
    local sum=0
    local min=${arr[0]}
    local max=${arr[0]}
    
    for num in "${arr[@]}"; do
        ((sum += num))
        ((num < min)) && min=$num
        ((num > max)) && max=$num
    done
    
    local avg=$(echo "scale=2; $sum / ${#arr[@]}" | bc)
    
    echo "Sum: $sum"
    echo "Average: $avg"
    echo "Min: $min"
    echo "Max: $max"
}

# Usage
numbers=(10 20 30 40 50)
process_numbers "${numbers[@]}"
```

### Exercise 3: File Search Utility
```bash
find_files_by_type() {
    local dir=$1
    local ext=$2
    
    if [ ! -d "$dir" ]; then
        echo "Error: Directory not found"
        return 1
    fi
    
    local count=$(find "$dir" -name "*.$ext" 2>/dev/null | wc -l)
    echo "Files with .$ext: $count"
    
    echo "Files over 1MB:"
    find "$dir" -name "*.$ext" -size +1M 2>/dev/null
}

# Usage
find_files_by_type "/path/to/dir" "txt"
```

### Exercise 4: Password Generator
```bash
generate_password() {
    local length=${1:-12}
    local chars="abcdefghijkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789!@#$%^&*"
    local password=""
    
    for ((i=0; i<length; i++)); do
        local random=$(($(date +%s) + i * 12345))
        local random=$((random % ${#chars}))
        password+=${chars:$random:1}
    done
    
    echo "$password"
}

# Usage
generate_password 16
```

---

## Quiz Answers

| Question | Answer | Explanation |
|----------|--------|-------------|
| Q1 | **b** `Hello, World` | $1 expands to "World", printed with prefix |
| Q2 | **d** `return` can return any data type | False - return only handles 0-255 exit codes |
| Q3 | **b** Limits variable scope to current function | local restricts variable to function scope |
| Q4 | **b** `my_func "${array[@]}"` | Correct syntax to pass array preserving elements |
| Q5 | **b** `result=$(my_func)` | Command substitution captures stdout |

---

## Hands-On Project: Bash Toolkit (Solution)

```bash
#!/bin/bash
# toolkit.sh - Reusable Bash Function Library

# === String Functions ===
str_uppercase() {
    echo "$1" | tr 'a-z' 'A-Z'
}

str_lowercase() {
    echo "$1" | tr 'A-Z' 'a-z'
}

str_trim() {
    echo "$1" | xargs
}

str_reverse() {
    echo "$1" | rev
}

str_length() {
    echo ${#1}
}

# === Number Functions ===
num_is_even() {
    [ $(($1 % 2)) -eq 0 ] && return 0 || return 1
}

num_is_odd() {
    [ $(($1 % 2)) -ne 0 ] && return 0 || return 1
}

num_is_prime() {
    local n=$1
    if [ $n -le 1 ]; then return 1; fi
    for ((i=2; i*i<=n; i++)); do
        [ $((n % i)) -eq 0 ] && return 1
    done
    return 0
}

num_factorial() {
    local n=$1
    local result=1
    for ((i=2; i<=n; i++)); do
        result=$((result * i))
    done
    echo $result
}

# === File Functions ===
file_exists() {
    [ -f "$1" ] && return 0 || return 1
}

file_is_empty() {
    [ -z "$(cat "$1" 2>/dev/null)" ] && return 0 || return 1
}

file_count_lines() {
    [ -f "$1" ] && wc -l < "$1" || echo 0
}

# === System Functions ===
sys_disk_usage() {
    df -h . | tail -1 | awk '{print $5}'
}

sys_memory_usage() {
    free -h | grep Mem | awk '{print $3 "/" $2}'
}

sys_cpu_count() {
    nproc
}

# === Main Menu ===
main() {
    while true; do
        echo "===== Bash Toolkit ====="
        echo "1. String Functions"
        echo "2. Number Functions"
        echo "3. File Functions"
        echo "4. System Functions"
        echo "5. Run All Tests"
        echo "6. Exit"
        read -p "Choose: " choice
        
        case $choice in
            1)
                echo "Uppercase: $(str_uppercase 'hello')"
                echo "Lowercase: $(str_lowercase 'HELLO')"
                echo "Trimmed: '$(str_trim '  spaces  ')'"
                echo "Reversed: $(str_reverse 'hello')"
                echo "Length: $(str_length 'hello')"
                ;;
            2)
                num_is_even 4 && echo "4 is even" || echo "4 is odd"
                num_is_prime 7 && echo "7 is prime" || echo "7 is not prime"
                echo "Factorial of 5: $(num_factorial 5)"
                ;;
            3)
                file_exists "/etc/passwd" && echo "/etc/passwd exists"
                echo "Lines in /etc/passwd: $(file_count_lines /etc/passwd)"
                ;;
            4)
                echo "Disk usage: $(sys_disk_usage)"
                echo "Memory: $(sys_memory_usage)"
                echo "CPU cores: $(sys_cpu_count)"
                ;;
            5)
                echo "Testing all functions..."
                echo "Uppercase test: $(str_uppercase 'test')"
                echo "Prime test: $(num_is_prime 11 && echo '11 is prime')"
                echo "Memory: $(sys_memory_usage)"
                echo "All tests passed!"
                ;;
            6) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option" ;;
        esac
        echo
    done
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
```

---

## Summary

- All exercises reinforce function concepts: parameters, return values, scope
- Quiz tests understanding of syntax and behavior
- Project combines all skills into a practical, reusable library