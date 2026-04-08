# 🐚 STACK 25: ZSH ESSENTIALS [ELECTIVE]
## Z Shell - Power User's Shell

---

## 🔰 What is Zsh?

> **Think of it this way:** If Bash is a reliable pickup truck that gets the job done, Zsh is that same truck with a turbo engine, GPS navigation, and a built-in coffee maker. It does everything Bash does — just with more comfort and convenience.

**Zsh** (Z Shell) is a powerful Unix shell that extends bash with many additional features. It's designed for interactive use and also powerful for scripting. If you already know Bash, you already know about 90% of Zsh — the remaining 10% is where all the magic happens.

### Analogy: Bash vs Zsh

| Aspect | Bash | Zsh |
|--------|------|-----|
| **Role** | The default shell on most Linux systems | The default shell on macOS (since Catalina) |
| **Compatibility** | POSIX standard | Mostly compatible with Bash |
| **Interactive use** | Good | Excellent |
| **Scripting** | Great | Good (but Bash is more portable) |
| **Out-of-the-box feel** | Functional | Polished |

### Why Use Zsh?

| Feature | Bash | Zsh |
|---------|------|-----|
| Auto-complete | Basic | Advanced |
| Globbing | Limited | Powerful |
| Spell correction | ❌ | ✅ |
| Shared history | ❌ | ✅ |
| Plugin system | Limited | Oh My Zsh |
| Prompt customization | Basic | Powerful |

> **Pro Tip:** You don't have to "switch" to use Zsh. You can install it, experiment with it, and keep Bash as your default until you're comfortable. Zsh and Bash can coexist peacefully!

### ⚠️ Common Zsh Mistakes (Avoid These!)

1. **Assuming 100% Bash Compatibility**
   ```bash
   # ❌ This Bash-ism might behave differently in Zsh
   echo ${array[@]}    # Bash: works
   echo ${array[@]}    # Zsh: might need different syntax

   # ✅ Fix: Test scripts in Zsh before relying on them
   # Or use #!/bin/bash shebang for Bash-specific scripts
   ```

2. **Forgetting PATH Changes**
   ```bash
   # After switching, your .bashrc aliases/functions won't auto-load
   # ✅ Fix: Copy important configs to ~/.zshrc
   ```

3. **Plugin Overload**
   ```bash
   # ❌ Don't enable 50 plugins - it slows down startup
   plugins=(git docker npm python node yarn aws kubectl...)

   # ✅ Only enable what you actually use daily
   plugins=(git docker npm)
   ```

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
# Zsh comes pre-installed on macOS (since Catalina 10.15)
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

> **Pro Tip:** After running `chsh`, you need to **log out and log back in** (or restart your terminal) for the change to take effect. Just opening a new tab won't always work!

---

## 🎨 Installing Oh My Zsh

### What is Oh My Zsh? (Explained Simply)

> **Think of Oh My Zsh as an "app store + theme shop" for your terminal.**
>
> Zsh on its own is great, but configuring it means editing text files and remembering arcane settings. **Oh My Zsh** is a community-driven framework that wraps Zsh and gives you:
> - **Themes**: One-line prompt changes (from simple to fancy with git status, timestamps, etc.)
> - **Plugins**: Pre-built shortcuts and completions for tools you already use (git, docker, npm, python, etc.)
> - **Sensible defaults**: Good settings out of the box without reading a manual
>
> You **don't need** Oh My Zsh to use Zsh, but it's the fastest way to get a polished setup. Think of it this way:
> - **Zsh** = the engine
> - **Oh My Zsh** = the dashboard, leather seats, and infotainment system

### Installation
```bash
# Via curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Via wget
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

> **Pro Tip:** The install script will ask to change your default shell to Zsh. Say **yes** if you want Zsh every time you open a terminal. You can always switch back to Bash later with `chsh -s /bin/bash`.

### What Happens After Installation?

Oh My Zsh creates a `~/.oh-my-zsh/` directory with all its files and generates a new `~/.zshrc` configuration file. Your terminal will immediately look different — that's the default theme kicking in!

### Update Oh My Zsh
```bash
# Update Oh My Zsh
upgrade_oh_my_zsh

# Or manually
cd ~/.oh-my-zsh
git pull
```

> **Pro Tip:** Oh My Zsh updates automatically every week by default. You'll see a message like "Would you like to check for updates?" when you open a new terminal. You can safely say yes!

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

### What Are Plugins? (Simple Explanation)

> Plugins are like **browser extensions for your terminal**. They add superpowers to commands you already use.
>
> - The **git** plugin lets you type `g status` instead of `git status` and `gco main` instead of `git checkout main`
> - The **docker** plugin auto-completes container names when you press Tab
> - **zsh-autosuggestions** shows greyed-out text suggesting what you might want to type (based on your history)
> - **zsh-syntax-highlighting** turns your text green when the command is valid and red when it's wrong — like a spell-checker for your terminal

### Installing Plugins
```bash
# Edit ~/.zshrc and add plugins to this line:
plugins=(
    git
    docker
    kubectl
    zsh-autosuggestions
    zsh-syntax-highlighting
)
```

> **Pro Tip:** Don't go overboard with plugins! Start with just `git` and one or two others. Each plugin slightly slows down your terminal startup. If your terminal takes more than 1 second to open, you probably have too many plugins.

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

> **Pro Tip:** After adding a new plugin to the `plugins=()` line in `~/.zshrc`, always run `source ~/.zshrc` to reload your config. Otherwise you'll need to close and reopen your terminal.

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

## 🎓 Final Project: Zsh Configuration Manager

Now that you've mastered Zsh essentials, let's see how a professional scripter might automate their shell setup. We'll examine the "Zsh Manager" — a tool that installs Oh My Zsh, manages plugins and themes, and handles custom aliases automatically.

### What the Zsh Configuration Manager Does:
1. **Installs Oh My Zsh** and common plugins with a single command.
2. **Manages Themes** by programmatically editing the `.zshrc` file.
3. **Adds and Removes Plugins** without needing to manual text editing.
4. **Manages Custom Aliases** by appending them to the configuration file.
5. **Provides an Interactive CLI** to configure your shell on any new machine.
6. **Validates Current Setup** to ensure all required directories exist.

### Key Snippet: Installing Oh My Zsh Programmatically
A good manager script can install Oh My Zsh in "unattended" mode, which means it won't prompt the user or change the shell automatically until it's ready.

```bash
cmd_install() {
    # -fsSL: Fail silently, show errors, follow redirects
    # --unattended: Don't ask questions or switch to zsh immediately
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}
```

### Key Snippet: Modifying the .zshrc with Sed
The manager uses `sed` to search for and replace specific lines in your configuration file.

```bash
cmd_theme() {
    local theme=$1
    # Find the line starting with ZSH_THEME= and replace the whole line
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"$theme\"/" "$HOME/.zshrc"
    log "Theme set to: $theme"
}
```

**Pro Tip:** Automating your shell configuration means you can set up a brand new computer with all your favorite tools, aliases, and themes in seconds!

---

## ✅ Stack 25 Complete!

Congratulations! You've successfully "turbocharged" your terminal experience! You can now:
- ✅ **Understand the power of Zsh** and how it extends Bash
- ✅ **Install and configure Oh My Zsh** for a better workflow
- ✅ **Use advanced plugins** like autosuggestions and syntax highlighting
- ✅ **Customize your prompt** with themes and git status indicators
- ✅ **Master advanced globbing** and history features
- ✅ **Automate your shell setup** using Zsh-aware scripts

### What's Next?
In the next stack, we'll dive into **Vim for Scripters**. You'll learn how to edit your scripts at lightning speed using the world's most powerful text editor!

**Next: Stack 26 - Vim for Scripters →**

---

*End of Stack 25*

- **Previous:** [Stack 24 → Advanced Scheduling](24_scheduling_advanced.md)
- **Next:** [Stack 26 - Vim for Scripters](26_vim_editor.md)