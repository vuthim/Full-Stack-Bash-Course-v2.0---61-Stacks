# 📚 STACK 14: GIT FOR SCRIPTERS
## Version Control for Bash Scripts

---

## 🔰 Why Git for Scripts?

Git helps you:
- Track changes to your scripts
- Collaborate with others
- Maintain multiple versions
- Roll back mistakes
- Create backups

---

## 🔧 Basic Git Setup

```bash
# Install Git
sudo apt install git    # Debian/Ubuntu
sudo yum install git    # RedHat/CentOS

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Initialize repository
git init

# Check status
git status
```

---

## 📋 Essential Git Commands

```bash
# Clone repository
git clone https://github.com/user/repo.git

# Add files
git add script.sh
git add .              # Add all files

# Commit changes
git commit -m "Initial version"

# View history
git log
git log --oneline

# Check differences
git diff
git diff --staged

# Branches
git branch              # List branches
git branch feature-name # Create branch
git checkout feature    # Switch branch
git merge feature       # Merge branch
```

---

## 🌐 Working with Remotes

```bash
# Add remote
git remote add origin https://github.com/user/repo.git

# Push to remote
git push origin main

# Pull from remote
git pull origin main

# Fetch changes
git fetch origin
```

---

## 🔀 Gitignore for Scripts

```bash
# .gitignore
*.log
*.tmp
*.bak
.env
node_modules/
dist/
build/
secrets/
credentials/
```

---

## 🏆 Practice: Script Versioning

```bash
# Initialize
mkdir my_scripts && cd my_scripts
git init

# Create .gitignore
echo "*.log" > .gitignore
echo "*.bak" >> .gitignore
git add .gitignore
git commit -m "Add gitignore"

# Add first script
cat > backup.sh << 'EOF'
#!/bin/bash
echo "Backing up..."
tar -czf backup.tar.gz data/
EOF
git add backup.sh
git commit -m "Add backup script"

# Check history
git log --oneline
```

---

## ✅ Stack 14 Complete!