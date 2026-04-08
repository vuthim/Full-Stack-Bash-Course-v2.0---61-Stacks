# 🔄 STACK 29: CI/CD PIPELINES
## Continuous Integration and Deployment

**What is CI/CD?** Think of it like an automated assembly line for your code:
- Every time you save (commit), a robot tests it
- If tests pass, it automatically deploys to users
- No manual steps, no forgetting, no human errors!

---

## 🔰 What is CI/CD?

### CI (Continuous Integration)
Developers merge code changes frequently, triggering automated builds and tests.
**Goal:** Catch bugs early, before they pile up.

### CD (Continuous Delivery/Deployment)
Automatically deploy code to production after passing tests.
- **Delivery** = Ready to deploy (human pushes the button)
- **Deployment** = Automatically deployed (no human needed)

### Pipeline Flow
```
Code → Build → Test → Deploy
  ↓      ↓      ↓      ↓
Commit → CI   → QA   → Prod
```

**Real-World Analogy:**
```
Without CI/CD:  Writing a book, then reading it cover-to-cover only after finishing
With CI/CD:     Reading each chapter as you write it (catch plot holes early!)
```

---

## 🏗️ Key Concepts

### Pipeline Stages
| Stage | Purpose |
|-------|---------|
| Build | Compile code |
| Test | Run automated tests |
| Security | Scan for vulnerabilities |
| Deploy | Release to environment |

### Environments
- **Development**: Local testing
- **Staging**: Pre-production
- **Production**: Live

---

## 🐙 GitHub Actions

### Basic Workflow File
```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: |
        npm ci
        
    - name: Run tests
      run: |
        npm test
```

### More Examples
```yaml
# Deploy to server
deploy:
  runs-on: ubuntu-latest
  needs: build
  
  steps:
  - uses: actions/checkout@v3
  
  - name: Deploy to server
    uses: appleboy/ssh-action@v0.1.0
    with:
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      script: |
        cd /var/www/app
        git pull
        npm install
        pm2 restart app
```

---

## 🔧 Jenkins Pipeline

### Jenkinsfile (Declarative)
```groovy
pipeline {
    agent any
    
    environment {
        APP_NAME = 'myapp'
    }
    
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh 'npm install'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Testing...'
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deploying...'
                sh './deploy.sh'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

---

## 🌀 GitLab CI/CD

### .gitlab-ci.yml
```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

test:
  stage: test
  script:
    - npm test
  coverage: /Coverage: \d+\.\d+%/m

deploy:
  stage: deploy
  script:
    - ./deploy.sh
  only:
    - main
```

---

## 📦 Docker in CI/CD

### Docker Build and Push
```yaml
- name: Build Docker image
  run: |
    docker build -t myapp:${{ github.sha }} .
    docker tag myapp:${{ github.sha }} myapp:latest
    
- name: Push to registry
  run: |
    echo ${{ secrets.DOCKER_TOKEN }} | docker login -u ${{ secrets.DOCKER_USER }} --password-stdin
    docker push myapp/myapp
```

### Docker Compose in CI
```yaml
services:
  - docker:dind
  
steps:
  - docker-compose up -d
  - docker-compose exec -T app npm test
  - docker-compose down
```

---

## 🔒 Secrets Management

### GitHub Secrets
```yaml
- name: Deploy
  run: |
    curl -X POST ${{ secrets.WEBHOOK_URL }}
```

### Environment Variables
```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_KEY: ${{ secrets.API_KEY }}
```

---

## 🧪 Testing in Pipeline

### Multiple Test Types
```yaml
- name: Unit Tests
  run: npm run unit-test

- name: Integration Tests
  run: npm run integration-test
  
- name: E2E Tests
  run: npm run e2e-test
  
- name: Security Scan
  run: |
    npm audit --audit-level=high
    docker scan myapp:latest
```

---

## 🚀 Deployment Strategies

### Blue-Green Deployment
```bash
# Deploy to blue (staging)
docker-compose -f docker-compose.blue.yml up -d

# Test blue
curl http://blue.example.com

# Switch traffic
# Update load balancer

# Keep green for rollback
# docker-compose -f docker-compose.green.yml down
```

### Rolling Deployment
```yaml
- name: Rolling Deploy
  run: |
    for server in ${{ secrets.SERVERS }}; do
      ssh $server "cd /app && docker-compose pull && docker-compose up -d"
    done
```

---

## 📊 Monitoring Pipelines

### Notifications
```yaml
- name: Slack Notification
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    fields: repo,message,commit,author
```

---

## 🏆 Practice Exercises

### Exercise 1: Create GitHub Actions Workflow
```bash
# Create workflow directory
mkdir -p .github/workflows

# Create CI workflow
cat > .github/workflows/ci.yml << 'EOF'
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: echo "Testing..."
EOF
```

### Exercise 2: Multi-Stage Pipeline
```yaml
# Add build, test, deploy stages
# Use matrix strategy for multiple Node versions
strategy:
  matrix:
    node-version: [14, 16, 18]
```

---

## 📋 CI/CD Cheat Sheet

| Tool | Purpose |
|------|---------|
| GitHub Actions | Cloud CI/CD |
| Jenkins | Self-hosted CI/CD |
| GitLab CI | GitLab CI/CD |
| Travis CI | Cloud CI |

### Common Commands
```bash
# Jenkins
jenkins-cli build job

# GitLab
gitlab-ci-local
```

---

## 🎓 Final Project: CI/CD Pipeline Manager

Now that you've mastered CI/CD concepts, let's see how a professional scripter might automate pipeline management. We'll examine the "CI/CD Manager" — a tool that simplifies creating, running, and managing pipeline configurations for different types of projects.

### What the CI/CD Pipeline Manager Does:
1. **Lists All Pipelines** currently configured in your workspace.
2. **Generates YAML Workflows** automatically from standard templates.
3. **Simulates Pipeline Runs** to verify logic before pushing to GitHub/GitLab.
4. **Applies Project Templates** (Node.js, Python, Docker) with one command.
5. **Checks Pipeline Status** and provides a clean summary of your automation.
6. **Manages Workflow Files** programmatically, reducing manual YAML errors.

### Key Snippet: Generating Workflows with Templates
The manager uses templates to ensure that every new project starts with a robust, standard CI/CD configuration.

```bash
cmd_create() {
    local name=$1
    local pipeline_file="$HOME/ci-pipelines/${name}.yml"
    
    # Generate a standard GitHub Actions style workflow
    cat > "$pipeline_file" << EOF
name: $name Pipeline
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: echo "Building your project..."
      - name: Test
        run: echo "Running automated tests..."
EOF
    log "Pipeline '$name' created successfully!"
}
```

### Key Snippet: Template Application
By using a `case` statement, the manager can apply specific best practices for different programming languages.

```bash
cmd_apply_template() {
    local template=$1
    
    case $template in
        nodejs)
            # Add specific Node.js steps (npm install, npm test)
            cat > "$CI_DIR/nodejs.yml" << 'EOF'
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
EOF
            log "Node.js CI template applied!"
            ;;
        *)
            error "Template not found."
            ;;
    esac
}
```

**Pro Tip:** Automating the creation of your CI/CD files ensures that you never forget to include critical steps like security scanning or linting!

---

## ✅ Stack 29 Complete!

Congratulations! You've successfully automated the "factory line" of software development! You can now:
- ✅ **Understand CI/CD** and why it's critical for modern DevOps
- ✅ **Build automated pipelines** that trigger on every code change
- ✅ **Configure workflows** for GitHub Actions, GitLab CI, and Jenkins
- ✅ **Automate build and test stages** to catch bugs before users do
- ✅ **Manage secrets safely** within your CI/CD environment
- ✅ **Deploy code automatically** to production with confidence

### What's Next?
In the next stack, we'll dive into **Logging Best Practices**. You'll learn how to make your scripts talk to you through structured logs, making troubleshooting a breeze!

**Next: Stack 30 - Logging Best Practices →**

---

*End of Stack 29*