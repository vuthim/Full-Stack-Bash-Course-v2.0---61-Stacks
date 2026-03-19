# 📖 STACK 3B: QUOTING, EXPANSION & SAFE FILE HANDLING
## Critical Bash Safety Fundamentals

> *"Most shell bugs come from mishandled quoting and expansion."*

---

## 🔰 Why This Matters

Improper quoting and expansion is the #1 cause of shell script failures. This lesson covers concepts that every professional Bash scripter must master.

---

## 💬 Quoting Rules

### Single Quotes vs Double Quotes

```bash
# Single quotes - LITERAL (no expansion)
name="World"
echo 'Hello $name'        # Output: Hello $name
echo 'Hello $(whoami)'    # Output: Hello $(whoami)

# Double quotes - INTERPRETED (expansion happens)
echo "Hello $name"        # Output: Hello World
echo "Hello $(whoami)"    # Output: Hello username

# When in doubt, use double quotes around variables
echo "$name"              # Safe: prints "World"
echo $name                # Dangerous: word splitting issues
```

### When to Use Quotes

| Situation | Use | Example |
|-----------|-----|---------|
| Variables | Always `"$var"` | `echo "$name"` |
| Command substitution | Double quotes | `echo "$(cmd)"` |
| Literal strings with special chars | Single quotes | `echo 'path: $HOME'` |
| Paths with spaces | Always quote | `ls "$my_path"` |
| User input | Always quote | `process "$user_input"` |

---

## 🔄 Shell Expansion

### Types of Expansion (in order)

```bash
# 1. Brace Expansion (first)
echo {1..5}                    # 1 2 3 4 5
echo {a..z}                    # a b c ... z
echo file{1,2,3}.txt           # file1.txt file2.txt file3.txt

# 2. Tilde Expansion
echo ~                         # /home/username
echo ~/Documents               # /home/username/Documents
echo ~root                     # /root

# 3. Parameter Expansion
echo ${HOME}
echo ${var:-default}           # Use default if unset
echo ${var:=default}           # Set default if unset
echo ${var:?error}             # Error if unset

# 4. Command Substitution
echo $(date)                    # Output of date command
echo `date`                     # Old syntax, avoid

# 5. Arithmetic Expansion
echo $((2 + 2))                # 4
echo $((x * 2))                # Double x

# 6. Word Splitting (usually unwanted!)
# After expansion, words split on IFS (default: space, tab, newline)
```

### Brace Expansion
```bash
# Create multiple files
touch file{1..5}.txt          # file1.txt ... file5.txt

# Copy files
cp program{,.bak}             # program program.bak

# Nested
echo {a,b{1,2}}               # a b1 b2
```

### Parameter Expansion Tricks
```bash
var="hello world"

# Length
echo ${#var}                  # 11

# Substring
echo ${var:0:5}               # hello
echo ${var:6}                 # world

# Replace
echo ${var/world/universe}    # hello universe
echo ${var//o/O}             # hellO wOrld (all o's)

# Remove pattern
echo ${var#hel}               # lo world (shortest match)
echo ${var##hel}              # lo world (longest match)
echo ${var%orld}              # hello w (shortest)
echo ${var%%orld}             # hello w (longest)

# Case modification (Bash 4+)
echo ${var^}                  # Hello world (first char uppercase)
echo ${var^^}                # HELLO WORLD (all uppercase)
echo ${var,}                  # hello world (first char lowercase)
echo ${var,,}                # hello world (all lowercase)
```

---

## ⚠️ Word Splitting - The Silent Killer

### The Problem
```bash
names="John Jane Bob"
for name in $names; do      # WRONG: loops 3 times
    echo "$name"
done

for name in "$names"; do    # RIGHT: loops 1 time
    echo "$name"
done
```

### Safe Loop Patterns
```bash
# WRONG - breaks on filenames with spaces
for file in $(ls *.txt); do
    process "$file"
done

# RIGHT - use glob directly
for file in *.txt; do
    process "$file"
done

# RIGHT - read lines properly
while IFS= read -r line; do
    process "$line"
done < file.txt
```

---

## 🛡️ Safe File Handling

### The `"$@"` Variable - Critical!

```bash
# "$@" expands to each positional parameter as a separate word
# ALWAYS use "$@" not "$*" when passing arguments

# WRONG
for arg in "$*"; do           # "$*" becomes one string
    echo "$arg"
done
# Output with args: a b c → "a b c" (1 iteration)

# RIGHT
for arg in "$@"; do           # "$@" preserves boundaries
    echo "$arg"
done
# Output with args: a b c → "a", "b", "c" (3 iterations)

# Copy all args to another command
process_files "$@"            # All args preserved
```

### Difference Between `"$@"` and `"$*"`

```bash
set -- "arg 1" "arg 2" "arg 3"

# "$*" - joins with first character of IFS (default: space)
echo "$*"                     # arg 1 arg 2 arg 3

# "$@" - each arg as separate word
echo "$@"                     # arg 1 arg 2 arg 3

# When quoted, they're identical UNLESS IFS is changed
IFS=':'
echo "$*"                     # arg 1:arg 2:arg 3
echo "$@"                     # arg 1 arg 2 arg 3
```

### Safe File Operations

```bash
# ALWAYS quote file paths
file="/path/with spaces/file.txt"
cat "$file"
rm "$file"

# Safe file reading
while IFS= read -r line; do
    echo "Line: $line"
done < "$input_file"

# Safe globbing (nullglob for no matches)
shopt -s nullglob
for f in *.txt; do
    echo "$f"
done
shopt -u nullglob

# Safe find with xargs
find . -name "*.txt" -print0 | xargs -0 process
```

### Safe Loops Over Files

```bash
# WRONG - breaks on spaces
for f in $(ls *.txt); do
    echo "$f"
done

# RIGHT - direct glob
for f in *.txt; do
    [ -e "$f" ] || continue   # Skip if no matches (nullglob)
    echo "$f"
done

# RIGHT - nullglob + check
shopt -s nullglob extglob
for f in *.txt; do
    echo "Processing: $f"
done
shopt -u nullglob extglob

# RIGHT - find with null-separated names
while IFS= read -r -d '' file; do
    echo "Processing: $file"
done < <(find . -name "*.txt" -print0)
```

---

## 🔧 Shell Options (shopt)

### Essential Safety Options

```bash
# Check current options
shopt

# nullglob - globs that match nothing expand to nothing (not the literal pattern)
shopt -s nullglob
ls *.nonexistent          # No output (not "*.nonexistent")
shopt -u nullglob

# failglob - globs that match nothing cause error
shopt -s failglob
ls *.nonexistent          # Error: no match

# dotglob - include hidden files in globs
shopt -s dotglob
ls *                      # Includes .files too

# globstar - ** matches nested directories
shopt -s globstar
ls **/*.txt               # All .txt recursively

# nocaseglob - case-insensitive globs
shopt -s nocaseglob
ls *.TXT                  # Matches .txt files too

# extglob - extended glob patterns
shopt -s extglob
ls !(*.txt)               # All except .txt
ls @(foo|bar).txt         # foo.txt or bar.txt
ls *(foo|bar).txt        # Zero or more
ls +(foo|bar).txt        # One or more
ls ?(foo|bar).txt        # Zero or one
```

### Setting Options in Scripts

```bash
#!/bin/bash
# Enable safe options at script start
set -euo pipefail
shopt -s nullglob globstar

# Your script here

# Disable at end
shopt -u nullglob globstar
```

---

## 📝 mapfile/readarray - Reading Files

```bash
# Read file into array (Bash 4+)
mapfile -t lines < file.txt
for line in "${lines[@]}"; do
    echo "$line"
done

# With delimiter
mapfile -t -d '' lines < <(find . -name "*.txt" -print0)

# readarray (alias for mapfile)
readarray -t lines < file.txt

# Read with line numbers
mapfile -t lines < file.txt
for i in "${!lines[@]}"; do
    echo "$i: ${lines[i]}"
done
```

---

## 🎯 IFS - Input Field Separator

```bash
# Default IFS: space, tab, newline

# Read CSV (comma separated)
IFS=',' read -r name age city <<< "John,30,NYC"
echo "$name $age $city"

# Read each word
IFS=' ' read -r -a words <<< "one two three"
echo "${words[0]}"          # one

# Preserving leading/trailing whitespace
IFS= read -r line           # Note: IFS= (empty)

# Reset to default
IFS=$' \t\n'
```

---

## 🚨 Common Mistakes & Fixes

### Mistake 1: Unquoted Variables
```bash
# WRONG
file="my document.txt"
rm $file                    # Tries to remove "my" and "document.txt"

# RIGHT
rm "$file"

# WRONG  
echo $variable              # Word splitting
echo "$variable"            # Safe
```

### Mistake 2: Command Substitution in `[ ]`
```bash
# WRONG
if [ $(grep pattern file) = "found" ]; then

# RIGHT - quote the expansion
if [ "$(grep pattern file)" = "found" ]; then

# Or use [[ ]] which is safer
if [[ $(grep pattern file) == "found" ]]; then
```

### Mistake 3: Forgetting `-r` in `read`
```bash
# WRONG - backslashes are interpreted
while IFS= read line; do
    echo "$line"
done < file.txt

# RIGHT - -r preserves backslashes
while IFS= read -r line; do
    echo "$line"
done < file.txt
```

### Mistake 4: Greedy Globbing
```bash
# WRONG
var="*.txt"
cat $var                     # Expands in wrong context

# RIGHT
var="*.txt"
cat $var                     # Still problematic
eval "cat $var"             # Safe if var is trusted

# BEST - use array
files=(*.txt)
cat "${files[@]}"
```

---

## ✅ Safe Script Template

```bash
#!/bin/bash
# Safe script template with proper quoting

set -euo pipefail
shopt -s nullglob globstar

# Functions
cleanup() {
    rm -f "$tmpfile"
}
trap cleanup EXIT

# Main
tmpfile=$(mktemp)

# Always quote
echo "Processing: $1"
for file in "$@" ; do
    [ -f "$file" ] || continue
    while IFS= read -r line; do
        printf '%s\n' "$line"
    done < "$file"
done
```

---

## 🏆 Practice Exercises

### Exercise 1: Quoting Test
```bash
# What does this output? Try to guess first, then test.
VAR="hello world"
echo $VAR
echo "$VAR"
echo '$VAR'
```

### Exercise 2: Fix This Script
```bash
# This script is broken. Fix it.
for file in $(ls *.log); do
    tail -n 10 $file >> all_logs.txt
done
```

### Exercise 3: Safe File Loop
```bash
# Create files with spaces in names
touch "my file 1.log" "my file 2.log"

# Write a loop that processes them safely
# (should process each file once, not break on spaces)
```

### Exercise 4: Implement Safe Arguments
```bash
#!/bin/bash
# Make this safe: handle files with spaces, special chars

for arg in "$@"; do
    echo "Argument: $arg"
done
```

---

## ✅ Stack 3B Complete!

You learned:
- ✅ Single vs double quotes
- ✅ All types of shell expansion
- ✅ Word splitting dangers
- ✅ `"$@"` vs `"$*"`
- ✅ Safe file handling patterns
- ✅ Shell options (shopt)
- ✅ mapfile/readarray
- ✅ IFS usage
- ✅ Common mistakes and fixes

### Next: Stack 4 → Text Processing Tools →

---

## 📋 Quick Reference

```bash
# Always quote variables
echo "$variable"

# Use "$@" for arguments
process "$@"

# Use -r with read
while IFS= read -r line; do

# Use nullglob
shopt -s nullglob

# Use [[ ]] instead of [ ]
[[ $var == "value" ]]

# Use set -euo pipefail
set -euo pipefail
```

---

*End of Stack 3B*
