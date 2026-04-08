# ✅ STACK 44: SHELLCHECK
## Bash Script Linting and Quality

**What is ShellCheck?** Think of ShellCheck as a "spell checker for your bash scripts." Just like your word processor catches typos, ShellCheck catches bugs, security issues, and bad practices BEFORE you run your script!

**Why This Matters:** ShellCheck is the #1 tool for catching "I didn't know that was a problem" bugs. Many infamous script disasters (like the `rm -rf /` bug) would have been caught instantly.

---

## 🔰 What is ShellCheck?

ShellCheck is a static analysis tool that finds bugs and issues in shell scripts.

### Why Use ShellCheck? (The Benefits)
- ✅ **Catches common errors** - Unquoted variables, wrong operators, missing escapes
- ✅ **Enforces best practices** - Proper quoting, error handling, safe patterns
- ✅ **Improves script quality** - Cleaner, more reliable code
- ✅ **Prevents bugs** - Find issues before they cause real damage

### ShellCheck Analogy for Beginners
```
Writing a script without ShellCheck:
  → Send an email without proofreading (oops!)

Writing with ShellCheck:
  → Email with autocorrect catching your mistakes (safe!)
```

---

## ⚡ Installing ShellCheck

### Ubuntu/Debian
```bash
sudo apt install shellcheck
```

### macOS
```bash
brew install shellcheck
```

### From Source
```bash
# Download
wget -O shellcheck.tar.xz https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz

# Extract
tar -xf shellcheck.tar.xz
sudo cp shellcheck-stable/shellcheck /usr/local/bin/
```

---

## 🔍 Using ShellCheck

### Basic Usage
```bash
# Check a script
shellcheck myscript.sh

# Check specific shell
shellcheck -s bash script.sh
shellcheck -s sh script.sh

# Use standard
shellcheck -s bash --shell=bash script.sh
```

### Exit Codes
```bash
# 0: No issues
# 1: Errors
# 2: Warnings
# 3: Info/Style

# Use in CI/CD
shellcheck script.sh || exit 1
```

---

## 📝 Common Warnings

### SC2086: Quote Variables
```bash
# Wrong
echo $var

# Correct
echo "$var"

# ShellCheck message
# SC2086: Double quote to prevent globbing
```

### SC2166: Use && Instead of -a
```bash
# Wrong
if [ $a -eq 1 -a $b -eq 2 ]; then

# Correct
if [ "$a" -eq 1 ] && [ "$b" -eq 2 ]; then
```

### SC2004: $ Not Needed
```bash
# Wrong
echo ${var}

# Correct (most cases)
echo $var
```

### Common Issues
| Code | Issue |
|------|-------|
| SC2086 | Quote variables |
| SC2166 | Use && not -a |
| SC2004 | $ not needed |
| SC2128 | Empty array |
| SC2148 | Add shebang |
| SC1090 | Can't follow non-constant source |

---

## ⚙️ Configuration

### .shellcheckrc
```bash
# Create in project root
# .shellcheckrc
enable=all
shell=bash
exclude=SC1090,SC2034
source=./lib.sh

# Disable specific warnings
disable=SC2086,SC2166
```

### Inline Comments
```bash
# Disable warning for specific line
echo "$foo bar"  # shellcheck disable=SC2086
```

---

## 🔄 Git Integration

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check bash scripts
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$'); do
    if ! shellcheck "$file"; then
        echo "ShellCheck failed on $file"
        exit 1
    fi
done
```

### GitHub Actions
```yaml
name: ShellCheck

on: [push, pull_request]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
```

---

## 🏆 Practice Exercises

### Exercise 1: Check Script
```bash
# Create script with issues
cat > test.sh << 'EOF'
#!/bin/bash
var="hello"
echo $var world
if [ $var == "hello" ]; then
    echo yes
fi
EOF

# Check
shellcheck test.sh

# Fix issues and check again
```

### Exercise 2: CI Integration
```yaml
# .github/workflows/shellcheck.yml
name: ShellCheck

on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run ShellCheck
        run: |
          shellcheck scripts/*.sh
```

### Exercise 3: Fix Script
```bash
# Test script
cat > fixme.sh << 'EOF'
#!/bin/bash
files=$(ls *.txt)
for f in $files; do
    echo $f
done

[ -z "$files" ] && echo "No files"
EOF

# Run and fix all issues
shellcheck -S error fixme.sh
```

---

## 📋 ShellCheck Codes

| Code | Description |
|------|-------------|
| SC1xxx | Parsing |
| SC2xxx | Variables |
| SC3xxx | Conditionals |
| SC2xxx | Loops |
| SC2xxx | Functions |

### Most Important
- SC2086: Quote variables
- SC2166: Use && not -a
- SC2006: Use $(..) not `..`
- SC2148: Add shebang

---

## 🎓 Final Project: Script Quality & Format Manager

Now that you've learned the common pitfalls of Bash scripting, let's see how a professional software engineer might automate code quality. We'll examine the "ShellCheck Runner" — a tool that automatically scans your scripts for bugs, enforces best practices, and even formats your code for readability.

### What the Script Quality & Format Manager Does:
1. **Audits Individual Scripts** using ShellCheck to find hidden bugs and security risks.
2. **Bulk Scans Entire Directories** to ensure every script in your project is high-quality.
3. **Automates Code Formatting** using tools like `shfmt` to keep your code pretty.
4. **Simplifies Installation** by detecting your system and installing ShellCheck for you.
5. **Provides Color-Coded Feedback** making it easy to spot where your scripts need work.
6. **Integrates with CI/CD** logic to prevent "dirty" code from being saved.

### Key Snippet: Bulk Auditing with Find
Instead of checking every file manually, the manager uses `find` to locate every shell script and run a quality check on each one.

```bash
cmd_check_all() {
    local dir=${1:-.}
    echo "Scanning all scripts in $dir..."
    
    # find: look for files ending in .sh
    # while read: process each file one by one
    find "$dir" -name "*.sh" -type f | while read -r file; do
        echo "=== Checking: $file ==="
        shellcheck "$file" || true # Continue even if errors are found
    done
}
```

### Key Snippet: Automated Formatting
Writing clean code is hard; having a tool do it for you is easy. The manager uses `shfmt` to standardize indentation and spacing.

```bash
cmd_format() {
    local file=$1
    
    # shfmt -w: Write the changes directly to the file
    if command -v shfmt &>/dev/null; then
        shfmt -w "$file"
        log "Formatted '$file' to professional standards."
    else
        error "shfmt not found. Please install it to use formatting."
    fi
}
```

**Pro Tip:** Running this manager on your code before you share it with others is the best way to look like a Bash expert!

---

## ✅ Stack 44 Complete!

Congratulations! You've successfully implemented an "automated mentor" for your code! You can now:
- ✅ **Use ShellCheck** to find bugs that even experts miss
- ✅ **Understand SC warnings** and how to fix variable, loop, and quoting issues
- ✅ **Automate code formatting** for consistent and readable scripts
- ✅ **Perform bulk audits** across large project directories
- ✅ **Integrate linting** into your professional development workflow
- ✅ **Write safer, faster, and more portable** Bash code

### What's Next?
In the next stack, we'll dive into **Advanced Patterns**. You'll learn how to apply "Design Patterns" to Bash, turning simple scripts into sophisticated software architecture!

**Next: Stack 45 - Advanced Patterns →**

---

*End of Stack 44*
- **Previous:** [Stack 43 → Windows WSL](43_wsl.md)
-- **Next:** [Stack 45 - Advanced Patterns](45_advanced_patterns.md)