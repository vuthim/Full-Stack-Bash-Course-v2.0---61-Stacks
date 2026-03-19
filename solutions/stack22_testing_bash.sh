#!/bin/bash
# Stack 22 Solution: Testing Bash Scripts - Test Framework

set -euo pipefail

NAME="Bash Test Framework"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_RUN=0

log_pass() { echo -e "${GREEN}✓ PASS${NC}: $*"; ((TESTS_PASSED++)); ((TESTS_RUN++)); }
log_fail() { echo -e "${RED}✗ FAIL${NC}: $*"; ((TESTS_FAILED++)); ((TESTS_RUN++)); }
log_info() { echo -e "${BLUE}[INFO]${NC}: $*"; }

assert_equals() {
    local expected=$1
    local actual=$2
    local msg=${3:-"Assertion failed"}
    
    if [ "$expected" = "$actual" ]; then
        log_pass "$msg"
    else
        log_fail "$msg (expected: '$expected', got: '$actual')"
    fi
}

assert_contains() {
    local haystack=$1
    local needle=$2
    local msg=${3:-"Assertion failed"}
    
    if echo "$haystack" | grep -q "$needle"; then
        log_pass "$msg"
    else
        log_fail "$msg ('$needle' not found in '$haystack')"
    fi
}

assert_file_exists() {
    local file=$1
    local msg=${2:-"File should exist: $file"}
    
    if [ -f "$file" ]; then
        log_pass "$msg"
    else
        log_fail "$msg"
    fi
}

assert_dir_exists() {
    local dir=$1
    local msg=${2:-"Directory should exist: $dir"}
    
    if [ -d "$dir" ]; then
        log_pass "$msg"
    else
        log_fail "$msg"
    fi
}

assert_command_exists() {
    local cmd=$1
    local msg=${2:-"Command should exist: $cmd"}
    
    if command -v "$cmd" &>/dev/null; then
        log_pass "$msg"
    else
        log_fail "$msg"
    fi
}

assert_success() {
    local cmd=$*
    if eval "$cmd" &>/dev/null; then
        log_pass "Command succeeded: $cmd"
    else
        log_fail "Command failed: $cmd"
    fi
}

assert_failure() {
    local cmd=$*
    if ! eval "$cmd" &>/dev/null; then
        log_pass "Command failed as expected: $cmd"
    else
        log_fail "Command should have failed: $cmd"
    fi
}

print_summary() {
    echo ""
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}         TEST SUMMARY${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo -e "Total:  $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    fi
}

log_info "Test framework loaded"
log_info "Use: assert_equals, assert_contains, assert_file_exists, etc."
log_info "End tests with: print_summary"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_info "Running example tests..."
    
    assert_equals "hello" "hello" "String equality"
    assert_contains "hello world" "world" "String contains"
    assert_file_exists "/etc/passwd" "System file exists"
    assert_command_exists "bash" "Bash command exists"
    assert_success "echo test" "Simple command"
    
    print_summary
fi
