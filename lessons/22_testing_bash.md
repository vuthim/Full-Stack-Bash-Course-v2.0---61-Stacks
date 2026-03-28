# 🧪 STACK 22: TESTING BASH SCRIPTS
## Unit Testing & Test-Driven Development

---

## 🔰 Why Test Bash Scripts?

Testing ensures:
- Scripts work as expected
- Bugs are caught early
- Changes don't break existing functionality
- Documentation is clear
- Refactoring is safe

### Testing Pyramid for Bash
```
        /\
       /  \     Integration Tests
      /----\    (full scripts)
     /      \
    /--------\  Unit Tests
   /          \ (functions)
  /____________\
```

---

## 🏃 Simple Test Framework

### Basic Assertion Functions
```bash
#!/bin/bash
# lib/test_framework.sh

PASSED=0
FAILED=0

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [ "$expected" = "$actual" ]; then
        echo "✓ PASS: $message"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        ((FAILED++))
        return 1
    fi
}

assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [ "$unexpected" != "$actual" ]; then
        echo "✓ PASS: $message"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Should NOT equal: '$unexpected'"
        echo "  Actual:            '$actual'"
        ((FAILED++))
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    if eval "$condition"; then
        echo "✓ PASS: $message"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Condition: $condition"
        ((FAILED++))
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"
    
    if ! eval "$condition"; then
        echo "✓ PASS: $message"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Condition: $condition"
        ((FAILED++))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
    
    if [ -f "$file" ]; then
        echo "✓ PASS: $message"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        ((FAILED++))
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain: $needle}"
    
    if echo "$haystack" | grep -q "$needle"; then
        echo "✓ PASS: $message"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Haystack: $haystack"
        echo "  Needle:   $needle"
        ((FAILED++))
        return 1
    fi
}

assert_empty() {
    local value="$1"
    local message="${2:-Should be empty}"
    
    if [ -z "$value" ]; then
        echo "✓ PASS: $message"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        echo "  Value: '$value'"
        ((FAILED++))
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-Should NOT be empty}"
    
    if [ -n "$value" ]; then
        echo "✓ PASS: $message"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL: $message"
        ((FAILED++))
        return 1
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

reset_counters() {
    PASSED=0
    FAILED=0
}
```

### Using the Framework
```bash
#!/bin/bash
# test_myfunction.sh

source ./lib/test_framework.sh
source ./my_functions.sh  # Your functions

echo "Running tests..."

# Test addition
result=$(add 2 3)
assert_equals "5" "$result" "add 2 3 should return 5"

# Test greeting
result=$(greet "World")
assert_equals "Hello, World!" "$result" "greet should work"

# Test file operations
touch /tmp/testfile
assert_file_exists "/tmp/testfile" "Test file should exist"

# Test string contains
result="Hello World"
assert_contains "$result" "World" "Should contain World"

# Run report
report
```

---

## 🧪 bats-core (Bash Testing Framework)

### Installation
```bash
# Ubuntu/Debian
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local

# macOS
brew install bats-core

# Verify
bats --version
```

### Basic bats Test File
```bash
#!/usr/bin/env bats
# test_example.bats

@test "addition" {
    result=$(add 2 3)
    [ "$result" -eq 5 ]
}

@test "greeting" {
    result=$(greet "World")
    [ "$result" = "Hello, World!" ]
}

@test "file check" {
    touch /tmp/bats_test_file
    [ -f /tmp/bats_test_file ]
}
```

### Running bats Tests
```bash
# Run single test file
bats test_example.bats

# Run multiple test files
bats test1.bats test2.bats

# Run all tests in directory
bats tests/

# Verbose output
bats --tap test.bats

# Capture stdout
bats --print-output-on-failure test.bats
```

### bats Assertions
```bash
#!/usr/bin/env bats

@test "string equals" {
    result="hello"
    [ "$result" = "hello" ]
}

@test "string not equals" {
    result="hello"
    [ "$result" != "world" ]
}

@test "number comparison" {
    value=10
    [ "$value" -gt 5 ]
    [ "$value" -lt 20 ]
    [ "$value" -ge 10 ]
    [ "$value" -le 10 ]
}

@test "file exists" {
    touch /tmp/test
    [ -f /tmp/test ]
}

@test "file not exists" {
    rm -f /tmp/nonexistent
    [ ! -f /tmp/nonexistent ]
}

@test "directory exists" {
    [ -d /tmp ]
}

@test "command exists" {
    which ls
}

@test "variable is empty" {
    value=""
    [ -z "$value" ]
}

@test "variable is not empty" {
    value="test"
    [ -n "$value" ]
}
```

### Setup and Teardown
```bash
#!/usr/bin/env bats

setup() {
    # Runs before each @test
    touch /tmp/setup_test
}

teardown() {
    # Runs after each @test
    rm -f /tmp/setup_test
}

setup_file() {
    # Runs once before all tests
    echo "Starting test suite..."
}

teardown_file() {
    # Runs once after all tests
    echo "Test suite complete!"
}

@test "first test" {
    [ -f /tmp/setup_test ]
}

@test "second test" {
    [ -f /tmp/setup_test ]
}
```

### Skip Tests
```bash
#!/usr/bin/env bats

@test "always skip" {
    skip "This test is not ready"
}

@test "conditional skip" {
    if [ ! -f /some/file ]; then
        skip "File does not exist"
    fi
}

@test "skip with reason" {
    command -v some_tool >/dev/null 2>&1 || skip "some_tool not installed"
}
```

---

## 📁 Project Structure

### Recommended Test Directory Layout
```
myproject/
├── src/
│   └── functions.sh
├── tests/
│   ├── functions.bats
│   ├── integration.bats
│   └── test_helper.bash
├── .bats
│   └── bats-core
└── Makefile
```

### Test Helper
```bash
#!/usr/bin/env bats
# tests/test_helper.bash

# Load the functions to test
load ../src/functions

# Helper function
create_temp_file() {
    touch "/tmp/test_file_$RANDOM"
}

# Stub functions
stub_command() {
    # Create a stub command
    echo '#!/bin/bash' > /tmp/stub_$1
    chmod +x /tmp/stub_$1
}
```

---

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install bats
      run: |
        git clone https://github.com/bats-core/bats-core.git
        ./bats-core/install.sh /usr/local
    
    - name: Run tests
      run: bats tests/
    
    - name: Run shellcheck
      run: |
        sudo apt install shellcheck
        shellcheck src/*.sh
```

### GitLab CI
```yaml
# .gitlab-ci.yml
test:
  image: ubuntu:latest
  before_script:
    - apt-get update && apt-get install -y bats shellcheck
  script:
    - bats tests/
```

### Makefile
```makefile
# Makefile

.PHONY: test install-test

test: install-test
	@bats tests/

install-test:
	@if ! command -v bats &> /dev/null; then \
		git clone https://github.com/bats-core/bats-core.git; \
		cd bats-core && ./install.sh /usr/local; \
	fi

lint:
	@shellcheck src/*.sh

ci: test lint
```

---

## 🧩 Testing Functions

### Testing Pure Functions
```bash
# src/math.sh
add() {
    echo $(($1 + $2))
}

multiply() {
    echo $(($1 * $2))
}

is_even() {
    [ $(($1 % 2)) -eq 0 ]
}
```

```bash
# tests/math.bats
#!/usr/bin/env bats

load ../src/math

@test "add: 2 + 3 = 5" {
    result=$(add 2 3)
    [ "$result" -eq 5 ]
}

@test "add: negative numbers" {
    result=$(add 5 -3)
    [ "$result" -eq 2 ]
}

@test "multiply: 3 * 4 = 12" {
    result=$(multiply 3 4)
    [ "$result" -eq 12 ]
}

@test "is_even: 4 is even" {
    is_even 4
}

@test "is_even: 5 is not even" {
    ! is_even 5
}
```

### Testing File Operations
```bash
# tests/file_ops.bats

@test "create_backup creates backup file" {
    source ../src/file_ops
    
    # Run function
    create_backup /etc/hosts
    
    # Check result
    [ -f "/etc/hosts.backup.$(date +%Y%m%d)" ]
}

@test "cleanup removes old backups" {
    source ../src/file_ops
    
    # Create old backup
    touch /tmp/old_backup.20200101
    
    # Run cleanup
    cleanup 0  # Keep nothing
    
    # Verify
    [ ! -f /tmp/old_backup.20200101 ]
}
```

### Testing Error Handling
```bash
# src/validate.sh

validate_input() {
    local input="$1"
    
    if [ -z "$input" ]; then
        echo "Error: Input cannot be empty" >&2
        return 1
    fi
    
    if ! [[ "$input" =~ ^[a-zA-Z]+$ ]]; then
        echo "Error: Input must contain only letters" >&2
        return 1
    fi
    
    echo "Valid: $input"
    return 0
}
```

```bash
# tests/validate.bats

@test "validate_input: empty input returns error" {
    run validate_input ""
    [ "$status" -ne 0 ]
    [ "$output" = "Error: Input cannot be empty" ]
}

@test "validate_input: invalid chars returns error" {
    run validate_input "test123"
    [ "$status" -ne 0 ]
}

@test "validate_input: valid input succeeds" {
    run validate_input "hello"
    [ "$status" -eq 0 ]
    [ "$output" = "Valid: hello" ]
}
```

---

## 🎯 Test-Driven Development Example

### Step 1: Write Failing Test
```bash
# tests/calculate.bats
#!/usr/bin/env bats

@test "calculate_total: sums items correctly" {
    result=$(calculate_total "10,20,30")
    [ "$result" -eq 60 ]
}

@test "calculate_total: handles single item" {
    result=$(calculate_total "50")
    [ "$result" -eq 50 ]
}

@test "calculate_total: handles empty string" {
    result=$(calculate_total "")
    [ "$result" -eq 0 ]
}
```

### Step 2: Run Test (It Should Fail)
```bash
$ bats tests/calculate.bats
 ✗ calculate_total: sums items correctly
   (in test file tests/calculate.bats, line 4)
   /tmp/bats-run-XXXX: command not found
```

### Step 3: Implement Function
```bash
# src/calculate.sh

calculate_total() {
    local items="$1"
    local total=0
    
    if [ -z "$items" ]; then
        echo 0
        return
    fi
    
    IFS=',' read -ra nums <<< "$items"
    for num in "${nums[@]}"; do
        total=$((total + num))
    done
    
    echo $total
}
```

### Step 4: Run Test (Should Pass)
```bash
$ bats tests/calculate.bats
 ✓ calculate_total: sums items correctly
 ✓ calculate_total: handles single item
 ✓ calculate_total: handles empty string
```

---

## ⚠️ Common Testing Mistakes

### DON'T
```bash
# ❌ Testing implementation details
@test "check internal variable" {
    # Hard to test, refactor instead
    [ "$internal_var" = "value" ]
}

# ❌ Tests that depend on each other
@test "second test" {
    # Relies on first test creating something
}

# ❌ No assertions
@test "do something" {
    my_function  # Just runs, no check
}

# ❌ Tests that are too broad
@test "everything works" {
    # Too much, hard to debug failures
}
```

### DO
```bash
# ✅ Test behavior, not implementation
@test "returns correct sum" {
    result=$(add 2 3)
    [ "$result" -eq 5 ]
}

# ✅ Independent tests
@test "creates file" {
    my_function
    [ -f /tmp/output ]
}

# ✅ Clear assertions
@test "returns error for empty input" {
    run my_function ""
    [ "$status" -ne 0 ]
}

# ✅ One concern per test
@test "handles valid input" { }
@test "handles invalid input" { }
@test "handles empty input" { }
```

---

## 📝 Exercises

### Exercise 1: Simple Framework
Create a simple test framework with:
1. `assert_equals`
2. `assert_true`
3. `assert_file_exists`
4. Test counter and report

### Exercise 2: bats Tests
Write bats tests for a string utility library:
1. `reverse_string`
2. `uppercase`
3. `is_palindrome`

### Exercise 3: CI Integration
Add GitHub Actions workflow to run tests automatically

### Exercise 4: Error Handling
Write tests that verify:
1. Proper error messages
2. Correct exit codes
3. Invalid input handling

---

## ✅ Stack 22 Complete!

You learned:
- ✅ Simple test framework basics
- ✅ bats-core installation and usage
- ✅ bats assertions and helpers
- ✅ Setup/teardown functions
- ✅ CI/CD integration (GitHub, GitLab)
- ✅ Testing strategies (TDD)
- ✅ Common mistakes to avoid

### Next: Stack 23 - Security Scripting →

---

*End of Stack 22*
