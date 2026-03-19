# 🔄 STACK 29: CI/CD PIPELINES
## Continuous Integration and Deployment

---

## 🔰 What is CI/CD?

### CI (Continuous Integration)
Developers merge code changes frequently, triggering automated builds and tests.

### CD (Continuous Delivery/Deployment)
Automatically deploy code to production after passing tests.

### Pipeline Flow
```
Code → Build → Test → Deploy
  ↓      ↓      ↓      ↓
Commit → CI   → QA   → Prod
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

## ✅ Stack 29 Complete!

You learned:
- ✅ CI/CD concepts and pipeline stages
- ✅ GitHub Actions workflows
- ✅ Jenkins pipelines
- ✅ GitLab CI configuration
- ✅ Docker in CI/CD
- ✅ Secrets management
- ✅ Deployment strategies

### Next: Stack 30 - Logging Best Practices →

---

*End of Stack 29*