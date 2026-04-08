# 🔄 STACK 12B: BASH PORTABILITY & POSIX
## Writing Scripts That Work Everywhere

> *"Write for POSIX, enhance with Bash."*

---

## 🔰 Why Portability Matters

| Shell | Used On | Features |
|-------|---------|----------|
| `bash` | Linux, macOS (old), BSD | Full features |
| `sh` (dash) | Debian/Ubuntu /bin/sh | POSIX only, fast |
| `sh` (bash) | macOS /bin/sh | Limited |
| `sh` (zsh) | Some embedded systems | Varies |
| `sh` (busybox) | Embedded/containers | Minimal |

### Real-World Scenarios
- CI/CD runners may use `dash` as `/bin/sh`
- Alpine Linux uses BusyBox ash
- Docker minimal images have limited shells
- System scripts in `/bin/` often need POSIX compliance

---

## 📋 POSIX vs Bash Features

### What's POSIX (Portable)
```bash
# Variables (basic)
var="value"
echo "$var"

# Conditionals
if [ "$var" = "test" ]; then
    echo "yes"
fi

# Case statement
case "$var" in
    foo) echo "foo" ;;
    *) echo "other" ;;
esac

# Loops
for i in a b c; do
    echo "$i"
done

while read line; do
    echo "$line"
done

# Functions
func() {
    echo "$1"
}

# Basic parameter expansion
${var:-default}
${var:=default}
${#var}

# Command substitution
$(cmd)
`cmd`

# Arithmetic (limited)
$((a + b))

# Standard utilities: sed, awk, grep, etc.
```

### What's Bash-Only (Not Portable)
```bash
# Arrays
arr=(one two three)
echo "${arr[0]}"
echo "${arr[@]}"           # Entire array

# Associative arrays (Bash 4+)
declare -A dict
dict[key]=value

# [[ ]] instead of [ ]
[[ $var == pattern* ]]     # Regex in [[ ]]

# Process substitution
while read line; do
    echo "$line"
done < <(grep pattern file)

# Mapfile/readarray
mapfile -t lines < file.txt

# Bash-specific options
shopt -s nullglob
shopt -s globstar

# Extended globs
rm !(*.txt)                # Requires shopt -s extglob

# $SECONDS
echo $SECONDS

# PIPESTATUS
echo "${PIPESTATUS[@]}"

# BASH_SOURCE, FUNCNAME arrays
echo "${FUNCNAME[@]}"

# Here strings
grep pattern <<< "$var"

# Coprocesses
coproc NAME { command; }

# BASH_REMATCH
[[ "test" =~ t.*t ]] && echo "${BASH_REMATCH[0]}"
```

---

## 📝 Shebang Decisions

### Standard Shebangs
```bash
#!/bin/bash          # Bash (may not exist everywhere)
#!/bin/sh            # POSIX sh (more portable)
#!/usr/bin/env bash # Find bash in PATH (most portable)

# For POSIX scripts:
#!/bin/sh            # Preferred for /bin/sh

# For Bash scripts:
#!/usr/bin/env bash # Finds bash in PATH
```

### When to Use Which

| Script Type | Shebang | Reason |
|-------------|---------|--------|
| System init scripts | `#!/bin/sh` | Must work in recovery |
| Cron jobs | `#!/bin/sh` | May run in minimal env |
| Personal tools | `#!/bin/bash` | Use full features |
| Libraries | Depends | Document requirements |
| CI/CD scripts | `#!/bin/bash` | Usually available |

---

## 🔧 Writing Portable Scripts

### Portable Script Template
```bash
#!/bin/sh
# Portable POSIX script template

# Exit on error
set -e

# Unset variables are errors
set -u

# Portable way to get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Use POSIX utilities
# sed, awk, grep, cut, tr, etc.

# Functions
log() {
    printf '%s\n' "$*"
}

# Main
log "Starting..."
```

### Portable Variable Operations
```bash
# WRONG - Bash-specific
echo "${var:-default}"

# RIGHT - POSIX compatible
: "${var:=default}"
echo "$var"

# Get path dirname portably
dirname "$0"
basename "$0"

# String length
${#var}                     # POSIX
```

### Portable Arithmetic
```bash
# POSIX arithmetic
result=$((a + b * c))

# Note: No +=, ++, etc. in pure POSIX
i=$((i + 1))               # Instead of ((i++))

# Floating point - use awk or bc
result=$(awk 'BEGIN {print 3.14 * r, r=2}')

# Better: use bc
result=$(echo "scale=2; 10 / 3" | bc)
```

### Portable String Operations
```bash
# Substring (POSIX) - use expr
sub=$(expr "$var" : '\(.....\)')  # First 5 chars
sub=$(expr "$var" : '.*\(.....\)') # Last 5 chars

# Or use cut
echo "$var" | cut -c1-5

# Pattern matching - use case
case "$var" in
    foo*) echo "starts with foo" ;;
    *bar) echo "ends with bar" ;;
    *)    echo "other" ;;
esac

# Replace (no direct replacement in pure POSIX)
# Use sed
echo "$var" | sed 's/old/new/g'
```

---

## 🛠️ Detecting and Testing

### Check Available Shell
```bash
#!/bin/sh
# Check if we have bash
if [ -n "${BASH_VERSION:-}" ]; then
    # Bash-specific code
    shopt -s nullglob
fi

# Check for features
if [ -n "${ZSH_VERSION:-}" ]; then
    echo "Running in Zsh"
fi
```

### Testing for POSIX Compliance
```bash
# Check with dash
dash -n script.sh

# Check with sh
sh -n script.sh

# Use shellcheck for portability warnings
shellcheck -s sh script.sh

# Test on multiple shells
for shell in /bin/sh /bin/dash /bin/bash; do
    [ -x "$shell" ] && $shell -n script.sh && echo "$shell: OK"
done
```

### Shellcheck Portability Settings
```bash
# Ignore bash-specific warnings for POSIX scripts
shellcheck -s sh -e SC2035 script.sh

# Common flags:
# -s sh      : Assume POSIX sh
# -s bash    : Assume Bash
# -e SCxxxx  : Exclude specific warning
```

---

## 📦 Portable Library Patterns

### Cross-Platform `has()` Function
```sh
# Check if command exists
has() {
    command -v "$1" >/dev/null 2>&1
}

# Usage
if has curl; then
    curl -s https://example.com
elif has wget; then
    wget -qO- https://example.com
fi
```

### Portable Echo
```sh
# Echo without newline
printf '%s' "$text"

# Echo with newline
printf '%s\n' "$text"

# Avoid echo -e (not portable)
# Use printf instead
```

### Portable Read
```sh
# Basic read
echo "Enter name:"
read name

# With prompt (portable)
printf 'Enter name: '
read name

# Read with default
: "${name:=anonymous}"
```

### Portable Temporary Files
```sh
# POSIX temporary file
tmpfile=$(mktemp)

# Or fallback
: "${TMPDIR:=/tmp}"
tmpfile="${TMPDIR}/script.$$"

# Cleanup
trap 'rm -f "$tmpfile"' EXIT INT TERM
```

---

## ⚠️ Common Portability Pitfalls

### Pitfall 1: Arrays
```sh
# WRONG - not portable
for item in "${array[@]}"; do

# RIGHT - use space-separated string
for item in $string; do

# Or use while read
echo "$string" | tr ' ' '\n' | while read item; do
```

### Pitfall 2: [[ ]]
```sh
# WRONG - not POSIX
if [[ $var == "test" ]]; then

# RIGHT - use [ ]
if [ "$var" = "test" ]; then

# For pattern matching in POSIX
if [ "$var" != "${var#test}" ]; then
    echo "starts with test"
fi
```

### Pitfall 3: $()
```sh
# Actually $() IS POSIX
result=$(command)

# The old backtick form ` ` also works
result=`command`

# Nested command substitution
# POSIX (but hard to read)
result=$(grep "$(echo pattern)" file)
```

### Pitfall 4: Local Variables
```sh
# WRONG - local is bash-specific
func() {
    local var="value"
}

# RIGHT - POSIX (no local keyword needed)
func() {
    var="value"
}

# Or use subshell
func() (
    var="value"
)
```

### Pitfall 5: Source with .
```sh
# . is POSIX (not "source")
. ./library.sh

# This works too (but less portable)
# source ./library.sh
```

---

## 📊 Shell Feature Comparison

| Feature | POSIX sh | Bash | Dash |
|---------|----------|------|------|
| Variables | Yes | Yes | Yes |
| Arrays | No | Yes | No |
| Functions | Yes | Yes | Yes |
| `[[ ]]` | No | Yes | No |
| `$()` | Yes | Yes | Yes |
| `${var:=default}` | Yes | Yes | Yes |
| `set -euo pipefail` | partial | Yes | partial |
| Process substitution | No | Yes | No |
| shopt | No | Yes | No |
| mapfile | No | Yes | No |
| coproc | No | Yes | No |
| Associative arrays | No | Yes (4+) | No |

---

## 🎯 When to Be Portable

### Be Portable When:
- Writing system scripts (`/etc/init.d/`)
- Cron jobs in minimal environments
- Scripts distributed to many machines
- Embedded systems
- Container entrypoints (Alpine-based)
- Scripts that will be maintained long-term

### Can Use Bash When:
- Personal/developer tools
- CI/CD pipelines (Bash available)
- Modern containers (Bash installed)
- Internal organization tools
- Clearly documented as "requires Bash"

---

## 🏆 Practice Exercises

### Exercise 1: Convert to POSIX
```bash
# Convert this Bash script to POSIX sh
#!/bin/bash
declare -A config
config[name]="app"
config[version]="1.0"
for key in "${!config[@]}"; do
    echo "$key: ${config[$key]}"
done
```

### Exercise 2: Write Portable Script
```bash
# Write a script that:
# - Uses only POSIX features
# - Checks for required commands
# - Works on Linux and macOS
# - Has a shebang choice you can defend
```

### Exercise 3: Test Your Scripts
```bash
# Test these scripts with different shells:
# - bash
# - dash
# - sh (whatever is default)

# Check if they work correctly
```

---

## 🎓 Final Project: The Universal POSIX Bootstrap

Now that you've mastered the differences between Bash and POSIX, let's look at how a professional DevOps engineer might build a "Bootstrap" script. This is a script that runs on any new server (even a minimal Alpine Linux or a legacy Unix box) to detect the environment and install necessary tools.

### What the Universal POSIX Bootstrap Does:
1. **Detects the Shell Environment** (identifies if it's running in Bash, Zsh, or pure POSIX `sh`).
2. **Performs Dependency Audits** using the portable `command -v` to check for required tools like `curl` or `wget`.
3. **Implements Defensive Logging** using the portable `printf` instead of the non-standard `echo -e`.
4. **Handles Errors Gracefully** using `set -e` to ensure the bootstrap stops if a critical step fails.
5. **Standardizes Variable Defaults** using the portable `${VAR:=default}` syntax.
6. **Cleans Up Resources** by using `trap` to remove temporary files, regardless of the shell version.

### Key Snippet: The Cross-Platform Dependency Checker
A professional bootstrap script should always check if it has the "tools for the job" before trying to use them.

```sh
# A portable way to check for a command (works in sh, bash, zsh, dash)
has() {
    command -v "$1" >/dev/null 2>&1
}

# Use it to choose between different tools
if has curl; then
    download_cmd="curl -sSL"
elif has wget; then
    download_cmd="wget -qO-"
else
    echo "Error: Neither curl nor wget found. Cannot proceed!" >&2
    exit 1
fi
```

### Key Snippet: Detecting Bash Power
Even if you write a portable script, you might want to "unlock" Bash features if they happen to be available.

```sh
if [ -n "${BASH_VERSION:-}" ]; then
    # We are in Bash! Let's enable some safe options
    shopt -s nullglob
    echo "Bash mode enabled: Extra safety features active."
else
    echo "Standard POSIX mode: Using minimal features for maximum compatibility."
fi
```

**Pro Tip:** Writing POSIX-compliant scripts is like building with "Universal Parts." It takes a bit more effort, but your tools will work on everything from a tiny Raspberry Pi to a massive enterprise mainframe!

---

## ✅ Stack 12B Complete!

Congratulations! You've successfully mastered the art of "Shell Agnosticism"! You can now:
- ✅ **Identify the differences** between POSIX `sh` and modern Bash
- ✅ **Choose the right shebang** (`#!/bin/sh` vs `#!/bin/bash`) for any job
- ✅ **Write universal scripts** that run on Alpine, Ubuntu, macOS, and more
- ✅ **Audit dependencies** portably using `command -v`
- ✅ **Avoid common pitfalls** like using Bash-only arrays or `[[ ]]` in POSIX
- ✅ **Test for compliance** using `dash` and `shellcheck`

### What's Next?
Now that your scripts are portable and robust, it's time to put them on autopilot! In the next stack, we'll dive into **Cron & Scheduling** to learn how to run your code at specific times, every day, forever!

**Next: Stack 13 - Cron & Scheduling →**

---

*End of Stack 12B*
- **Previous:** [Stack 12 → Advanced Scripting](12_advanced_scripting.md)
- **Next:** [Stack 13 - Cron & Scheduling](13_cron_scheduling.md) 