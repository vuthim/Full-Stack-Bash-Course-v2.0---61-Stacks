# ✅ STACK 44: SHELLCHECK
## Bash Script Linting and Quality

---

## 🔰 What is ShellCheck?

ShellCheck is a static analysis tool that finds bugs and issues in shell scripts.

### Why Use ShellCheck?
- Catches common errors
- Enforces best practices
- Improves script quality
- Prevents bugs

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

## ✅ Stack 44 Complete!

You learned:
- ✅ What is ShellCheck
- ✅ Installation
- ✅ Basic usage
- ✅ Common warnings
- ✅ Configuration
- ✅ CI integration

### Next: Stack 45 - Advanced Patterns →

---

*End of Stack 44*