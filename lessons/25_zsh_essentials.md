# 🐚 STACK 25: ZSH ESSENTIALS [ELECTIVE]
## Z Shell - Power User's Shell

---

## 🔰 What is Zsh?

**Zsh** (Z Shell) is a powerful Unix shell that extends bash with many additional features. It's designed for interactive use and also powerful for scripting.

### Why Use Zsh?

| Feature | Bash | Zsh |
|---------|------|-----|
| Auto-complete | Basic | Advanced |
| Globbing | Limited | Powerful |
| Spell correction | ❌ | ✅ |
| Shared history | ❌ | ✅ |
| Plugin system | Limited | Oh My Zsh |
| Prompt customization | Basic | Powerful |

---

## ⚡ Installing Zsh

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install zsh
```

### Fedora/RHEL
```bash
sudo dnf install zsh
```

### macOS
```bash
# Zsh comes pre-installed on macOS
# To install latest version
brew install zsh
```

### Set Zsh as Default
```bash
# Change your default shell
chsh -s /bin/zsh

# Verify
echo $SHELL
```

---

## 🎨 Installing Oh My Zsh

Oh My Zsh is a framework for managing your Zsh configuration.

### Installation
```bash
# Via curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Via wget
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

### Update Oh My Zsh
```bash
# Update Oh My Zsh
upgrade_oh_my_zsh

# Or manually
cd ~/.oh-my-zsh
git pull
```

---

## 🔧 Zsh Configuration

### ~/.zshrc Basics
```bash
# Set editor
export EDITOR=vim

# Aliases
alias ll='ls -la'
alias la='ls -a'
alias grep='grep --color=auto'

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Enable correction
setopt CORRECT
setopt CORRECT_ALL
```

### Theme Configuration
```bash
# Set theme (in ~/.zshrc)
ZSH_THEME="robbyrussell"

# Popular themes
# robbyrussell, agnoster, powerlevel10k, starship
```

---

## 🎯 Zsh Features

### 1. Globbing

```zsh
# List files modified in the last day
ls **/*(mod-1)

# List files smaller than 10K
ls **/*(L-10)

# List directories only
ls *(/)

# List executable files only
ls *(x)

# List files by modification time (newest first)
ls *(om)

# List files by size (largest first)
ls *(OL)
```

### 2. Extended Globbing
```zsh
# Exclude pattern
ls ^*.txt  # All files except .txt

# OR patterns
ls *(txt|pdf|doc)

# Conditional globbing
ls *(.)
```

### 3. Auto-completion

```zsh
# Tab completion for commands
# Just type command and press Tab

# Kill process completion
kill -9 <Tab>

# Git completion
git checkout <Tab>
git branch -d <Tab>

# SSH completion
ssh <Tab>
scp file.txt <Tab>
```

### 4. Directory Navigation

```zsh
# Auto-cd (no need to type cd)
/home/user

# Directory stack
pushd /tmp
popd
dirs -v

# .. (parent), ... (grandparent), .... (great-grandparent)
cd ....
```

### 5. History Search

```zsh
# Reverse search
Ctrl+R

# Forward search
Ctrl+S

# Execute previous command
!!

# Execute last command matching pattern
!?grep
```

---

## 🔌 Useful Zsh Plugins

### Installing Plugins
```bash
# Edit ~/.zshrc
plugins=(
    git
    docker
    kubectl
    zsh-autosuggestions
    zsh-syntax-highlighting
)
```

### Popular Plugins

| Plugin | Purpose |
|--------|---------|
| zsh-autosuggestions | Suggests commands as you type |
| zsh-syntax-highlighting | Highlights valid commands |
| git | Git aliases and functions |
| docker | Docker completion |
| kubectl | Kubernetes completion |
| fzf | Fuzzy finder |

### Install zsh-autosuggestions
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### Install zsh-syntax-highlighting
```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

---

## 📝 Zsh vs Bash Scripts

### Key Differences

```bash
#!/bin/zsh
# Note: Use #!/bin/zsh for Zsh scripts

# Arrays (both work, but Zsh is 1-indexed by default)
array=(one two three)
echo "${array[1]}"  # Zsh: one
echo "${array[0]}"  # Bash: one

# For loops
for i in {1..5}; do
    echo "Number: $i"
done

# Associative arrays (Zsh)
declare -A scores
scores[alice]=95
scores[bob]=87
echo "${scores[alice]}"
```

### Portability
```bash
#!/usr/bin/env bash
# Use bash for portable scripts
# Zsh-specific features won't work in bash
```

---

## 🎨 Customizing Your Prompt

### Basic Prompt
```bash
# In ~/.zshrc
PROMPT='%F{green}%n%f@%F{blue}%m%f:%F{yellow}%~%f$ '
```

### Powerlevel10k Theme
```bash
# Install
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Set in ~/.zshrc
ZSH_THEME="powerlevel10k/powerlevel10k"
```

---

## ⚡ Zsh Shortcuts

### Movement
| Shortcut | Action |
|----------|--------|
| Ctrl+A | Move to beginning of line |
| Ctrl+E | Move to end of line |
| Alt+B | Move back one word |
| Alt+F | Move forward one word |

### Editing
| Shortcut | Action |
|----------|--------|
| Ctrl+U | Clear line before cursor |
| Ctrl+K | Clear line after cursor |
| Ctrl+W | Delete word before cursor |
| Alt+D | Delete word after cursor |

### History
| Shortcut | Action |
|----------|--------|
| Ctrl+R | Search history backward |
| Ctrl+S | Search history forward |
| Ctrl+P | Previous command |
| Ctrl+N | Next command |

---

## 🏆 Practice Exercises

### Exercise 1: Install and Configure Zsh
```bash
# 1. Install Zsh
sudo apt install zsh

# 2. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. Add some aliases to ~/.zshrc
echo "alias ll='ls -la'" >> ~/.zshrc
echo "alias gs='git status'" >> ~/.zshrc

# 4. Reload config
source ~/.zshrc
```

### Exercise 2: Try Globbing
```zsh
# Create test files
mkdir -p test_dir
touch test_dir/file{1..10}.txt
touch test_dir/document{1..5}.pdf

# List only .txt files
ls test_dir/*.txt

# List files modified today (requires touching)
touch test_dir/new.txt
ls test_dir/*(mod-0)

# List only directories
mkdir test_dir/subdir
ls test_dir/*(/)
```

### Exercise 3: Configure Plugins
```bash
# Clone plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Edit ~/.zshrc
nano ~/.zshrc
# Change: plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Reload
source ~/.zshrc
```

---

## 📋 Zsh Cheat Sheet

| Command | Description |
|---------|-------------|
| `setopt` | Show all options |
| `alias` | List all aliases |
| `history` | Show command history |
| `dirstack` | Show directory stack |
| `fc` | Fix command (history editor) |

### Useful Options
```bash
# Auto-correction
setopt CORRECT
setopt CORRECT_ALL

# Directory handling
setopt AUTO_CD
setopt PUSHD_IGNORE_DUPS

# History
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Globbing
setopt GLOB_STAR_SHORT
setopt EXTENDED_GLOB
```

---

## ✅ Stack 25 Complete!

You learned:
- ✅ What is Zsh and why use it
- ✅ Installing Zsh and Oh My Zsh
- ✅ Configuration and customization
- ✅ Zsh features (globbing, completion, history)
- ✅ Using plugins
- ✅ Zsh vs Bash scripting

### Next: Stack 26 - Vim for Scripters →

---

## 📝 Challenge: Build Your Zsh Setup

Create a comprehensive ~/.zshrc that includes:
1. Useful aliases for common tasks
2. Custom prompt with git status
3. Useful plugins installed
4. Custom functions for frequently used operations

---

*End of Stack 25*