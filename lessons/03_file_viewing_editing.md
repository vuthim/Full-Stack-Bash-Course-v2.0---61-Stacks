# 📝 STACK 3: FILE VIEWING, EDITING & SAFE HANDLING
## Looking at and Changing Files Safely

In this stack, we'll learn how to view, edit, and manipulate files safely and effectively. These skills are essential for everything from simple configuration changes to complex data processing.

---

## Part A: Looking at Files and Using Text Editors

Before we can edit files, we need to know how to look at them properly. Think of file viewing like different ways to examine a book:
- **cat** is like reading the whole book at once
- **less** is like using a bookmark to jump around
- **head/tail** are like looking at just the first or last chapters
- **nano/vim** are like being able to edit the book itself

---

## 🔍 Advanced Ways to Look at Files

### cat - More Than Just Displaying Files
The `cat` command is versatile - it can display files, create new ones, append to existing files, and combine multiple files.

```bash
cat file.txt                    # Display file contents
cat -n file.txt                 # Show all lines with numbers
cat -b file.txt                 # Number only non-empty lines
cat -s file.txt                 # Remove extra blank lines
cat -T file.txt                 # Show tabs as ^I (useful for debugging)
cat -A file.txt                 # Show ALL characters (including spaces, tabs)

# Create file from keyboard (type content, then Ctrl+D to save)
cat > newfile.txt
Hello World
[Press Ctrl+D here to save and exit]

# Append to existing file (adds to the end)
cat >> existing.txt
More content
[Press Ctrl+D here to save and exit]

# Combine multiple files into one
cat file1.txt file2.txt > combined.txt
```

> 💡 **cat Tips:**
> - Use `cat -n` when you need to reference line numbers (like in error messages)
> - The `>` creates/overwrites a file, while `>>` appends to existing content
> - Press `Ctrl+D` to signal "end of input" when using cat to create files
> - Be careful with large files - `cat` will display the entire content at once

---

### less - The Powerful Pager

Think of `less` as a sophisticated book reader for your terminal. Instead of dumping an entire large file onto your screen (which would be overwhelming), `less` shows you one screenful at a time and lets you navigate through the file efficiently.

```bash
less largefile.log          # Basic usage - view file one screen at a time
less -N largefile.log       # Show line numbers (helpful for referencing)
less -X largefile.log       # Keep file content visible after quitting
less -S largefile.log       # Don't wrap long lines (scroll horizontally instead)
```

#### less Navigation Made Simple

| Key | What It Does | When to Use It |
|-----|--------------|----------------|
| `Space` / `PageDown` | Move down one screen | When you want to see the next chunk of content |
| `b` / `PageUp` | Move up one screen | When you want to go back to see previous content |
| `↓` / `j` | Move down one line | For fine-grained movement down |
| `↑` / `k` | Move up one line | For fine-grained movement up |
| `g` | Go to the very beginning | When you want to start from the top |
| `G` | Go to the very end | When you want to jump to the bottom |
| `NUMBERg` | Go to a specific line | Type `50g` to go to line 50 |
| `/pattern` | Search forward | Type `/error` to find the next "error" |
| `?pattern` | Search backward | Type `?error` to find the previous "error" |
| `n` | Repeat last search in same direction | Find the next match after your initial search |
| `N` | Repeat last search in opposite direction | Find the previous match after your initial search |
| `v` | Open current file in vim editor | When you need to edit what you're viewing |
| `h` | Show help screen | When you forget the keyboard shortcuts |
| `q` | Quit less | When you're done viewing the file |

> 💡 **less Tips for Beginners:**
> - Start typing `/` then your search term to find text as you type (like in web browsers)
> - Press `h` anytime to see a complete list of all less commands
> - Use `-N` flag when you need to reference line numbers (common in debugging)
> - If text looks squished, try `-S` to prevent line wrapping and scroll horizontally instead
> - Press `Ctrl+C` to interrupt if less gets stuck or takes too long to load

---

### head & tail - Selective Viewing

Sometimes you don't need to see an entire file - just the beginning or end. That's where `head` and `tail` come in handy.

```bash
# Head - First N lines (shows the start of a file)
head file.txt                  # Shows first 10 lines (default)
head -n 20 file.txt            # Shows first 20 lines
head -c 100 file.txt           # Shows first 100 bytes (useful for binary files)

# Tail - Last N lines (shows the end of a file)
tail file.txt                  # Shows last 10 lines (default)
tail -n 25 file.txt            # Shows last 25 lines
tail -f file.txt               # Follow file - shows new lines as they're added (LIVE)
tail -f -n 100 file.txt        # Shows last 100 lines, then follows for new ones

# Multiple files at once
head -n 5 file1.txt file2.txt  # Shows first 5 lines of each file
```

> 💡 **When to use which:**
> - Use `head` when you want to see what a file contains (like previewing a document)
> - Use `tail` when you want to see recent activity (like checking the latest log entries)
> - Use `tail -f` to monitor logs in real-time (essential for debugging server issues)
> - Press `Ctrl+C` to stop `tail -f` when you're done watching
> 
> 🔍 **Pro Tip:** Combine with other commands:
> - `head -n 5 file.txt | tail -n 3` shows lines 3-5 of a file
> - `grep "error" app.log | tail -n 10` shows the 10 most recent errors

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

If you're new to command-line text editors, nano is the perfect place to start. It's designed to be intuitive and user-friendly, with helpful menus visible at all times.

```bash
nano filename.txt              # Open or create a file for editing
nano -m filename.txt          # Enable mouse support (click to place cursor)
nano -c filename.txt          # Show cursor position (line/column numbers)
nano +100 filename.txt        # Open file and jump directly to line 100
```

> 💡 **nano Tips for Beginners:**
> - The menu at the bottom shows all available shortcuts (^ means Ctrl key)
> - `Ctrl + O` = Write Out (save), then press Enter to confirm filename
> - `Ctrl + X` = Exit nano (will prompt to save if you have unsaved changes)
> - `Ctrl + K` = Cut entire line, `Ctrl + U` = Paste (uncut) line
> - `Ctrl + W` = Search for text, `Ctrl + \` = Replace text
> - Just start typing to add text - no special modes needed!
> - Arrow keys work normally for moving the cursor

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

#### Why Learn vim? (Even If It Seems Weird at First)
Vim might seem strange when you first encounter it, but it's worth learning because:
- **It's everywhere**: Pre-installed on virtually all Unix/Linux systems (including servers you might remote into)
- **It's fast**: Once you learn the basics, you can edit text faster than with any mouse-based editor
- **It's keyboard-only**: No need to take your hands off the keyboard to reach for a mouse
- **It's customizable**: You can tailor it exactly to your workflow preferences

> 💡 **Don't worry if vim feels confusing at first** - everyone struggles initially. The key is to learn just enough to get by, then gradually pick up more advanced features as you need them.

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

### dos2unix / unix2dos - Fixing Line Endings
Different operating systems handle line endings differently:
- Windows uses `\r\n` (carriage return + line feed)
- Unix/Linux/macOS uses `\n` (just line feed)
- Old Mac OS used `\r` (just carriage return)

When you move files between systems, you might see strange `^M` characters or lines that don't display correctly. These tools fix that:

```bash
# Convert Windows line endings to Unix format
# Fixes the ^M characters you might see at end of lines
dos2unix file.txt

# Convert Unix line endings to Windows format
# Useful if you're creating a file for Windows users
unix2dos file.txt

# Check what type of line endings a file currently has
file file.txt
```

> 💡 **When to use these:**
> - Use `dos2unix` when you get a file from Windows that shows `^M` at line ends
> - Use `unix2dos` when you're creating a file that Windows users need to read
> - The `file` command will show you if a file has "CRLF" (Windows) or "LF" (Unix) line endings

### tr - Translate Characters
The `tr` command (short for "translate") is like a character find-and-replace tool. It reads input, changes characters according to your rules, and outputs the result.

```bash
# Convert lowercase letters to uppercase
echo "hello" | tr 'a-z' 'A-Z'
# Output: HELLO

# Delete all digits (0-9) from the input
echo "hello123" | tr -d '0-9'
# Output: hello

# Squeeze repeated characters down to just one
echo "heeeeelllo" | tr -s 'e'
# Output: hello (multiple e's become single e)
```

> 💡 **tr Tips:**
> - Think of `tr` as working on individual characters, not words or lines
> - Use it with pipes (`|`) to process output from other commands
> - Common uses: changing case, removing unwanted characters, cleaning up whitespace
> - The `-d` flag deletes specified characters
> - The `-s` flag "squeezes" repeated characters down to single instances

---

## 📊 File Comparison

Sometimes you need to see exactly how two files differ - maybe you edited a configuration file and want to see what changed, or you're comparing two versions of a script. These tools help you spot the differences.

### diff - Compare Files (Shows What's Different)
The `diff` command shows you exactly what lines are different between two files. Think of it as a "spot the difference" game for text files.

```bash
diff file1.txt file2.txt      # Shows differences in traditional format
diff -u file1.txt file2.txt  # Shows differences in unified format (preferred for patches)
diff -i file1.txt file2.txt  # Ignores case differences (treat "A" and "a" as same)
diff -w file1.txt file2.txt  # Ignores whitespace differences (spaces/tabs don't matter)
```

> 💡 **diff Output Explained:**
> - Lines starting with `-` are in file1 but not file2 (removed)
> - Lines starting with `+` are in file2 but not file1 (added)
> - Lines starting with ` ` (space) are in both files (unchanged)
> - The `-u` (unified) format shows context around changes, making it easier to understand
> - Example: `- apple` means "apple was in the first file but removed from the second"
> - Example: `+ banana` means "banana was added to the second file"

### cmp - Binary Comparison (Quick Check)
Sometimes you just need to know if two files are identical or not - you don't need to see the differences. That's what `cmp` is for.

```bash
cmp file1.bin file2.bin       # Returns nothing if files are identical
# If files differ, shows the first byte position where they differ
```

> 💡 **When to use cmp vs diff:**
> - Use `cmp` when you just need a yes/no answer: "Are these files exactly the same?"
> - Use `diff` when you need to know: "How are these files different?"
> - `cmp` is faster for large files when you only need to know if they match

### comm - Line-by-Line Comparison (For Sorted Files)
The `comm` command compares two sorted files and shows you three columns:
1. Lines only in the first file
2. Lines only in the second file  
3. Lines in both files

```bash
comm file1.txt file2.txt
# Output format: 
#   [only in file1]   [only in file2]   [in both files]
# example output:
#   apple             banana            cherry
#   (tab)             (tab)             date
```

> 💡 **Important:** `comm` requires both files to be sorted first! Use `sort` if needed:
> ```bash
> comm <(sort file1.txt) <(sort file2.txt)
> ```
>
> 🔍 **Useful comm flags:**
> - `comm -1 file1.txt file2.txt` hides column 1 (only show lines unique to file2 or in both)
> - `comm -2 file1.txt file2.txt` hides column 2 (only show lines unique to file1 or in both)
> - `comm -3 file1.txt file2.txt` hides column 3 (only show lines that are different, not common)

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

### Navigation
- **Previous:** [Stack 2 → File & Directory Operations](02_file_operations.md)
- **Next:** [Stack 3B → Quoting, Expansion & Safe Handling](03b_quoting_expansion.md)

---

*End of Stack 3*
