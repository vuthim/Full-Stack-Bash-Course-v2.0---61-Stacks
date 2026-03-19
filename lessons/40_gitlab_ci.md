# 🔄 STACK 40: GITLAB CI/CD
## Advanced Pipelines with GitLab

---

## 🔰 What is GitLab CI/CD?

GitLab CI/CD is a built-in continuous integration tool that comes with GitLab.

### Components
| Component | Purpose |
|-----------|---------|
| .gitlab-ci.yml | Pipeline definition |
| Runner | Executes jobs |
| Artifacts | Share between jobs |
| Cache | Speed up pipelines |

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

## ✅ Stack 40 Complete!

You learned:
- ✅ GitLab CI basics
- ✅ Jobs and stages
- ✅ Docker in CI
- ✅ Artifacts and cache
- ✅ Environment variables
- ✅ Environments

### Next: Stack 41 - Performance Tuning →

---

*End of Stack 40*