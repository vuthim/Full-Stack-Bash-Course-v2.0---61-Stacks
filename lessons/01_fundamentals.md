# 🐚 STACK 1: BASH FUNDAMENTALS
## Your First Steps into the Shell World

---

## 🔰 What is Bash?

**Bash** = **B**ourne **A**gain **Sh**ell

- A command-line interpreter (shell) for Unix/Linux systems
- Reads and executes commands from text files (scripts)
- Powers macOS Terminal, Linux terminals, WSL, Git Bash

### Why Learn Bash?
✅ Automate repetitive tasks  
✅ System administration  
✅ DevOps & CI/CD pipelines  
✅ Remote server management  
✅ Become a powerful developer  

---

## 🎯 Terminal Basics

### Opening the Terminal
```bash
# Linux: Ctrl + Alt + T
# Mac: Cmd + Space → "Terminal"
# Windows: WSL or Git Bash
```

### Your First Commands

| Command | Description | Example |
|---------|-------------|---------|
| `echo` | Print text | `echo "Hello"` |
| `date` | Show current date/time | `date` |
| `whoami` | Current user | `whoami` |
| `which` | Find command location | `which ls` |
| `clear` | Clear screen | `clear` |

### Try It Now!

```bash
echo "Hello, Bash World!"
date
whoami
uname -a          # System information
```

---

## ⌨️ Command Structure

```
command [options] [arguments]

ls -l /home
│  │  │   │
│  │  │   └── argument (what to act on)
│  │  └────── option (how to act)
│  └───────── command (what to do)
```

### Common Options
- `-l` = long format
- `-a` = all files (including hidden)
- `-h` = human readable sizes
- `-r` = reverse order
- `-t` = sort by time

---

## 🔧 Essential Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + C` | Cancel current command |
| `Ctrl + L` | Clear screen |
| `Ctrl + A` | Move to beginning of line |
| `Ctrl + E` | Move to end of line |
| `Ctrl + U` | Clear before cursor |
| `Ctrl + K` | Clear after cursor |
| `Tab` | Auto-complete |
| `↑` / `↓` | Command history |

---

## 📝 Practice Exercise

### Part 1: Basic Commands
```bash
# Print your name
echo "My name is [Your Name]"

# Display calendar
cal

# Show logged in users
who
```

### Part 2: Explore Your System
```bash
# Find where you are
pwd

# List files in current directory
ls

# List with details
ls -lah

# Check system info
uname -a
```

---

## 🏆 Stack 1 Challenge

Create a script that displays:
1. A greeting with your name
2. Current date and time
3. Current working directory
4. Number of files in current directory

**Save as:** `hello_bash.sh`j

```bash
#!/bin/bash
# Your first Bash script!

echo "=============================="
echo "  Hello, Bash Master! 🐚"
echo "=============================="
echo ""
echo "📅 Date: $(date)"
echo "📁 Directory: $(pwd)"
echo "📂 Files: $(ls | wc -l)"
echo ""
echo "=============================="
```

Run it:
```bash
chmod +x hello_bash.sh
./hello_bash.sh
```

---

## ✅ Stack 1 Complete!

You learned:
- ✅ What is Bash and why it matters
- ✅ Basic terminal commands
- ✅ Command structure and options
- ✅ Keyboard shortcuts
- ✅ Created your first script!

### Next: Stack 2 → File & Directory Operations

---

*[Continue to Stack 2 when ready...]*