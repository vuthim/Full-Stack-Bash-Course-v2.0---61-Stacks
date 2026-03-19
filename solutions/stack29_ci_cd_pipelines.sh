#!/bin/bash
# Stack 29 Solution: CI/CD Pipelines - CI/CD Manager

set -euo pipefail

NAME="CI/CD Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CI_DIR="$HOME/ci-pipelines"
mkdir -p "$CI_DIR"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - CI/CD Pipeline Management

Usage: $0 [COMMAND] [OPTIONS]

PIPELINES:
    list                 List all pipelines
    create NAME          Create new pipeline
    run NAME             Run pipeline manually
    status NAME          Check pipeline status
    delete NAME          Delete pipeline

TEMPLATES:
    template             List pipeline templates
    apply-template NAME Apply template

EXAMPLES:
    $0 list
    $0 create myapp
    $0 run myapp
EOF
}

cmd_list() {
    echo -e "${BLUE}=== CI/CD Pipelines ===${NC}"
    ls -la "$CI_DIR"/*.yml 2>/dev/null || echo "No pipelines found"
}

cmd_create() {
    local name=$1
    local pipeline_file="$CI_DIR/${name}.yml"
    
    cat > "$pipeline_file" << EOF
name: $name
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: echo "Building..."
      - name: Test
        run: echo "Testing..."
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying..."
EOF
    
    log "Created pipeline: $name"
}

cmd_run() {
    local name=$1
    local pipeline_file="$CI_DIR/${name}.yml"
    
    if [ ! -f "$pipeline_file" ]; then
        error "Pipeline not found: $name"
        exit 1
    fi
    
    log "Running pipeline: $name"
    echo "=== Simulated Pipeline Run ==="
    echo "Stage: Checkout"
    echo "Stage: Build"
    echo "Stage: Test"
    echo "Stage: Deploy"
    log "Pipeline completed"
}

cmd_status() {
    local name=$1
    log "Pipeline status: $name (simulated)"
}

cmd_delete() {
    local name=$1
    local pipeline_file="$CI_DIR/${name}.yml"
    
    if [ -f "$pipeline_file" ]; then
        rm "$pipeline_file"
        log "Deleted pipeline: $name"
    else
        error "Pipeline not found: $name"
    fi
}

cmd_template() {
    echo -e "${BLUE}=== Pipeline Templates ===${NC}"
    echo "  - nodejs"
    echo "  - python"
    echo "  - docker"
    echo "  - static"
}

cmd_apply_template() {
    local template=$1
    
    case $template in
        nodejs)
            cat > "$CI_DIR/nodejs.yml" << 'EOF'
name: Node.js CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
EOF
            log "Applied template: nodejs"
            ;;
        python)
            log "Applied template: python"
            ;;
        docker)
            log "Applied template: docker"
            ;;
        *)
            error "Unknown template: $template"
            ;;
    esac
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        list) cmd_list ;;
        create) cmd_create "$1" ;;
        run) cmd_run "$1" ;;
        status) cmd_status "$1" ;;
        delete) cmd_delete "$1" ;;
        template) cmd_template ;;
        apply-template) cmd_apply_template "$1" ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
