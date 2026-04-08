# 🐚 STACK 1: BASH FUNDAMENTALS
## Your First Steps into the Shell World

---

## 🔰 What is Bash?

**Bash** (pronounced "bash") stands for **B**ourne **A**gain **Sh**ell. It's a program that lets you talk to your computer by typing commands instead of clicking with a mouse.

Think of Bash as a translator between you and your computer's operating system. When you type a command, Bash understands it and tells your computer what to do.

**Bash is everywhere:**
- Powers the Terminal app on Mac computers
- Runs in Linux terminals (Ubuntu, CentOS, etc.)
- Works in Windows through WSL (Windows Subsystem for Linux) or Git Bash
- Used by developers, system administrators, and DevOps engineers worldwide

### Why Learn Bash? (Simple Explanation)
Instead of clicking icons and menus, you type commands to make your computer work for you:
✅ **Save time** - Automate boring, repetitive tasks so your computer does them while you focus on important work
✅ **Gain control** - Manage your computer like a professional system administrator
✅ **Build career skills** - Essential for DevOps, cloud computing, and software development jobs
✅ **Work remotely** - Control servers anywhere in the world from your laptop
✅ **Join the developer community** - Most programmers use Bash daily as part of their workflow

---

## 🎯 Terminal Basics (Made Super Simple)

### Opening the Terminal (How to Get Started)
```bash
# Linux: Press Ctrl + Alt + T (all at once)
# Mac: Press Cmd + Space, type "Terminal", hit Enter
# Windows: Use WSL or Git Bash (install if needed)
```

### Your First 5 Commands (Try These Now!)

| Command | What It Does | Real-Life Example | Try It |
|---------|--------------|-------------------|---------|
| `echo` | Prints text to screen | Like saying something out loud | `echo "Hello"` |
| `date` | Shows current date/time | Like checking your watch | `date` |
| `whoami` | Shows your username | Like asking "Who am I?" | `whoami` |
| `which` | Finds where a command lives | Like finding where a tool is stored | `which ls` |
| `clear` | Clears the screen | Like wiping a whiteboard clean | `clear` |

### Try It Right Now! (Copy & Paste These)
```bash
echo "Hello, Bash World!"  # Say hello
date                       # What's the date/time?
whoami                     # What's your username?
uname -a                   # Computer system info (bonus!)
```

---

## ⌨️ Command Structure (How Commands Work)

Think of a command like a sentence in English:
```
VERB [ADVERBS] [OBJECTS]
command [options] [arguments] 

Example: ls -l /home
         │   │   │
         │   │   └── OBJECT: What to act on (/home directory)
         │   │      
         │   └────── ADVERB: How to act (-l = long/detailed format)
         │           
         └────────── VERB: What to do (ls = list files)
```

### Common Options (Like Adverbs - They Modify How Commands Work)
These work with many commands like ls, cp, rm, etc.:
- `-l` = long format (show details like size, date, permissions)
- `-a` = all files (including hidden ones that start with .)
- `-h` = human readable sizes (show 1K instead of 1024)
- `-r` = reverse order (show results backwards)
- `-t` = sort by time (newest first)

**Pro Tip**: You can combine them! `ls -lah` = list all files in long format with human sizes

---

## 🔧 Essential Keyboard Shortcuts (Your Time-Savers)

Think of these as cheat codes for typing faster:

| Shortcut | What It Does | When to Use It |
|----------|--------------|----------------|
| `Ctrl + C` | **STOP** - Cancel current command | When a command is stuck or taking too long |
| `Ctrl + L` | **CLEAR** - Wipe the screen clean | When the screen gets too cluttered |
| `Ctrl + A` | **HOME** - Jump to start of line | When you need to fix something at the beginning |
| `Ctrl + E` | **END** - Jump to end of line | When you need to fix something at the end |
| `Ctrl + U` | **ERASE LEFT** - Delete everything before cursor | When you typed too much and want to restart |
| `Ctrl + K` | **ERASE RIGHT** - Delete everything after cursor | When you want to keep the beginning but delete the end |
| `Tab` | **AUTO-COMPLETE** - Let Bash finish your typing | Type part of a command/folder name, then hit Tab |
| `↑` / `↓` | **HISTORY** - Scroll through past commands | Press ↑ to get your last command, ↓ to go forward |

**Pro Tips:**
- Hit `Tab` twice to see all possible completions
- Hold `Ctrl` and press the letter key (like `Ctrl+C`)
- These work in most command-line tools, not just Bash!

---

## 📝 Practice Exercise (Try These Now!)

Don't worry about making mistakes - that's how we learn!

### Part 1: Basic Commands (Do These One at a Time)
```bash
# Print your name (replace [Your Name] with your actual name)
echo "My name is [Your Name]"

# See today's date
date

# Show what day it is
date +"%A, %B %d, %Y"

# Check who you are logged in as
whoami

# See who else is on the system
who

# Look at a calendar
cal

# Look at this month's calendar with today highlighted
cal -3
```

### Part 2: Explore Your System (Try These)
```bash
# Find where you are right now (like a "You are here" sign)
pwd

# See what files/folders are in your current location
ls

# See more details (sizes, dates, permissions)
ls -l

# See ALL files including hidden ones (those starting with .)
ls -la

# See details in a nice, readable format
ls -lah

# Get detailed info about your computer
uname -a

# Just the operating system name
uname -o

# Just the kernel version
uname -r
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