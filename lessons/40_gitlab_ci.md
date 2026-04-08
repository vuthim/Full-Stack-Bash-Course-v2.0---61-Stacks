# 🔄 STACK 40: GITLAB CI/CD
## Advanced Pipelines with GitLab

**What is GitLab CI/CD?** Think of it as a built-in automation robot for your GitLab projects. Every time you push code, it automatically builds, tests, and deploys - no manual intervention needed!

**Why GitLab CI/CD?** It's included with GitLab (no extra setup), uses simple YAML files, and integrates perfectly with your repositories.

---

## 🔰 What is GitLab CI/CD?

GitLab CI/CD is a built-in continuous integration tool that comes with GitLab.

### Components (Explained Simply)
| Component | What It Does | Analogy |
|-----------|--------------|---------|
| **.gitlab-ci.yml** | Pipeline definition (your automation recipe) | The instruction manual |
| **Runner** | Executes the jobs (the worker) | The factory worker following instructions |
| **Artifacts** | Files passed between jobs (build outputs) | Products moving down an assembly line |
| **Cache** | Speed up pipelines (reuse dependencies) | Keeping tools handy instead of fetching them each time |

### CI/CD Pipeline Flow
```
You push code → GitLab sees the .gitlab-ci.yml
              → Spins up a Runner
              → Executes stages in order:
                  Build → Test → Deploy
              → You get results (pass/fail) in minutes!
```

**Pro Tip:** Each stage runs in parallel (all jobs in "test" stage run together). Stages run sequentially (build must pass before test starts).

---

## ⚡ Basic GitLab CI

### .gitlab-ci.yml Structure
```yaml
stages:
  - build
  - test
  - deploy

variables:
  DOCKER_DRIVER: overlay2

build:
  stage: build
  script:
    - echo "Building..."
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

test:
  stage: test
  script:
    - echo "Testing..."
    - npm test
  dependencies:
    - build

deploy:
  stage: deploy
  script:
    - echo "Deploying..."
  only:
    - main
```

---

## 🔧 Jobs and Stages

### Multiple Jobs
```yaml
test:unit:
  stage: test
  script: npm run test:unit
  coverage: /Coverage: \d+\.\d+%/m

test:integration:
  stage: test
  script: npm run test:integration

test:e2e:
  stage: test
  script: npm run test:e2e
  when: manual
```

### Rules
```yaml
deploy:
  stage: deploy
  script: ./deploy.sh
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == "main"'
```

---

## 🐳 Docker in GitLab CI

### Docker Build
```yaml
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t myapp:$CI_COMMIT_SHA .
    - docker tag myapp:$CI_COMMIT_SHA myapp:latest
```

### Build and Push
```yaml
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

---

## 📦 Artifacts and Cache

### Artifacts
```yaml
build:
  stage: build
  script: npm ci && npm run build
  artifacts:
    paths:
      - build/
    expire_in: 1 week
    reports:
      junit: test-results.xml
```

### Cache
```yaml
build:
  stage: build
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
  script:
    - npm ci
```

---

## 🔐 Environment Variables

### Protected Variables
```yaml
deploy:
  stage: deploy
  script:
    - echo $SECRET_PASSWORD
  environment:
    name: production
    url: https://example.com
```

### Predefined Variables
```yaml
script:
  - echo $CI_COMMIT_SHA
  - echo $CI_COMMIT_BRANCH
  - echo $CI_PIPELINE_URL
  - echo $CI_REGISTRY_IMAGE
```

---

## 🌐 Environments

### Environment Config
```yaml
deploy_prod:
  stage: deploy
  script: ./deploy.sh production
  environment:
    name: production
    url: https://example.com
    on_stop: stop_prod

deploy_staging:
  stage: deploy
  script: ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com

stop_prod:
  stage: deploy
  script: ./stop.sh
  environment:
    name: production
    action: stop
  when: manual
```

---

## 🏗️ Advanced Patterns

### Docker Multi-stage Build
```dockerfile
FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Matrix Strategy
```yaml
test:
  stage: test
  script: npm test
  matrix:
    - NODE_VERSION: "14"
    - NODE_VERSION: "16"
    - NODE_VERSION: "18"
```

---

## 🏆 Practice Exercises

### Exercise 1: Create Basic Pipeline
```yaml
# .gitlab-ci.yml
image: node:18

stages:
  - build
  - test

build:
  stage: build
  script:
    - npm ci
    - npm run build

test:
  stage: test
  script:
    - npm test
```

### Exercise 2: Add Docker Build
```yaml
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t myapp .
```

### Exercise 3: Deploy to Environment
```yaml
deploy_staging:
  stage: deploy
  script: ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy_prod:
  stage: deploy
  script: ./deploy.sh prod
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
```

---

## 📋 GitLab CI Cheat Sheet

| Variable | Description |
|----------|-------------|
| `$CI_COMMIT_SHA` | Current commit |
| `$CI_BRANCH` | Current branch |
| `$CI_PIPELINE_URL` | Pipeline URL |
| `$CI_REGISTRY` | Docker registry |

---

## 🎓 Final Project: GitLab CI/CD Workflow Manager

Now that you've mastered the GitLab CI/CD syntax, let's see how a professional scripter might build a tool to manage their pipeline files. We'll examine the "GitLab CI Manager" — a utility that generates standard configuration files, validates them, and manages GitLab Runners automatically.

### What the GitLab CI/CD Workflow Manager Does:
1. **Generates Multi-Stage Workflows** automatically from standard templates.
2. **Handles Build Artifacts** by configuring paths and retention policies.
3. **Validates CI Files** using the `gitlab-runner` CLI to catch syntax errors.
4. **Applies Project Templates** (Docker, Node.js, Python) with specific build steps.
5. **Registers GitLab Runners** programmatically for automated scaling.
6. **Audits Configuration Files** across your local projects.

### Key Snippet: Template-Based Generation
Instead of writing YAML from scratch, the manager uses Bash to generate a robust, three-stage pipeline (Build, Test, Deploy) instantly.

```bash
cmd_create() {
    local ci_file=".gitlab-ci.yml"
    
    # Generate a complete GitLab pipeline file
    cat > "$ci_file" << EOF
stages:
  - build
  - test
  - deploy

build_job:
  stage: build
  script:
    - echo "Compiling your code..."
  artifacts:
    paths: [build/]

test_job:
  stage: test
  script:
    - echo "Running unit tests..."

deploy_job:
  stage: deploy
  script:
    - echo "Pushing to production!"
  only: [main]
EOF
    log "Standard GitLab CI pipeline generated successfully!"
}
```

### Key Snippet: Automated Runner Registration
Setting up a new build machine (Runner) is usually a long interactive process. The manager automates it using the `--non-interactive` flag.

```bash
cmd_runner_register() {
    log "Registering new GitLab runner..."
    
    # Register the runner without asking questions
    sudo gitlab-runner register --non-interactive \
        --url "https://gitlab.com/" \
        --registration-token "\$REG_TOKEN" \
        --executor "docker" \
        --docker-image "alpine:latest"
}
```

**Pro Tip:** Automating your CI/CD setup ensures that every project in your company follows the exact same quality and security standards!

---

## ✅ Stack 40 Complete!

Congratulations! You've successfully automated the entire lifecycle of your code within the GitLab ecosystem! You can now:
- ✅ **Understand GitLab CI/CD Architecture** (Stages, Jobs, Runners)
- ✅ **Write complex YAML configurations** for automated builds
- ✅ **Manage build artifacts** to pass data between pipeline stages
- ✅ **Optimize your pipelines** using caching and parallel jobs
- ✅ **Secure your environment** with protected variables and environments
- ✅ **Register and manage your own Runners** for high-speed builds

### What's Next?
In the next stack, we'll dive into **Performance Tuning**. You'll learn how to optimize your Linux system and your scripts to run at maximum efficiency!

**Next: Stack 41 - Performance Tuning →**

---

*End of Stack 40*
- **Previous:** [Stack 39 → System Hardening](39_system_hardening.md)
-- **Next:** [Stack 41 - Performance Tuning](41_performance_tuning.md)