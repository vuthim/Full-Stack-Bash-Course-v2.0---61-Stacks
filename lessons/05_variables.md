# 🔢 STACK 5: VARIABLES & DATA TYPES
## Making Your Scripts Dynamic

**What Are Variables?** Think of variables like labeled boxes. You put something in a box, label it, and later you can look up the label to find what's inside. The "variable" part means the contents can change - you can swap what's in the box anytime!

**Why This Matters?** Without variables, you'd repeat the same values everywhere in your scripts. With them, you write once, change in one place, and everything updates. Variables are what make scripts "smart" instead of static!

---

## 📦 What Are Variables?

Variables store data that can change during script execution.

### Variable Analogy
```
Variable = A labeled box
name="John"   →  Put "John" in a box labeled "name"
echo $name    →  Look in the "name" box, read what's inside
name="Jane"   →  Replace contents with "Jane" (the box stays, contents change!)
```

### Variable Rules (The Grammar)
- Name: letters, numbers, underscores (can't start with number)
- Case-sensitive (`NAME` ≠ `name` - they're different boxes!)
- **No spaces around `=`** (this trips up EVERY beginner!)
- Reference with `$` prefix

---

## 🔨 Basic Variables

### Creating & Using Variables
```bash
# Create a variable
name="John"
age=25
price=19.99

# Using variables
echo "Name: $name"
echo "Age: $age"
echo "Price: $price"

# Alternative syntax
echo "Name: ${name}"

# Combining
echo "Hello, ${name}!"
```

### Variable Types
```bash
# String
greeting="Hello World"

# Integer
count=42

# Float (treated as string in basic bash)
price=19.99

# Array
colors=("red" "green" "blue")
```

### Unsetting Variables
```bash
name="John"
unset name         # Delete variable
echo $name         # Empty output
```

---

## 📝 Special Variables

### Command-Line Arguments
```bash
# Script: script.sh
echo "Script name: $0"
echo "First arg: $1"
echo "Second arg: $2"
echo "Third arg: $3"
echo "All args: $@"
echo "All args: $*"
echo "Number of args: $#"

# Usage: ./script.sh arg1 arg2 arg3
```

| Variable | Description |
|----------|-------------|
| `$0` | Script name |
| `$1` - `$9` | Arguments 1-9 |
| `${n}` | Argument n (for n>9) |
| `$@` | All arguments (as separate strings) |
| `$*` | All arguments (as single string) |
| `$#` | Number of arguments |
| `$$` | Current process ID |
| `$?` | Last command exit status |
| `$!` | Last background process ID |

### Example
```bash
#!/bin/bash
# Args: $@ = arg1 arg2 arg3
echo "You provided $# arguments"
echo "They are: $@"
```

### `"$@"` vs `"$*"` (Important)
```bash
#!/bin/bash

for arg in "$@"; do
    echo "[$arg]"
done

# If script is run as:
# ./script.sh "hello world" bash
#
# "$@" keeps arguments separate:
# [hello world]
# [bash]
#
# "$*" joins them into one string:
# [hello world bash]
```

### Safe Argument Habits
```bash
# Good: quote variables and arguments
cp "$source_file" "$target_file"
grep "$pattern" "$file"

# Good: forward command-line arguments safely
some_command "$@"

# Risky: word splitting and globbing can happen
cp $source_file $target_file
some_command $@
```

---

## 🧮 Arithmetic Operations

### Using `expr`
```bash
a=10
b=3

# Addition
expr $a + $b          # 13
expr $a - $b          # 7
expr $a \* $b         # 30 (escape the *)
expr $a / $b          # 3
expr $a % $b          # 1
```

### Using `$(( ))` (Recommended)
```bash
a=10
b=3

echo $((a + b))       # 13
echo $((a - b))       # 7
echo $((a * b))       # 30
echo $((a / b))       # 3
echo $((a % b))       # 1

# Compound
result=$((a + b * 2))
echo $result          # 16
```

### Using `let`
```bash
let "a = 10 + 5"
let "b = a * 2"
echo $b               # 30
```

### Increment/Decrement
```bash
x=5
echo $((x++))         # 5 (print then increment)
echo $x               # 6

x=5
echo $((++x))         # 6 (increment then print)
echo $x               # 6

x=5
echo $((x--))         # 5
echo $((--x))         # 4
```

---

## 🔤 String Operations

### String Length
```bash
text="Hello World"
echo ${#text}         # 11
```

### Substring Extraction
```bash
text="Hello World"

# From position 0, length 5
echo ${text:0:5}      # Hello

# From position 6, length 5
echo ${text:6:5}      # World

# Last 5 characters
echo ${text: -5}      # World

# Length 5 from end
echo ${text:(-5)}     # World
```

### String Replacement
```bash
text="Hello World"

# Replace first match
echo ${text/World/Universe}   # Hello Universe

# Replace all matches
echo ${text//l/L}             # HeLLo WorLd

# Replace prefix
echo ${text/#Hello/Hi}        # Hi World

# Replace suffix
echo ${text/%World/Universe}  # Hello Universe
```

### Case Conversion
```bash
text="Hello World"

# To lowercase
echo ${text,,}                # hello world

# To uppercase
echo ${text^^}                # HELLO WORLD
```

---

## 📚 Arrays

### Creating Arrays
```bash
# Simple array
fruits=("apple" "banana" "cherry")

# Mixed (works but not recommended)
mixed=(apple 123 "hello world")

# Indexed manually
array[0]="first"
array[1]="second"
array[5]="sixth"
```

### Accessing Array Elements
```bash
fruits=("apple" "banana" "cherry")

echo ${fruits[0]}     # apple
echo ${fruits[1]}     # banana
echo ${fruits[2]}     # cherry

# All elements
echo ${fruits[@]}     # apple banana cherry
echo ${fruits[*]}     # apple banana cherry
```

### Array Length
```bash
fruits=("apple" "banana" "cherry")

echo ${#fruits[@]}    # 3 (element count)
echo ${#fruits[0]}   # 5 (length of first element)
```

### Array Slicing
```bash
numbers=(1 2 3 4 5 6 7 8 9 10)

echo ${numbers[@]:0:3}    # 1 2 3 (from index 0, length 3)
echo ${numbers[@]:5:3}   # 6 7 8
echo ${numbers[@]: -3}   # 8 9 10 (last 3)
```

### Array Operations
```bash
fruits=("apple" "banana" "cherry")

# Append element
fruits+=("date")
# Now: apple banana cherry date

# Remove element
unset fruits[1]
# Now: apple cherry date

# Rebuild array (fix gaps)
fruits=("${fruits[@]}")

# Get all indexes
echo ${!fruits[@]}   # 0 1 2
```

### Associative Arrays (Bash 4+)
```bash
declare -A person

person["name"]="John"
person["age"]="30"
person["city"]="NYC"

echo ${person["name"]}    # John
echo ${!person[@]}        # name age city
echo ${person[@]}          # John 30 NYC
```

### Reading Arrays Safely with `mapfile`
```bash
# Read lines from a file into an array
mapfile -t servers < servers.txt

# Print one item per line
printf '%s\n' "${servers[@]}"

# Read command output into an array
mapfile -t log_files < <(find /var/log -maxdepth 1 -name '*.log')
```

---

## 🌏 Environment Variables

### Viewing Environment Variables
```bash
# View all
env
printenv

# View specific
echo $HOME
echo $PATH
echo $USER
echo $PWD
echo $SHELL
echo $HOSTNAME
echo $RANDOM
```

### Creating Environment Variables
```bash
# Temporary (only for current session)
export MY_VAR="Hello"
echo $MY_VAR

# Permanent - add to ~/.bashrc or ~/.bash_profile
export PATH=$PATH:/new/path

# In script - only available to that script
MY_VAR="value"
export MY_VAR
```

---

## ⭐ Parameter Expansion

### Default Values
```bash
name=""
echo ${name:-"Guest"}     # Guest (use default if empty)
echo ${name:="Guest"}     # Guest (assign default if empty)
echo ${name:?"Error"}     # Error if empty (exit script)

# Non-empty default
filename=${filename:-"output.txt"}
```

### String Operations
```bash
path="/home/user/documents/file.txt"

# Remove matching prefix
echo ${path##*/}          # file.txt (longest match)
echo ${path#*/}            # home/user/documents/file.txt (shortest)

# Remove matching suffix
echo ${path%.*}            # /home/user/documents/file
echo ${path%%.*}           # /home/user/documents/file

# Get length
echo ${#path}              # 33
```

### Quoting and Expansion Safety
```bash
file_name="my report.txt"

# Good: preserve spaces exactly
echo "$file_name"
cp "$file_name" "/tmp/"

# Risky: word splitting may break it into two words
echo $file_name
cp $file_name /tmp/
```

### Expansion Order (High Level)

Bash expands commands in stages. The important beginner rule is:

1. Expansion happens before the command runs
2. Unquoted results may be split into multiple words
3. Unquoted `*` patterns may expand to filenames

```bash
name="*.txt"

# Prints the literal value
echo "$name"

# May expand to matching files in the current directory
echo $name
```

### Filename Globbing Basics
```bash
# Match files ending in .log
echo *.log

# Match one character
echo file?.txt

# Match any one of these characters
echo report_[0-9].txt
```

### Safer Shell Options
```bash
# These options help catch mistakes in scripts
set -euo pipefail

# Optional matching controls
shopt -s nullglob    # Unmatched *.log becomes nothing
shopt -s failglob    # Unmatched *.log becomes an error
```

---

## 🏆 Practice Exercises

### Exercise 1: Calculator
```bash
#!/bin/bash
# Create a simple calculator
# Usage: calc.sh 10 + 5

num1=$1
op=$2
num2=$3

case $op in
    +) echo $((num1 + num2)) ;;
    -) echo $((num1 - num2)) ;;
    \*) echo $((num1 * num2)) ;;
    /) echo $((num1 / num2)) ;;
    *) echo "Invalid operator" ;;
esac
```

### Exercise 2: User Info Script
```bash
#!/bin/bash
echo "User: $USER"
echo "Home: $HOME"
echo "Shell: $SHELL"
echo "PID: $$"
echo "Random: $RANDOM"
```

### Exercise 3: Array Operations
```bash
#!/bin/bash
# Array of numbers
numbers=(5 10 15 20 25)

echo "All: ${numbers[@]}"
echo "Count: ${#numbers[@]}"
echo "Sum: $(($(echo ${numbers[@]} | tr ' ' '+')))"

# Using awk for sum
echo "Sum via awk: $(awk 'BEGIN{for(i in ARGV) s+=ARGV[i]; print s}' "${numbers[@]}")"

# Or more simply:
sum=0
for n in "${numbers[@]}"; do
    ((sum += n))
done
echo "Sum: $sum"
```

### Exercise 4: String Manipulation
```bash
#!/bin/bash
# Extract filename and extension

path="/home/user/documents/photo.jpg"

filename=${path##*/}      # photo.jpg
basename=${filename%.*}   # photo
extension=${filename#*.}   # jpg

echo "Full: $filename"
echo "Name: $basename"
echo "Ext:  $extension"
```

---

## ✅ Stack 5 Complete!

You learned:
- ✅ Creating and using variables
- ✅ Special variables ($0, $1, $@, $$, etc.)
- ✅ Arithmetic operations ($(( )), expr, let)
- ✅ String operations (length, substring, replacement)
- ✅ Arrays (indexed and associative)
- ✅ `"$@"` vs `"$*"` argument handling
- ✅ Quoting and expansion safety
- ✅ Environment variables
- ✅ Parameter expansion (defaults, removal)

### Next: Stack 6 → Control Flow (if/else, case) →
