# 🔀 STACK 6: CONTROL FLOW
## Making Decisions in Your Scripts

---

## 🔀 The if Statement

### Basic Syntax
```bash
# Simple if
if [ condition ]; then
    command
fi

# if-else
if [ condition ]; then
    command1
else
    command2
fi

# if-elif-else
if [ condition1 ]; then
    command1
elif [ condition2 ]; then
    command2
else
    command3
fi
```

### Test Conditions

#### File Tests
```bash
file="/path/to/file"

if [ -e "$file" ]; then     # File exists
if [ -f "$file" ]; then     # Regular file exists
if [ -d "$file" ]; then     # Directory exists
if [ -r "$file" ]; then     # File is readable
if [ -w "$file" ]; then     # File is writable
if [ -x "$file" ]; then     # File is executable
if [ -L "$file" ]; then     # Symbolic link
if [ -s "$file" ]; then     # File exists and not empty
if [ -z "$file" ]; then     # File is empty
```

#### String Tests
```bash
str="hello"

if [ -z "$str" ]; then     # String is empty
if [ -n "$str" ]; then     # String is not empty
if [ "$str" = "hello" ]; then   # Equal
if [ "$str" != "hello" ]; then  # Not equal
if [ "$a" == "$b" ]; then   # (Same as =, preferred)
```

#### Number Comparisons
```bash
a=5
b=10

if [ $a -eq $b ]; then     # Equal
if [ $a -ne $b ]; then     # Not equal
if [ $a -gt $b ]; then     # Greater than
if [ $a -ge $b ]; then     # Greater or equal
if [ $a -lt $b ]; then     # Less than
if [ $a -le $b ]; then     # Less or equal
```

#### Combining Conditions
```bash
# AND (-a or &&)
if [ $a -gt 0 ] && [ $a -lt 10 ]; then
if [ $a -gt 0 -a $a -lt 10 ]; then

# OR (-o or ||)
if [ $a -eq 0 ] || [ $a -eq 10 ]; then
if [ $a -eq 0 -o $a -eq 10 ]; then

# NOT
if [ ! -f "$file" ]; then
```

---

## 🔷 Double Brackets `[[ ]]` (Enhanced)

```bash
# Safer, more powerful than [ ]

# Pattern matching
str="hello.txt"
if [[ $str == *.txt ]]; then
    echo "Text file"
fi

# Regex matching
if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Valid email"
fi

# No word splitting (safer with spaces)
name="John Doe"
if [[ $name == "John Doe" ]]; then
    echo "Found!"
fi
```

---

## 📝 Case Statement

### Syntax
```bash
case variable in
    pattern1)
        commands1
        ;;
    pattern2)
        commands2
        ;;
    pattern3)
        commands3
        ;;
    *)
        default_commands
        ;;
esac
```

### Examples
```bash
# Simple case
read -p "Enter day number (1-7): " day

case $day in
    1) echo "Monday" ;;
    2) echo "Tuesday" ;;
    3) echo "Wednesday" ;;
    4) echo "Thursday" ;;
    5) echo "Friday" ;;
    6) echo "Saturday" ;;
    7) echo "Sunday" ;;
    *) echo "Invalid" ;;
esac
```

### Multiple Patterns
```bash
read -p "Continue? (y/n): " answer

case $answer in
    y|Y|yes|Yes|YES)
        echo "Continuing..."
        ;;
    n|N|no|No|NO)
        echo "Exiting..."
        exit
        ;;
    *)
        echo "Invalid input"
        ;;
esac
```

### Patterns with Wildcards
```bash
filename="document.txt"

case $filename in
    *.txt)     echo "Text file" ;;
    *.pdf)     echo "PDF document" ;;
    *.jpg|*.png) echo "Image file" ;;
    *)         echo "Unknown type" ;;
esac
```

---

## 🔄 Exit Status & $?

```bash
# Every command returns exit status (0 = success, non-zero = failure)

ls /etc/passwd
echo $?    # 0 (success)

ls /nonexistent
echo $?    # 1 or 2 (failure)

# Using in condition
if grep -q "root" /etc/passwd; then
    echo "Root user exists"
fi

# Using && and || for simple conditions
grep -q "error" log.txt && echo "Errors found"
grep -q "error" log.txt || echo "No errors"
```

---

## 🧪 Complete Examples

### Example 1: File Checker
```bash
#!/bin/bash

read -p "Enter filename: " filename

if [ -z "$filename" ]; then
    echo "Please enter a filename"
    exit 1
fi

if [ -f "$filename" ]; then
    echo "Regular file"
    echo "Size: $(wc -c < "$filename") bytes"
elif [ -d "$filename" ]; then
    echo "Directory"
elif [ -L "$filename" ]; then
    echo "Symbolic link"
else
    echo "Unknown file type"
fi
```

### Example 2: Grade Calculator
```bash
#!/bin/bash

read -p "Enter score (0-100): " score

if [ $score -ge 90 ] && [ $score -le 100 ]; then
    grade="A"
elif [ $score -ge 80 ]; then
    grade="B"
elif [ $score -ge 70 ]; then
    grade="C"
elif [ $score -ge 60 ]; then
    grade="D"
elif [ $score -ge 0 ]; then
    grade="F"
else
    echo "Invalid score!"
    exit 1
fi

echo "Grade: $grade"
```

### Example 3: System Info Menu
```bash
#!/bin/bash

echo "====== System Info Menu ======"
echo "1. Current user"
echo "2. Current directory"
echo "3. Uptime"
echo "4. Memory usage"
echo "5. Disk usage"
echo "=============================="

read -p "Choose option (1-5): " choice

case $choice in
    1) whoami ;;
    2) pwd ;;
    3) uptime ;;
    4) free -h ;;
    5) df -h ;;
    *) echo "Invalid option" ;;
esac
```

### Example 4: Simple Calculator with case
```bash
#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $s num1 operator num2"
    echo "Example: $s 10 + 5"
    exit 1
fi

num1=$1
op=$2
num2=$3

# Using (( )) for arithmetic in case
case $op in
    +) result=$((num1 + num2)) ;;
    -) result=$((num1 - num2)) ;;
    x|\*) result=$((num1 * num2)) ;;
    /) 
        if [ $num2 -eq 0 ]; then
            echo "Cannot divide by zero!"
            exit 1
        fi
        result=$((num1 / num2))
        ;;
    %) result=$((num1 % num2)) ;;
    *) 
        echo "Invalid operator: $op"
        exit 1
        ;;
esac

echo "$num1 $op $num2 = $result"
```

---

## 📋 Quick Reference

### Test Command Syntax
```bash
# File tests:  [ -option "file" ]
# String tests: [ "string" op "string" ]
# Number tests: [ num1 -op num2 ]
# Combined:    [ condition ] && [ condition ]
```

### Common Operators
| Operator | Meaning |
|----------|---------|
| `-eq` | Equal (numbers) |
| `-ne` | Not equal |
| `-gt` | Greater than |
| `-lt` | Less than |
| `-ge` | Greater or equal |
| `-le` | Less or equal |
| `-z` | Empty string |
| `-n` | Non-empty string |
| `-f` | Regular file |
| `-d` | Directory |
| `-e` | Exists |
| `-r` | Readable |
| `-w` | Writable |
| `-x` | Executable |

---

## 🏆 Practice Exercises

### Exercise 1: Password Checker
```bash
#!/bin/bash
# Check password strength

read -s -p "Enter password: " password
echo

if [ ${#password} -lt 8 ]; then
    echo "Weak: Less than 8 characters"
elif [[ $password == *[0-9]* ]] && [[ $password == *[A-Z]* ]]; then
    echo "Strong password!"
else
    echo "Medium: Add numbers and uppercase"
fi
```

### Exercise 2: Leap Year Checker
```bash
#!/bin/bash

read -p "Enter year: " year

if (( year % 400 == 0 )); then
    echo "Leap year"
elif (( year % 100 == 0 )); then
    echo "Not leap year"
elif (( year % 4 == 0 )); then
    echo "Leap year"
else
    echo "Not leap year"
fi
```

### Exercise 3: Service Manager
```bash
#!/bin/bash

service=$1
action=$2

case $action in
    start)
        echo "Starting $service..."
        ;;
    stop)
        echo "Stopping $service..."
        ;;
    restart)
        echo "Restarting $service..."
        ;;
    status)
        echo "Checking $service..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
```

---

## ✅ Stack 6 Complete!

You learned:
- ✅ Basic if/elif/else statements
- ✅ Test conditions (files, strings, numbers)
- ✅ Combining conditions (AND, OR, NOT)
- ✅ Double brackets `[[ ]]` for advanced testing
- ✅ Pattern matching in tests
- ✅ case statements
- ✅ Exit status and $?
- ✅ Building real scripts

### Next: Stack 7 → Loops (for, while, until) →