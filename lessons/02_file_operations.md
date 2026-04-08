# 📂 STACK 2: FILE & DIRECTORY OPERATIONS
## Mastering the Filesystem

---

## 🧭 Navigation Commands

### pwd - Print Working Directory
```bash
pwd                 # Shows current location
pwd -P              # Physical path (no symlinks)
```

### cd - Change Directory
```bash
cd /home/user       # Absolute path
cd Documents        # Relative path
cd ..               # Go up one level
cd ../..            # Go up two levels
cd ~                # Go to home directory
cd -                # Go to previous directory
cd                  # Go to home (same as ~)
```

### Special Directory Symbols
| Symbol | Meaning |
|--------|---------|
| `.` | Current directory |
| `..` | Parent directory |
| `~` | Home directory |
| `-` | Previous directory |
| `/` | Root directory |

---

## 📋 Listing Files

### ls - List Directory Contents
```bash
ls                  # Basic listing
ls -l               # Long format (details)
ls -a               # Show hidden files
ls -lah             # All + long + human readable
ls -lt              # Sort by modification time
ls -lSr             # Sort by size (reverse)
ls -R               # Recursive (show subdirs)
ls -1               # One file per line
```

### Understanding ls -l Output
```
-rw-r--r--  1 user  staff   1234 Jan 15 10:30 file.txt
```

| Part | Meaning |
|------|---------|
| `-` | File type (`-`=file, `d`=dir, `l`=link) |
| `rw-r--r--` | Permissions (owner/group/others) |
| `1` | Hard link count |
| `user` | Owner |
| `staff` | Group |
| `1234` | Size in bytes |
| `Jan 15 10:30` | Modified date |
| `file.txt` | Filename |

---

## 📁 Creating Directories

### mkdir - Make Directory
```bash
mkdir myfolder              # Create one directory
mkdir dir1 dir2 dir3       # Create multiple
mkdir -p prc       # Create nested (parent dirs)
mkdir -p backup/{2024,2025}# Create with braces
```
<img src="/assets/image.png"  width="500">

### rmdir - Remove Directory (only if empty)
```bash
rmdir myfolder             # Remove empty directory
rmdir -p dir/subdir  roject/s      # Remove and parent if empty
```
<img src="" width="400">
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