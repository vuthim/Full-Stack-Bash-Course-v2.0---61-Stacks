# 🔀 STACK 47: ADVANCED GIT WORKFLOWS
## Professional Git Techniques

---

## 🔰 Branching Strategies

### Git Flow
```bash
# Install git-flow
sudo apt install git-flow

# Initialize
git flow init

# Start feature
git flow feature start myfeature

# Finish feature
git flow feature finish myfeature

# Release
git flow release start 1.0.0
git flow release finish 1.0.0
```

### GitHub Flow
```bash
# Create branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "Add feature"

# Push
git push origin feature/my-feature

# Create pull request
# Review and test
# Merge to main
```

### Trunk-Based Development
```bash
# Work directly on main
git checkout main
# or for larger features
git checkout -b feature/tiny
# Keep branches short-lived (1-2 days)
```

---

## 🛠️ Advanced Commands

### Rebase
```bash
# Rebase onto main
git fetch origin
git rebase origin/main

# Interactive rebase (last 3 commits)
git rebase -i HEAD~3

# Fix commits:
# pick   = keep
# reword = change message
# edit   = stop to amend
# squash = combine with previous
# drop   = remove
```

### Cherry-Pick
```bash
# Apply specific commit
git cherry-pick abc123

# Cherry-pick without committing
git cherry-pick -n abc123
```

### Stash
```bash
# Save current work
git stash
git stash save "work in progress"

# List stashes
git stash list

# Apply and remove
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Create branch from stash
git stash branch new-feature stash@{0}
```

### Git Bisect (Debugging)
```bash
# Start bisect
git bisect start

# Mark current (broken)
git bisect bad

# Mark known good commit
git bisect good v1.0.0

# Test each commit automatically (in script)
git bisect run ./test_script.sh
```

---

## 🪝 Git Hooks

### Pre-commit Hook
```bash
# .git/hooks/pre-commit
#!/bin/bash

# Check bash scripts
shellcheck scripts/*.sh || exit 1

# Run tests
npm test || exit 1

# Prevent secret commits
if git diff --cached | grep -E "password|apikey|secret" >/dev/null 2>&1; then
    echo "Secrets detected!"
    exit 1
fi
```

### Pre-push Hook
```bash
# .git/hooks/pre-push
#!/bin/bash

# Run full test suite
npm run test:e2e || exit 1
```

### Commit-msg Hook
```bash
# .git/hooks/commit-msg
#!/bin/bash

COMMIT_MSG=$(cat "$1")
PATTERN="^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo "Invalid commit message format"
    echo "Format: type(scope): description"
    exit 1
fi
```

### Make Hooks Executable
```bash
chmod +x .git/hooks/pre-commit
```

---

## 🔒 Git Security

### Credential Storage
```bash
# Use SSH instead of HTTPS
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Cache credentials (15 minutes)
git config --global credential.helper cache
# Or store permanently
git config --global credential.helper store
```

### Signed Commits
```bash
# Generate GPG key
gpg --gen-key

# List keys
gpg --list-secret-keys --keyid-format=long

# Sign commits
git config --global user.signingkey KEY_ID
git commit -S -m "Signed commit"

# Sign tags
git tag -s v1.0.0 -m "Signed tag"
```

---

## 📋 Git Workflows

### Feature Branch Workflow
```bash
# Get latest
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/new-feature

# Work and commit
git add .
git commit -m "feat: add new feature"

# Keep updated
git fetch origin
git rebase origin/main

# Push
git push -u origin feature/new-feature
```

### Fork Workflow
```bash
# Fork repository on GitHub
# Clone your fork
git clone git@github.com:you/project.git

# Add upstream
git remote add upstream git@github.com:original/project.git

# Create feature branch
git checkout -b feature/my-feature

# Sync with upstream
git fetch upstream
git rebase upstream/main

# Push to your fork
git push origin feature/my-feature
```

---

## 🏆 Practice Exercises

### Exercise 1: Interactive Rebase
```bash
# Create commits
git commit --allow-empty -m "commit 1"
git commit --allow-empty -m "commit 2"
git commit --allow-empty -m "commit 3"

# Squish them
git rebase -i HEAD~3
# Change 2nd and 3rd to "squash"
```

### Exercise 2: Git Hooks
```bash
# Create pre-commit hook
mkdir -p .git/hooks

cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."
# Add your checks here
EOF
chmod +x .git/hooks/pre-commit
```

### Exercise 3: Git Bisect
```bash
# Find when bug was introduced
git bisect start
git bisect bad  # Current is broken
git bisect good v1.0.0  # Known good
# Test each step
git bisect good  # or bad
git bisect skip
git bisect reset  # End
```

---

## 📋 Git Commands Cheat Sheet

| Command | Description |
|---------|-------------|
| `git rebase` | Reapply commits on another branch |
| `git cherry-pick` | Apply specific commit |
| `git stash` | Temporarily save changes |
| `git bisect` | Binary search for bugs |
| `git reflog` | Show reference logs |

---

## ✅ Stack 47 Complete!

You learned:
- ✅ Branching strategies (Git Flow, GitHub Flow)
- ✅ Advanced Git commands (rebase, cherry-pick, bisect)
- ✅ Git hooks for automation
- ✅ Git security (GPG signing)
- ✅ Professional workflows
- ✅ Fork workflow

### Next: Stack 48 - Load Balancing →

---

*End of Stack 47*