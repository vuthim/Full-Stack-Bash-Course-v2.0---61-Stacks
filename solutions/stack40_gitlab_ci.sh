#!/bin/bash
# Stack 40 Solution: GitLab CI/CD - GitLab CI Manager

set -euo pipefail

NAME="GitLab CI Manager"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

GITLAB_DIR="$HOME/gitlab-ci"
mkdir -p "$GITLAB_DIR"

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - GitLab CI/CD Management

Usage: $0 [COMMAND] [OPTIONS]

PIPELINE:
    create PROJECT       Create .gitlab-ci.yml
    validate FILE        Validate CI file
    list                List pipelines

TEMPLATE:
    template TYPE       Create template
    apply TYPE          Apply template

RUNNER:
    runner-register     Register runner
    runner-list         List runners

EXAMPLES:
    $0 create myproject
    $0 template docker
EOF
}

cmd_create() {
    local project=$1
    local ci_file="$GITLAB_DIR/.gitlab-ci.yml"
    
    cat > "$ci_file" << EOF
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - echo "Building..."
  artifacts:
    paths:
      - build/

test:
  stage: test
  script:
    - echo "Testing..."

deploy:
  stage: deploy
  script:
    - echo "Deploying..."
  only:
    - main
EOF
    
    log "Created .gitlab-ci.yml for $project"
}

cmd_validate() {
    local file=$1
    
    if command -v gitlab-runner &>/dev/null; then
        gitlab-runner validate --docker
    else
        log "GitLab runner not installed - manual validation required"
    fi
}

cmd_list() {
    echo -e "${BLUE}=== GitLab CI Files ===${NC}"
    ls -la "$GITLAB_DIR"/*.yml 2>/dev/null || echo "No CI files found"
}

cmd_template() {
    local type=$1
    
    case $type in
        docker)
            cat > "$GITLAB_DIR/docker.yml" << 'EOF'
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
EOF
            log "Created Docker template"
            ;;
        nodejs)
            cat > "$GITLAB_DIR/nodejs.yml" << 'EOF'
build:
  stage: build
  image: node:latest
  cache:
    paths:
      - node_modules/
  script:
    - npm ci
    - npm run build
EOF
            log "Created Node.js template"
            ;;
        python)
            log "Created Python template"
            ;;
        *)
            error "Unknown template: $type"
            ;;
    esac
}

cmd_apply() {
    local type=$1
    cmd_template "$type"
}

cmd_runner_register() {
    log "Registering GitLab runner..."
    sudo gitlab-runner register --non-interactive
}

cmd_runner_list() {
    sudo gitlab-runner list 2>/dev/null || echo "No runners configured"
}

main() {
    local cmd=${1:-}
    shift || true
    
    case $cmd in
        create) cmd_create "$1" ;;
        validate) cmd_validate "$1" ;;
        list) cmd_list ;;
        template) cmd_template "$1" ;;
        apply) cmd_apply "$1" ;;
        runner-register) cmd_runner_register ;;
        runner-list) cmd_runner_list ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
