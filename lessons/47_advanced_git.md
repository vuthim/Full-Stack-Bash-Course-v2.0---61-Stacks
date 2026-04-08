# 🔀 STACK 47: ADVANCED GIT WORKFLOWS
## Professional Git Techniques

**Building on Stack 14:** You know Git basics (add, commit, push, branch). Now let's level up to professional workflows that teams actually use in production.

**Why Level Up?** Basic Git works fine for solo projects. But when you work with a team, handle releases, or manage complex features, basic Git leads to messy histories, broken merges, and "who broke main?!" moments. Advanced workflows keep teams organized and histories clean.

### Advanced Git Analogy
```
Basic Git:    Like driving a car with automatic transmission (gets you there)
Advanced Git: Like knowing how to parallel park, merge on highways, and navigate in snow
              (same car, but you can handle ANY situation!)
```

---

## 🔰 Branching Strategies (Professional Level)

### Git Flow (The Classic Enterprise Strategy)
**When to use it:** Large teams, release-driven development, complex features.

```bash
# Install git-flow
sudo apt install git-flow

# Initialize (creates the standard branch structure)
git flow init

# Start a new feature (creates feature/myfeature from develop)
git flow feature start myfeature

# Finish feature (merges back to develop)
git flow feature finish myfeature

# Start a release (freeze new features, only bug fixes)
git flow release start 1.0.0

# Finish release (merge to main AND develop, tag it)
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

## 🎓 Final Project: The Git Power User Tool

Now that you've explored the depths of Git, let's see how a professional software engineer might automate their advanced workflows. We'll examine the "Git Power User Tool" — a script that simplifies complex operations like rebasing, cherry-picking, and bug hunting with `bisect`.

### What the Git Power User Tool Does:
1. **Automates Rebasing** onto the main branch to keep your feature branches clean.
2. **Simplifies Cherry-Picking** by allowing you to pull specific commits with one command.
3. **Streamlines Bug Hunting** using `git bisect` to find exactly where a bug was introduced.
4. **Performs Repository Cleanup** by pruning old remote references and deleted branches.
5. **Generates Visual History Graphs** to help you understand complex branching.
6. **Audits Contributions** to show who has been working on what across the project.

### Key Snippet: Bug Hunting with Bisect
`git bisect` is like a "detective" tool that uses binary search to find a bug. The manager makes starting this process easier.

```bash
cmd_bisect_start() {
    local bad_commit=${1:-HEAD}
    echo "Starting search for the bug..."
    
    # 1. Start the bisect process
    git bisect start
    
    # 2. Mark the current version as BAD (it has the bug)
    git bisect bad "$bad_commit"
    
    log "Now find a commit that was GOOD and run: git bisect good <hash>"
}
```

### Key Snippet: Automated Branch Cleanup
Over time, a repo gets cluttered with branches that have already been merged. The manager cleans them up automatically.

```bash
cmd_cleanup_branches() {
    # Find branches that have already been merged into 'main'
    # grep -v 'main' ensures we don't accidentally delete the main branch!
    local merged=$(git branch --merged main | grep -v 'main')
    
    if [ -n "$merged" ]; then
        echo "Deleting merged branches: $merged"
        echo "$merged" | xargs git branch -d
        log "Local repository cleaned up successfully."
    else
        log "No merged branches found. Everything is already clean!"
    fi
}
```

**Pro Tip:** Automation tools like this turn "scary" Git commands into safe, repeatable workflows that save you hours of manual fixing!

---

## ✅ Stack 47 Complete!

Congratulations! You've successfully mastered the "Time Machine" of the software world! You can now:
- ✅ **Architect complex branching strategies** (Git Flow, GitHub Flow)
- ✅ **Rewriting history safely** using `git rebase`
- ✅ **Hunt down bugs** using advanced binary search with `git bisect`
- ✅ **Pick and choose specific changes** with `git cherry-pick`
- ✅ **Secure your code** using GPG signing and protected branches
- ✅ **Automate your Git workflow** using custom power-user scripts

### What's Next?
In the next stack, we'll dive into **Load Balancing**. You'll learn how to distribute network traffic across multiple servers to ensure your applications stay fast and reliable even under heavy load!

**Next: Stack 48 - Load Balancing →**

---

*End of Stack 47*
- **Previous:** [Stack 46 → Career & Production](46_career_production.md)   
-- **Next:** [Stack 48 - Load Balancing](48_load_balancing.md)