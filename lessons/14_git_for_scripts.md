# 📚 STACK 14: GIT FOR SCRIPTERS
## Version Control for Bash Scripts

Think of Git as a time machine for your code - it saves snapshots every time you commit, so you can always go back if something breaks.

---

## 🔰 Why Git for Scripts?

Git is essential for any scripter:
- ✅ **Track changes** - Every modification is recorded (who changed what and when)
- ✅ **Collaborate** - Work with team members without overwriting each other's work
- ✅ **Version control** - Maintain multiple versions (dev, production, etc.)
- ✅ **Rollback** - Revert to previous versions when something breaks
- ✅ **Backup** - Your code is safely stored remotely (GitHub, GitLab, etc.)
- ✅ **Branching** - Experiment without breaking your main code

**Real-World Example:** Imagine you write a backup script that works perfectly. You tweak it, but now it's broken. With Git, you can instantly go back to the working version!

---

## ⚙️ Git Installation & Setup

### Install Git
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install git

# CentOS/RHEL
sudo yum install git
sudo dnf install git

# macOS
brew install git

# Windows
# Download from https://git-scm.com
```

### Basic Configuration (Do This First!)
Set your identity - this is like signing your name on every change.

```bash
# Set your identity (appears in commit history)
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Set default branch name (modern standard is 'main')
git config --global init.defaultBranch main

# Set default editor (for writing commit messages)
git config --global core.editor vim
git config --global core.editor "nano"              # Beginner-friendly
git config --global core.editor "code --wait"       # VS Code

# Enable helpful features
git config --global pull.rebase false               # Use merge by default
git config --global merge.conflictstyle diff3       # Better conflict display
git config --global color.ui auto                   # Colorful output

# List all settings
git config --list --show-origin
```

**Pro Tip:** Use `--global` to apply these settings to all your projects. Without `--global`, it only applies to the current project.

### Repository Setup (Starting Fresh)
```bash
# Initialize new repository in current folder
git init

# Clone existing repository (copy from remote)
git clone https://github.com/user/repo.git
git clone https://github.com/user/repo.git my-folder  # Custom folder name

# Shallow clone (faster, downloads only latest - great for large repos)
git clone --depth 1 https://github.com/user/repo.git
```

---

## 📋 Essential Git Commands

### Status & Information
```bash
# Check repository status
git status

# Brief status
git status -sb

# Show working tree status
git status --short

# Show branches
git branch
git branch -a  # including remote
git branch -v  # with last commit

# Show commit history
git log
git log --oneline
git log --oneline -10  # last 10
git log --graph --oneline --all  # visual

# Show differences
git diff              # unstaged changes
git diff --staged     # staged changes
git diff HEAD~1       # vs previous commit
git diff main..feature  # between branches
```

### Adding & Committing
```bash
# Add specific file
git add script.sh

# Add all files
git add .
git add -A

# Add by pattern
git add *.sh
git add logs/

# Interactive add
git add -i
git add -p  # patch mode (select specific changes)

# Commit changes
git commit -m "Message here"
git commit -m "Title" -m "Description"

# Amend last commit
git commit --amend
git commit --amend -m "New message"

# Commit in one step
git commit -am "Message"  # only for tracked files!
```

### Undoing Changes
```bash
# Discard unstaged changes
git checkout -- file.sh
git restore file.sh  # newer syntax

# Unstage file
git reset HEAD file.sh
git restore --staged file.sh  # newer syntax

# Revert commit (creates new commit)
git revert abc1234

# Reset to previous commit (DANGEROUS)
git reset --soft HEAD~1  # keep changes staged
git reset --mixed HEAD~1  # keep changes unstaged (default)
git reset --hard HEAD~1  # DISCARD all changes!
```

---

## 🌐 Working with Remotes

### Remote Basics
```bash
# List remotes
git remote -v

# Add remote
git remote add origin https://github.com/user/repo.git

# Rename remote
git remote rename origin upstream

# Remove remote
git remote remove origin

# Change remote URL
git remote set-url origin https://github.com/user/new-repo.git
```

### Push & Pull
```bash
# Push to remote
git push origin main
git push -u origin main  # set upstream
git push -f origin main  # force push (be careful!)

# Push all branches
git push --all origin

# Pull from remote
git pull origin main
git pull --rebase origin main  # rebase instead of merge

# Fetch without merging
git fetch origin
git fetch --all
```

### Collaboration Workflow
```bash
# Keep your fork updated
git fetch upstream
git merge upstream/main

# Or use rebase
git fetch upstream
git rebase upstream/main
```

---

## 🌿 Branching Strategies

### Basic Branching
```bash
# Create branch
git branch feature-name
git checkout -b feature-name  # create and switch

# Switch branches
git checkout main
git switch main  # newer syntax
git switch -c feature-name  # create and switch

# Delete branch
git branch -d feature-name  # safe delete
git branch -D feature-name  # force delete

# Merge branch
git checkout main
git merge feature-name
git merge --no-ff feature-name  # preserve branch history
```

### Git Flow (Recommended)
```
main (production)
  ↑
develop (integration)
  ↑
feature/* (new features)
  ↑
hotfix/* (urgent fixes)
  ↑
release/* (releases)
```

### Practical Branching
```bash
# Start new feature
git checkout -b feature/add-backup-script develop

# Work on feature
git add backup.sh
git commit -m "Add backup script"

# Update from develop
git fetch origin
git merge origin/develop

# Push feature
git push -u origin feature/add-backup-script

# Create PR, get reviews, merge

# Clean up
git checkout develop
git pull
git branch -d feature/add-backup-script
```

---

## 🔀 Gitignore for Scripts

### Essential .gitignore
```bash
# Logs and temporary files
*.log
*.tmp
*.temp
*.swp
*.swo
*~

# Backup files
*.bak
*.backup
*.old

# Secrets and credentials
.env
.env.local
*.pem
*.key
credentials/
secrets/
keys/
id_rsa*

# Build outputs
dist/
build/
out/
target/

# Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.sublime-*

# Execution scripts (keep source, ignore compiled/output)
output/
results/
*.zip
*.tar.gz
!keep/
```

### Track Empty Directories
```bash
# Add .gitkeep to keep directories
touch output/.gitkeep
touch logs/.gitkeep

# In .gitignore, add:
# But keep these
!*/.gitkeep
```

---

## 🔧 Advanced Git for Scripters

### Stashing Changes
```bash
# Save changes temporarily
git stash
git stash push -m "WIP: working on feature"

# List stashes
git stash list

# Apply most recent stash
git stash pop

# Apply specific stash
git stash apply stash@{0}

# Drop stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

### Cherry-Picking
```bash
# Apply specific commit to current branch
git cherry-pick abc1234

# Cherry-pick without committing
git cherry-pick -n abc1234
```

### Tagging Releases
```bash
# Create lightweight tag
git tag v1.0.0

# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tags
git push origin v1.0.0
git push --tags

# Checkout tag
git checkout v1.0.0
```

### Submodules (Advanced)
```bash
# Add submodule
git submodule add https://github.com/user/repo.git lib/repo

# Clone with submodules
git clone --recurse-submodules https://github.com/user/repo.git

# Update submodules
git submodule update --init --recursive
```

---

## 📝 Script Versioning Workflow

### Professional Workflow
```bash
#!/bin/bash
# script_workflow.sh

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Check git is available
command -v git >/dev/null || { error "Git not installed"; exit 1; }

# Check we're in a repo
git rev-parse --git-dir >/dev/null 2>&1 || { error "Not a git repository"; exit 1; }

# Pull latest changes
log "Pulling latest changes..."
git pull origin main || error "Pull failed, continuing..."

# Run your script
log "Running script..."
./my_script.sh

# Add, commit, push
log "Committing changes..."
git add -A
git diff --staged --quiet && { log "No changes to commit"; exit 0; }

git commit -m "Update: $(date '+%Y-%m-%d %H:%M')"
git push origin main && log "Changes pushed!" || error "Push failed"
```

### Automated Versioning
```bash
#!/bin/bash
# version.sh - Auto-increment version

VERSION_FILE="version.txt"

# Read current version
if [ -f "$VERSION_FILE" ]; then
    CURRENT=$(cat "$VERSION_FILE")
    MAJOR=$(echo "$CURRENT" | cut -d. -f1)
    MINOR=$(echo "$CURRENT" | cut -d. -f2)
    PATCH=$(echo "$CURRENT" | cut -d. -f3)
    
    # Increment patch
    PATCH=$((PATCH + 1))
    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
else
    NEW_VERSION="1.0.0"
fi

echo "$NEW_VERSION" > "$VERSION_FILE"
echo "Version: $NEW_VERSION"

# Tag the release
git add "$VERSION_FILE"
git commit -m "Bump version to $NEW_VERSION"
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"
git push origin main --tags
```

---

## 🏆 Practice: Complete Workflow

### Step 1: Initialize
```bash
mkdir my_scripts && cd my_scripts
git init
git config user.name "Your Name"
git config user.email "you@email.com"

# Create .gitignore
cat > .gitignore << 'EOF'
*.log
*.tmp
.env
*.bak
EOF
git add .gitignore
git commit -m "Add .gitignore"
```

### Step 2: Create First Script
```bash
cat > backup.sh << 'EOF'
#!/bin/bash
# Simple backup script

set -euo pipefail

BACKUP_DIR="/tmp/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup home directory
tar -czf "$BACKUP_DIR/home_$DATE.tar.gz" "$HOME" || true

echo "Backup created: $BACKUP_DIR/home_$DATE.tar.gz"

# Keep only last 7 backups
find "$BACKUP_DIR" -name "home_*.tar.gz" -mtime +7 -delete
EOF

chmod +x backup.sh
git add backup.sh
git commit -m "Add backup script"
```

### Step 3: Add Remote & Push
```bash
# Create repo on GitHub, then:
git remote add origin https://github.com/yourusername/my_scripts.git
git push -u origin main
```

### Step 4: Make Changes
```bash
# Edit backup.sh to add more features
git add backup.sh
git commit -m "Add error handling"

# View history
git log --oneline

# Push changes
git push origin main
```

### Step 5: Create Feature Branch
```bash
git checkout -b feature/add-restore

# Add restore functionality
cat > restore.sh << 'EOF'
#!/bin/bash
# Restore from backup

set -euo pipefail

BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

tar -xzf "$BACKUP_FILE" -C /
echo "Restored from $BACKUP_FILE"
EOF

git add restore.sh
git commit -m "Add restore script"

git checkout main
git merge --no-ff feature/add-restore
git push origin main
```

---

## 🔍 Troubleshooting

### Common Issues

#### "detached HEAD"
```bash
# You're in detached HEAD state
# Either:
git checkout main           # go back to branch
git checkout -b new-branch  # create new branch
```

#### Merge Conflicts
```bash
# Open conflicted file
# Look for <<<<<<< ======= >>>>>>>
# Manually resolve
git add resolved_file.sh
git commit
```

#### Accidental Commit to Wrong Branch
```bash
# Move commit to correct branch
git branch feature-branch
git reset --hard HEAD~1   # go back in main
git checkout feature-branch
```

#### Large Files Added
```bash
# Remove from history (careful!)
git filter-branch --force --tree-filter 'rm -f large-file.zip' --tag-name-filter cat -- --all
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

---

## 📋 Git Commands Quick Reference

| Task | Command |
|------|---------|
| Initialize | `git init` |
| Clone | `git clone url` |
| Status | `git status` |
| Add | `git add file` |
| Commit | `git commit -m "msg"` |
| Push | `git push` |
| Pull | `git pull` |
| Branch | `git branch name` |
| Switch | `git checkout name` |
| Merge | `git merge name` |
| Log | `git log --oneline` |
| Diff | `git diff` |
| Stash | `git stash` |
| Tag | `git tag v1.0.0` |

---

## ✅ Stack 14 Complete!

You learned:
- ✅ Git installation and configuration
- ✅ Essential Git commands
- ✅ Working with remotes
- ✅ Branching strategies
- ✅ .gitignore best practices
- ✅ Advanced Git (stash, cherry-pick, tags)
- ✅ Script versioning workflow
- ✅ Automated versioning
- ✅ Complete practice workflow
- ✅ Troubleshooting common issues

### Next: Stack 15 - Docker & Bash →

---

*End of Stack 14*
