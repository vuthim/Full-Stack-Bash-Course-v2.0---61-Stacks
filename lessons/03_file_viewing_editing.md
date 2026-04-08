# 📝 STACK 3: FILE VIEWING, EDITING & SAFE HANDLING
## Looking at and Changing Files Safely

---

## Part A: Looking at Files and Using Text Editors

---

## 🔍 Advanced Ways to Look at Files

### cat - More Than Just Displaying Files
```bash
cat file.txt                    # Display file
cat -n file.txt                 # Number all lines
cat -b file.txt                 # Number non-empty lines
cat -s file.txt                 # Squeeze multiple blank lines
cat -T file.txt                 # Show tabs as ^I
cat -A file.txt                 # Show all characters

# Create file from keyboard
cat > newfile.txt
Hello World
[Ctrl+D to save]

# Append to file
cat >> existing.txt
More content
[Ctrl+D]

# Combine files
cat file1.txt file2.txt > combined.txt
```

---

### less - The Powerful Pager

`less` is essential for viewing large files efficiently.

```bash
less largefile.log
less -N largefile.log          # Show line numbers
less -X largefile.log          # Keep content on exit
less -S largefile.log          # Don't wrap long lines
```

#### less Navigation Keys

| Key | Action |
|-----|--------|
| `Space` / `PageDown` | Next page |
| `b` / `PageUp` | Previous page |
| `↓` / `j` | Next line |
| `↑` / `k` | Previous line |
| `g` | First line |
| `G` | Last line |
| `ng` | Go to line n |
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next search result |
| `N` | Previous search result |
| `v` | Open in vim |
| `h` | Help |
| `q` | Quit |

---

### head & tail - Selective Viewing

```bash
# Head - First N lines
head file.txt                  # Default 10 lines
head -n 20 file.txt            # First 20 lines
head -c 100 file.txt           # First 100 bytes

# Tail - Last N lines
tail file.txt                  # Last 10 lines
tail -n 25 file.txt            # Last 25 lines
tail -f file.txt               # Follow file (live)
tail -f -n 100 file.txt        # Last 100 lines, follow

# Multiple files
head -n 5 file1.txt file2.txt
```

#### Practical tail -f Examples
```bash
# Monitor log files
tail -f /var/log/syslog        # Linux system log
tail -f /var/log/auth.log      # Authentication log
tail -f /var/log/nginx/access.log

# On macOS
tail -f /var/log/system.log
tail -f /var/log/appstore.log
```

---

## ✏️ Text Editors

### nano - The Beginner-Friendly Editor

```bash
nano filename.txt              # Open/create file
nano -m filename.txt          # Enable mouse support
nano -c filename.txt          # Show cursor position
nano +100 filename.txt        # Open at line 100
```

#### nano Key Bindings

| Shortcut | Action |
|----------|--------|
| `Ctrl + O` | Save (Write Out) |
| `Ctrl + X` | Exit |
| `Ctrl + K` | Cut line |
| `Ctrl + U` | Paste (Uncut) |
| `Ctrl + W` | Search |
| `Ctrl + \` | Replace |
| `Ctrl + C` | Show cursor position |
| `Ctrl + Y` | Previous page |
| `Ctrl + V` | Next page |
| `Alt + A` | Start selection |
| `Alt + 6` | Copy selection |

#### nano Example Workflow
```bash
# Create and edit a file
nano script.sh

# Add content:
#!/bin/bash
echo "Hello nano!"

# Save: Ctrl + O, then Enter
# Exit: Ctrl + X
```

---

### vim - The Power Editor

> *"In my hands, Vim is the most powerful text editor."*

#### Why Learn vim?
- Pre-installed on virtually all Unix systems
- Extremely efficient for fast editing
- Keyboard-only (no mouse needed)
- Highly customizable

#### vim Modes

```
┌─────────────────────────────────────┐
│                                     │
│    NORMAL (Default)                 │
│    - Navigate                       │
│    - Delete, copy, paste            │
│    - Run commands                   │
│                                     │
│    ┌─────────────┐    i,a,o         │
│    │   INSERT    │ ───────────────► │
│    │  - Type text│◄───────────────  │
│    │  - Edit     │    Esc           │
│    └─────────────┘                  │
│                                     │
│    ┌─────────────┐    :             │
│    │   COMMAND  │ ───────────────► │
│    │  - Save    │◄───────────────   │
│    │  - Quit    │    Esc            │
│    └─────────────┘                  │
│                                     │
└─────────────────────────────────────┘
```

#### Essential vim Commands

##### Entering Modes
| Key | Mode |
|-----|------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `I` | Insert at line start |
| `A` | Insert at line end |
| `o` | New line below |
| `O` | New line above |
| `Esc` | Return to Normal |

##### Navigation
| Key | Action |
|-----|--------|
| `h` | Left |
| `j` | Down |
| `k` | Up |
| `l` | Right |
| `w` | Next word start |
| `e` | Next word end |
| `b` | Previous word |
| `0` | Line start |
| `$` | Line end |
| `gg` | File start |
| `G` | File end |
| `nG` | Go to line n |

##### Editing (in Normal mode)
| Key | Action |
|-----|--------|
| `x` | Delete character |
| `dd` | Delete line |
| `dw` | Delete word |
| `d$` | Delete to line end |
| `dgg` | Delete to file start |
| `u` | Undo |
| `Ctrl + r` | Redo |
| `yy` | Yank (copy) line |
| `p` | Paste after |
| `P` | Paste before |

##### Search & Replace
| Command | Action |
|---------|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `:%s/old/new/g` | Replace all |
| `:%s/old/new/gc` | Replace all (confirm) |

##### Saving & Exiting
| Command | Action |
|---------|--------|
| `:w` | Save |
| `:q` | Quit |
| `:wq` | Save & Quit |
| `:x` | Save & Quit |
| `:q!` | Quit without saving |
| `:w!` | Force save |
| `ZZ` | Save & Quit (same as :wq) |

#### vim Quick Start
```bash
vim myscript.sh

# 1. Press i to enter Insert mode
# 2. Type your content:
#!/bin/bash
echo "Hello from vim!"

# 3. Press Esc to return to Normal mode
# 4. Type :wq to save and quit
```

---

## 🔄 Converting & Transforming

### dos2unix / unix2dos
```bash
# Convert Windows line endings to Unix
dos2unix file.txt

# Convert Unix to Windows
unix2dos file.txt

# Check file format
file file.txt
```

### tr - Translate Characters
```bash
# Convert lowercase to uppercase
echo "hello" | tr 'a-z' 'A-Z'

# Delete characters
echo "hello123" | tr -d '0-9'

# Squeeze repeated characters
echo "heeeeelllo" | tr -s 'e'
```

---

## 📊 File Comparison

### diff - Compare Files
```bash
diff file1.txt file2.txt      # Side by side
diff -u file1.txt file2.txt  # Unified format
diff -i file1.txt file2.txt  # Ignore case
diff -w file1.txt file2.txt  # Ignore whitespace
```

### cmp - Binary Comparison
```bash
cmp file1.bin file2.bin       # Quick comparison
```

### comm - Line-by-Line Comparison
```bash
comm file1.txt file2.txt
# Output: unique to file1, unique to file2, common
```

---

## 🎓 Final Project: The Professional Log Monitor

Now that you've mastered the tools for viewing and editing files, let's see how a professional scripter might combine them. We'll examine a "Log Monitor" — a tool that uses `tail` to watch logs, `less` to search them, and `vim` to fix configuration issues discovered during monitoring.

### What the Professional Log Monitor Does:
1. **Automates Log Following** by wrapping `tail -f` with human-friendly headers.
2. **Filters Large Datasets** using `head` and `tail` to focus on the most relevant information.
3. **Pre-Configures Viewing** by launching `less` with line numbers and search patterns enabled.
4. **Simplifies File Edits** by providing a quick-switch mechanism to open specific lines in `vim`.
5. **Compares System Versions** using `diff` to audit changes between configuration files.
6. **Cleans Up Text** by stripping Windows carriage returns or transforming cases for readability.

### Key Snippet: Smart Log Tailing
A professional script doesn't just show logs; it prepares the environment so the scripter can react quickly to errors.

```bash
#!/bin/bash
# monitor_and_edit.sh

log_file="/var/log/syslog"

echo "=== Monitoring: $log_file ==="
echo "Pro Tip: Press Ctrl+C to stop following, then 'v' in 'less' to edit!"

# Start tailing the last 50 lines
tail -n 50 -f "$log_file"
```

### Key Snippet: Quick Configuration Audit
Before changing a file, a pro always checks what's different between the active config and the backup.

```bash
# Compare the live config with our known good backup
if diff -q "config.conf" "config.conf.bak" > /dev/null; then
    echo "Files are identical. No changes detected."
else
    echo "WARNING: Live config has diverged from backup!"
    diff -u "config.conf.bak" "config.conf" | less
fi
```

**Pro Tip:** Your ability to navigate and edit files efficiently is what makes you "fast" at the command line. Master these tools, and you'll be the person everyone calls when a server is down!

---

## ✅ Stack 3 Complete!

Congratulations! You've mastered the "eyes and hands" of the Linux system! You can now:
- ✅ **View files like a pro** using Advanced Cat and the Less pager
- ✅ **Slice and dice data** using Head and Tail
- ✅ **Navigate the nano editor** for quick, friendly changes
- ✅ **Command the vim editor** for high-speed, professional editing
- ✅ **Compare and transform files** using Diff, Cmp, and Tr
- ✅ **Monitor live systems** using real-time log following

### What's Next?
In the next stack, we'll dive into **Quoting & Expansion**. You'll learn the secret rules of how Bash handles spaces and special characters — the key to writing "Safe" scripts that never crash!

**Next: Stack 3B → Quoting, Expansion & Safe Handling →**

---

*End of Stack 3*
