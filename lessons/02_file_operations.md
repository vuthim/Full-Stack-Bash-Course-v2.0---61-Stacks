# 📂 STACK 2: FILE & DIRECTORY OPERATIONS
## Mastering the Filesystem

**What is the Filesystem?** Think of your computer's filesystem like a giant filing cabinet system. Directories (folders) are the drawers, and files are the documents inside. Navigation is how you move between drawers and find what you need!

**Why This Matters?** Every task in Linux involves files - editing configs, reading logs, running scripts. Master file operations and you'll feel at home in any Linux system.

---

## 🧭 Navigation Commands

### Understanding Your Location
Before you can move around, you need to know WHERE you are!

### pwd - Print Working Directory
```bash
pwd                 # Shows your current location (like "You are here" on a mall map)
pwd -P              # Physical path (ignores shortcuts/symlinks)
```

### cd - Change Directory (Moving Around)
```bash
cd /home/user       # Absolute path (full address from root)
cd Documents        # Relative path (from where you are now)
cd ..               # Go UP one level (like going up a floor in a building)
cd ../..            # Go UP two levels
cd ~                # Go HOME (your personal space)
cd -                # Go BACK to where you were before (like browser back button)
cd                  # Go home (same as cd ~)
```

### Special Directory Symbols (Memorize These!)
| Symbol | Meaning | Analogy |
|--------|---------|---------|
| `.` | Current directory | "Right here" |
| `..` | Parent directory | "One floor up" |
| `~` | Home directory | "Your room" |
| `/` | Root directory | "The building's foundation" |
| `-` | Previous directory |

---

## 📋 Listing Files

### ls - List Directory Contents
```bash
ls                  # Basic listing - just names
ls -l               # Long format - details like permissions, size, date
ls -a               # Show ALL files including hidden ones (starting with .)
ls -lah             # Most common combo: All files, Long format, Human-readable sizes
ls -lt              # Sort by modification time (newest first)
ls -lSr             # Sort by size (largest first, reverse order)
ls -R               # Recursive - show contents of subdirectories too
ls -1               # One file per line (good for piping to other commands)
```

> 💡 **Pro Tip:** Combine flags for powerful listings:
> - `ls -lat` shows all files (including hidden) sorted by time (newest first)
> - `ls -lrh` shows files in human-readable format, reversed order
> - `ls -l | grep "^d"` shows only directories (lines starting with 'd')

### Understanding ls -l Output (Made Simple)
When you run `ls -l`, you see detailed information about each file. Let's break down what each part means:

```
-rw-r--r--  1 user  staff   1234 Jan 15 10:30 file.txt
│   │   │   │     │     │      │          │
│   │   │   │     │     │      │          └── 8. Filename
│   │   │   │     │     │      └───────────── 7. Last modified date/time
│   │   │   │     │     └──────────────────── 6. File size (in bytes)
│   │   │   │     └────────────────────────── 5. Group name
│   │   │   └──────────────────────────────── 4. Owner username
│   │   └──────────────────────────────────── 3. Number of hard links
│   └──────────────────────────────────────── 2. Permissions (what users can do)
└──────────────────────────────────────────── 1. File type
```

| Part | What It Is | What It Means |
|------|------------|---------------|
| 1. File type | `-` | `-` = regular file, `d` = directory, `l` = symbolic link |
| 2. Permissions | `rw-r--r--` | Who can read, write, or execute: `rw-` (owner can read/write), `r--` (group can read), `r--` (others can read) |
| 3. Hard link count | `1` | How many different names point to this same file |
| 4. Owner | `user` | The user account that owns this file |
| 5. Group | `staff` | The group that has special access to this file |
| 6. Size | `1234` | File size in bytes (1,234 bytes = about 1.2KB) |
| 7. Date/Time | `Jan 15 10:30` | When the file was last modified |
| 8. Filename | `file.txt` | The name of the file |

> 💡 **Pro Tip:** Permission breakdown:
> - First character: file type (`-`=file, `d`=directory)
> - Next 3 chars: owner permissions (read/write/execute)
> - Next 3 chars: group permissions  
> - Last 3 chars: everyone else permissions
> - `r` = read, `w` = write, `x` = execute, `-` = no permission

---

## 📁 Creating Directories

### mkdir - Make Directory
```bash
mkdir myfolder              # Create one directory
mkdir dir1 dir2 dir3       # Create multiple
mkdir -p project           # Create nested (parent dirs)
mkdir -p backup/{2024,2025}# Create with braces (makes backup/2024 and backup/2025)
```

> 💡 **Pro Tip:** The `-p` flag is your friend! It creates parent directories automatically and doesn't complain if the directory already exists.

### rmdir - Remove Directory (only if empty)
```bash
rmdir myfolder             # Remove empty directory
rmdir -p project/subdir    # Remove and parent directories if empty
```
---

## 📄 File Operations

### cp - Copy Files/Directories
```bash
cp file.txt copy.txt               # Copy file
cp file.txt /backup/               # Copy to directory
cp -r folder/ backup/              # Copy directory (recursive)
cp -i file.txt backup/            # Interactive (ask before overwrite)
cp -v file.txt backup/            # Verbose (show what happened)
cp -p file.txt backup/            # Preserve permissions/timestamps
```

### mv - Move/Rename Files
```bash
mv old.txt new.txt                # Rename file
mv file.txt /documents/           # Move file
mv -i file.txt /documents/        # Interactive mode
mv -v file.txt /documents/        # Verbose mode
```

### rm - Remove Files
```bash
rm file.txt                        # Remove file
rm -r folder/                     # Remove directory + contents
rm -rf folder/                    # Force remove (no prompt!)
rm -i file.txt                    # Interactive (confirm)
rm -v file.txt                    # Verbose
```

⚠️ **Warning**: `rm -rf` is dangerous! Always double-check.

---

## 🔗 Links

### ln - Create Links
```bash
# Hard link (same file, different name)
ln original.txt hardlink.txt

# Symbolic/Soft link (like shortcut)
ln -s original.txt symlink.txt

# View link target
ls -l symlink.txt
readlink symlink.txt
```

---

## 👁 Viewing Files

### cat - Display Entire File
```bash
cat file.txt              # Show file content
cat -n file.txt          # Show with line numbers
cat -b file.txt          # Number non-empty lines
cat file1.txt file2.txt  # Concatenate files
```

### head/tail - View Beginning/End
```bash
head file.txt            # First 10 lines
head -n 20 file.txt      # First 20 lines
tail file.txt            # Last 10 lines
tail -n 20 file.txt     # Last 20 lines
tail -f file.txt         # Follow file (live updates)
tail -f /var/log/syslog  # Watch system logs
```

### less - View Large Files (Interactive)
```bash
less largefile.txt
```

| Key | Action |
|-----|--------|
| `q` | Quit |
| `↓` / `j` | Next line |
| `↑` / `k` | Previous line |
| `g` | Go to beginning |
| `G` | Go to end |
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |

---

## 📏 File Information

### wc - Word Count
```bash
wc file.txt              # Lines words bytes
wc -l file.txt          # Count lines only
wc -w file.txt          # Count words only
wc -c file.txt          # Count bytes
```

### file - Determine File Type
```bash
file script.sh
file image.png
file document.pdf
```

### stat - Detailed File Info
```bash
stat file.txt
```

---

## 🌳 tree - Visual Directory Structure
```bash
tree                    # Show tree of current dir
tree -L 2              # Limit depth to 2
tree -d                # Directories only
tree -a                # Include hidden
tree /home/user        # Show specific path
```

---

## 🏆 Practice Exercises

### Exercise 1: Create a Project Structure
```bash
# Create this structure:
# myproject/
#   ├── src/
#   ├── lib/
#   ├── tests/
#   └── docs/

mkdir -p myproject/{src,lib,tests,docs}
tree myproject
```

### Exercise 2: File Management Practice
```bash
# 1. Create a file
touch notes.txt

# 2. Write content to it
echo "My first note" > notes.txt

# 3. View it
cat notes.txt

# 4. Copy it
cp notes.txt notes_backup.txt

# 5. Rename it
mv notes.txt important_notes.txt

# 6. List all files
ls -lah
```

### Exercise 3: Log File Monitoring
```bash
# Watch a system log in real-time
tail -f /var/log/syslog

# Or on Ubuntu/Debian
tail -f /var/log/dmesg

# Or watch authentication logs
tail -f /var/log/auth.log
```

---

## ✅ Stack 2 Complete!

You learned:
- ✅ Navigate directories (cd, pwd)
- ✅ List files (various options like -l, -a, -h)
- ✅ Create/remove directories (mkdir, rmdir)
- ✅ Copy/move/rename (cp, mv, rm)
- ✅ View file contents (cat, head, tail, less)
- ✅ File information (wc, file, stat)
- ✅ Link files (ln)

### Next: Stack 3 → File Viewing & Editing →