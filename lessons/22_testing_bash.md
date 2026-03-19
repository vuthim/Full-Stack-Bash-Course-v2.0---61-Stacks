# 🧪 STACK 22: TESTING BASH SCRIPTS
## Unit Testing & Test-Driven Development

---

## 🔰 Why Test Bash Scripts?

Testing ensures:
- Scripts work as expected
- Bugs are caught early
- Changes don't break existing functionality
- Documentation is clear

---

## 🏃 Simple Test Framework

```bash
#!/bin/bash
# test_framework.sh - Simple testing

PASSED=0
FAILED=0

assert_equals() {
    local expected=$1
    local actual=$2
    local message=$3
    
    if [ "$expected" = "$actual" ]; then
        echo "✓ PASS: $message"
        ((PASSED++))
    else
        echo "✗ FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        ((FAILED++))
    fi
}

assert_true() {
    local condition=$1
    local message=$2
    
    if eval "$condition"; then
        echo "✓ PASS: $message"
        ((PASSED++))
    else
        echo "✗ FAIL: $message"
        ((FAILED++))
    fi
}

report() {
    echo ""
    echo "================================"
    echo "Tests: $PASSED passed, $FAILED failed"
    echo "================================"
    
    if [ $FAILED -gt 0 ]; then
        exit 1
    fi
}
```

---

## 📝 Writing Tests

```bash
#!/bin/bash
# test_myfunction.sh

source ./my_functions.sh  # Your functions

# Test addition
result=$(add 2 3)
assert_equals "5" "$result" "add 2 3 should return 5"

# Test greeting
result=$(greet "World")
assert_equals "Hello, World!" "$result" "greet should work"

# Test file check
touch /tmp/testfile
assert_true "[ -f /tmp/testfile ]" "file should exist"

# Run report
report
```

---

## 🧪 Using bats-core (Bash Testing)

```bash
# Install bats
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local

# Write test
cat > test_example.bats << 'EOF'
#!/usr/bin/env bats

@test "addition" {
  result=$(add 2 3)
  [ "$result" -eq 5 ]
}

@test "greeting" {
  result=$(greet "World")
  [ "$result" = "Hello, World!" ]
}
EOF

# Run tests
bats test_example.bats
```

---

## ✅ Stack 22 Complete!