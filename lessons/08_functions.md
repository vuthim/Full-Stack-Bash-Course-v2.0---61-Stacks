# 🔧 STACK 8: FUNCTIONS
## Reusable Code Blocks

---

## 📦 What Are Functions?

Functions are reusable code blocks that perform specific tasks.

### Why Use Functions?
- **DRY** - Don't Repeat Yourself
- **Modular** - Break code into pieces
- **Reusable** - Call multiple times
- **Readable** - Easier to understand

---

## 📝 Function Syntax

### Two Ways to Define
```bash
# Method 1: Without function keyword
function_name() {
    commands
}

# Method 2: With function keyword
function function_name {
    commands
}

# Method 3: With parentheses (less common)
function function_name() {
    commands
}
```

### Function Call
```bash
hello() {
    echo "Hello, World!"
}

# Call the function
hello
```

---

## 📥 Function Parameters

### Passing Arguments
```bash
greet() {
    echo "Hello, $1!"    # First argument
    echo "Hello, $2!"    # Second argument
}

greet "John" "Doe"
# Output:
# Hello, John!
# Hello, Doe!
```

### Accessing All Arguments
```bash
show_args() {
    echo "Number of args: $#"
    echo "All args: $@"
}

show_args one two three four
```

---

## 📤 Return Values

### Return Status (0-255)
```bash
check_even() {
    if [ $(($1 % 2)) -eq 0 ]; then
        return 0    # Success (even)
    else
        return 1    # Failure (odd)
    fi
}

check_even 10
echo $?    # 0

check_even 7
echo $?    # 1
```

### Returning Strings (using variable)
```bash
get_date() {
    echo $(date +%Y-%m-%d)
}

result=$(get_date)
echo "Date: $result"
```

### Returning Values (using variable)
```bash
add_numbers() {
    local sum=$(($1 + $2))
    echo $sum
}

total=$(add_numbers 5 10)
echo "Sum: $total"
```

---

## 🌐 Scope & Variables

### Local Variables
```bash
my_function() {
    local var="I'm local"
    echo $var
}

global_var="I'm global"

my_function
echo $global_var
# echo $var would be empty (not accessible)
```

### Global Variables
```bash
counter=0

increment() {
    counter=$((counter + 1))
}

increment
increment
echo $counter    # 2
```

---

## 🔄 Function Examples

### Example 1: Simple Calculator
```bash
add() {
    echo $(($1 + $2))
}

subtract() {
    echo $(($1 - $2))
}

multiply() {
    echo $(($1 * $2))
}

divide() {
    if [ $2 -eq 0 ]; then
        echo "Error: Division by zero"
        return 1
    fi
    echo $(($1 / $2))
}

# Usage
result=$(add 10 5)          # 15
result=$(subtract 10 5)     # 5
result=$(multiply 10 5)     # 50
result=$(divide 10 5)      # 2
result=$(divide 10 0)      # Error message
```

### Example 2: File Operations
```bash
file_count() {
    local dir=${1:-.}    # Default to current
    ls -1 "$dir" 2>/dev/null | wc -l
}

file_details() {
    if [ -f "$1" ]; then
        echo "File: $1"
        echo "Lines: $(wc -l < "$1")"
        echo "Size: $(wc -c < "$1") bytes"
    else
        echo "Error: $1 not found"
        return 1
    fi
}

# Usage
count=$(file_count "/etc")
echo "Files in /etc: $count"

file_details "script.sh"
```

### Example 3: User Input Validation
```bash
validate_email() {
    local email=$1
    
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

prompt_email() {
    local email
    read -p "Enter email: " email
    
    if validate_email "$email"; then
        echo "Valid email!"
    else
        echo "Invalid email format"
    fi
}
```

### Example 4: Menu System
```bash
#!/bin/bash

show_date() {
    date
}

show_uptime() {
    uptime
}

show_users() {
    who
}

show_memory() {
    free -h
}

show_menu() {
    echo "====== Menu ======"
    echo "1. Date & Time"
    echo "2. System Uptime"
    echo "3. Logged In Users"
    echo "4. Memory Usage"
    echo "5. Exit"
    echo "================="
}

main() {
    while true; do
        show_menu
        read -p "Choose: " choice
        
        case $choice in
            1) show_date ;;
            2) show_uptime ;;
            3) show_users ;;
            4) show_memory ;;
            5) echo "Goodbye!"; break ;;
            *) echo "Invalid" ;;
        esac
        echo
    done
}

main
```

### Example 5: Recursive Function
```bash
factorial() {
    local n=$1
    
    if [ $n -le 1 ]; then
        echo 1
    else
        local prev=$(factorial $((n - 1)))
        echo $((n * prev))
    fi
}

echo $(factorial 5)    # 120
```

---

## 🔧 Advanced Function Techniques

### Functions in Arrays
```bash
# Array of function references
commands=("func1" "func2" "func3")

func1() { echo "Function 1"; }
func2() { echo "Function 2"; }
func3() { echo "Function 3"; }

# Call function from array
${commands[0]}    # Calls func1
```

### Function Libraries
```bash
# file: lib.sh
log() {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1"
}

error() {
    echo "[ERROR] $1" >&2
}

# source the library
source lib.sh

log "Application started"
error "Something went wrong"
```

### Passing Arrays to Functions
```bash
process_array() {
    local arr=("$@")
    
    for item in "${arr[@]}"; do
        echo "Item: $item"
    done
}

my_array=(one two three)
process_array "${my_array[@]}"
```

---

## 📋 Function Tips

### Default Values in Parameters
```bash
greet() {
    local name=${1:-"Guest"}
    echo "Hello, $name!"
}

greet           # Hello, Guest!
greet "John"    # Hello, John!
```

### Checking Parameters
```bash
require_args() {
    if [ $# -lt 2 ]; then
        echo "Usage: $s <arg1> <arg2>"
        return 1
    fi
}
```

### Command Line Options in Functions
```bash
my_func() {
    while getopts "vh" opt; do
        case $opt in
            v) verbose=true ;;
            h) help; return 0 ;;
        esac
    done
    shift $((OPTIND-1))
    
    # Rest of function
}
```

---

## 🏆 Practice Exercises

### Exercise 1: String Utilities
```bash
#!/bin/bash

uppercase() {
    echo "$1" | tr 'a-z' 'A-Z'
}

lowercase() {
    echo "$1" | tr 'A-Z' 'a-z'
}

reverse() {
    echo "$1" | rev
}

# Test
echo $(uppercase "hello")    # HELLO
echo $(lowercase "WORLD")    # world
echo $(reverse "hello")     # olleh
```

### Exercise 2: Number Utilities
```bash
#!/bin/bash

is_even() {
    return $(($1 % 2 == 0))
}

is_prime() {
    local n=$1
    if [ $n -le 1 ]; then return 1; fi
    
    for ((i=2; i*i<=n; i++)); do
        if [ $((n % i)) -eq 0 ]; then
            return 1
        fi
    done
    return 0
}

# Test
is_even 4 && echo "Even"
is_prime 7 && echo "Prime"
```

### Exercise 3: Color Output
```bash
#!/bin/bash

red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
blue() { echo -e "\033[34m$1\033[0m"; }

red "Error message"
green "Success!"
yellow "Warning"
```

---

## 🎯 Embedded Exercises

### Exercise 1: Temperature Converter (5 min)
Create functions to convert between Celsius and Fahrenheit:
```bash
celsius_to_fahrenheit() {
    # Formula: (C × 9/5) + 32
    # Usage: celsius_to_fahrenheit 100
}

fahrenheit_to_celsius() {
    # Formula: (F − 32) × 5/9
    # Usage: fahrenheit_to_celsius 212
}
```

### Exercise 2: Array Processor (10 min)
Write a function that accepts an array and returns:
- Sum of all numbers
- Average (rounded to 2 decimal places)
- Largest and smallest values

```bash
process_numbers() {
    local arr=("$@")
    # Return: sum, average, min, max
}
```

### Exercise 3: File Search Utility (10 min)
Create a function that:
- Takes a directory and file extension as input
- Returns count of matching files
- Lists files over 1MB in size

```bash
find_files_by_type() {
    local dir=$1
    local ext=$2
    # Implementation here
}
```

### Exercise 4: Password Generator (10 min)
Build a function that:
- Takes length as parameter (default: 12)
- Generates random password with: uppercase, lowercase, numbers, special chars
- Excludes ambiguous characters (0, O, l, 1, etc.)

```bash
generate_password() {
    local length=${1:-12}
    # Implementation here
}
```

---

## 📝 Quiz: Test Your Knowledge

### Question 1
What is the output of this code?
```bash
greet() {
    local name=$1
    echo "Hello, $name"
}
greet "World"
```
a) `Hello, $name`  
b) `Hello, World`  
c) `Hello,`  
d) Error

### Question 2
Which statement about function return values is **FALSE**?
a) `return` can only return 0-255  
b) Use `echo` to return strings  
c) `$?` captures return status  
d) `return` can return any data type

### Question 3
What does the `local` keyword do?
a) Makes variable available to all functions  
b) Limits variable scope to current function  
c) Creates a global constant  
d) Disables the variable

### Question 4
How do you pass an array to a function?
a) `my_func $array`  
b) `my_func "${array[@]}"`  
c) `my_func $array[@]`  
d) `my_func $(array)`

### Question 5
What is the correct syntax to call function result into a variable?
a) `result = my_func`  
b) `result=$(my_func)`  
c) `result=my_func`  
d) `$result = my_func`

---

## 🚀 Hands-On Project: Function Library

### Project: "Bash Toolkit" Library (30-45 min)

Create a reusable library `toolkit.sh` with the following functions:

#### Part A: String Functions
- `str_uppercase "text"` - Convert to uppercase
- `str_lowercase "TEXT"` - Convert to lowercase
- `str_trim "  text  "` - Remove leading/trailing spaces
- `str_reverse "hello"` - Reverse string
- `str_length "hello"` - Get string length

#### Part B: Number Functions
- `num_is_even 4` - Check if even (return 0/1)
- `num_is_odd 5` - Check if odd (return 0/1)
- `num_is_prime 7` - Check if prime
- `num_factorial 5` - Calculate factorial

#### Part C: File Functions
- `file_exists "/path"` - Check if file exists
- `file_is_empty "/path"` - Check if file is empty
- `file_count_lines "/path"` - Count lines in file

#### Part D: System Functions
- `sys_disk_usage` - Show disk usage percentage
- `sys_memory_usage` - Show memory usage
- `sys_cpu_count` - Return CPU core count

### Requirements
1. Use `local` variables in all functions
2. Add error handling (check required parameters)
3. Create a `main()` function with menu to test all functions
4. Save as `toolkit.sh` and source it: `source toolkit.sh`

### Bonus Challenge
- Add `--help` option to each function
- Create color-coded output functions

### Expected Output Example
```
===== Bash Toolkit =====
1. String Functions
2. Number Functions  
3. File Functions
4. System Functions
5. Run All Tests
6. Exit
```

---

## ✅ Stack 8 Complete!

You learned:
- ✅ Function definition and syntax
- ✅ Passing parameters to functions
- ✅ Returning values (status & strings)
- ✅ Variable scope (local vs global)
- ✅ Real-world examples
- ✅ Recursive functions
- ✅ Function libraries
- ✅ Passing arrays to functions

### Next: Stack 9 → Input/Output & Redirection →

---

### 📚 Answer Key
See `solutions/answers_stack8.md` for solutions to all exercises and quiz answers.