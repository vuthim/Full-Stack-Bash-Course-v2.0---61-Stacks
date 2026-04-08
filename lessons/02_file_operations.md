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
cp file.txt copy.txt               # Copy file to new name
cp file.txt /backup/               # Copy file to directory
cp -r folder/ backup/              # Copy directory (recursive) - includes contents
cp -i file.txt backup/            # Interactive - asks before overwriting
cp -v file.txt backup/            # Verbose - shows what's being copied
cp -p file.txt backup/            # Preserve - keeps original timestamps/permissions
```

> 💡 **Pro Tips for cp:**
> - Always use `-i` when copying important files to avoid accidental overwrites
> - Use `-v` when copying multiple files to see progress
> - For backups, consider `cp -av` to preserve everything and see what's happening

### mv - Move/Rename Files
```bash
mv old.txt new.txt                # Rename file (same as copying then deleting)
mv file.txt /documents/           # Move file to directory
mv -i file.txt /documents/        # Interactive - asks before overwriting
mv -v file.txt /documents/        # Verbose - shows what's being moved
```

> 💡 **Pro Tips for mv:**
> - Use `mv` to rename files: `mv oldname.txt newname.txt`
> - The `-i` flag prevents accidental overwrites
> - Unlike `cp`, `mv` within the same filesystem is instant (just changes pointers)

### rm - Remove Files
```bash
rm file.txt                        # Remove file
rm -r folder/                     # Remove directory and all its contents
rm -rf folder/                    # Force remove - BE CAREFUL! No prompts, no second chances
rm -i file.txt                    # Interactive - asks for confirmation before each removal
rm -v file.txt                    # Verbose - shows what's being removed
```

⚠️ **Warning**: `rm -rf` is dangerous! Always double-check.

---

## 🔗 Links

### ln - Create Links
Links are like aliases or shortcuts to files. There are two types:

```bash
# Hard link (same file, different name)
ln original.txt hardlink.txt

# Symbolic/Soft link (like shortcut or alias)
ln -s original.txt symlink.txt

# View link target
ls -l symlink.txt
readlink symlink.txt
```

> 💡 **Understanding Links:**
> - **Hard link**: Points directly to the file's data on disk. Multiple hard links = multiple names for the same data. Deleting one hard link doesn't delete the data until all links are gone.
> - **Symbolic link (symlink)**: Points to another file by name (like a shortcut). If the original file is deleted, the symlink becomes "broken" (points to nothing).
> 
> 🔍 **When to use which:**
> - Use **hard links** when you want multiple names for the same file within the same filesystem
> - Use **symbolic links** when you need to link across filesystems or create shortcuts (most common use case)

---

## 👁 Viewing Files

### cat - Display Entire File
```bash
cat file.txt              # Show entire file content
cat -n file.txt          # Show with line numbers (great for code)
cat -b file.txt          # Number only non-empty lines
cat file1.txt file2.txt  # Concatenate (join) files together
```

> 💡 **cat Tips:**
> - Use `cat -n` when you need to reference line numbers (like in error messages)
> - Be careful with large files - `cat` will dump the entire content to your terminal
> - For viewing large files, use `less` or `head`/`tail` instead

### head/tail - View Beginning/End
```bash
head file.txt            # Show first 10 lines (default)
head -n 20 file.txt      # Show first 20 lines
tail file.txt            # Show last 10 lines (default)
tail -n 20 file.txt     # Show last 20 lines
tail -f file.txt         # Follow file - show new lines as they're added (live)
tail -f /var/log/syslog  # Watch system logs in real-time
```

> 💡 **head/tail Tips:**
> - Use `head` to see what a file contains without loading it all
> - Use `tail -f` to monitor log files as they update (essential for debugging)
> - Combine with line numbers: `tail -n 50` shows last 50 lines
> - Press `Ctrl+C` to stop `tail -f` when you're done watching

### less - View Large Files (Interactive)
`less` is perfect for viewing large files because it doesn't load the entire file into memory - it shows you one screen at a time.

```bash
less largefile.txt
```

| Key | Action | When to Use |
|-----|--------|-------------|
| `q` | Quit | Exit less when you're done viewing |
| `Space` / `PageDown` | Next page | Move down one full screen |
| `b` / `PageUp` | Previous page | Move up one full screen |
| `↓` / `j` | Next line | Move down one line |
| `↑` / `k` | Previous line | Move up one line |
| `g` | Go to beginning | Jump to the first line |
| `G` | Go to end | Jump to the last line |
| `/pattern` | Search forward | Type `/hello` to find "hello" going forward |
| `?pattern` | Search backward | Type `?hello` to find "hello" going backward |
| `n` | Next match | Find the next occurrence of your search |
| `N` | Previous match | Find the previous occurrence of your search |

> 💡 **less Tips:**
> - Start typing `/` then your search term to find text as you type
> - Press `h` for help screen showing all less commands
> - Use `-N` flag to show line numbers: `less -N largefile.txt`
> - Press `Ctrl+C` to interrupt if less gets stuck

---

## 📏 File Information

### wc - Word Count
Think of `wc` (word count) as a quick way to get statistics about your files.

```bash
wc file.txt              # Shows lines, words, and bytes
wc -l file.txt          # Count lines only (useful for logging)
wc -w file.txt          # Count words only
wc -c file.txt          # Count bytes (exact file size)
```

> 💡 **wc Examples:**
> - `wc -l *.log` shows line counts for all log files
> - `wc -w essay.txt` counts words in your writing
> - `ls -la | wc -l` counts how many files are in a directory (including the total line)

### file - Determine File Type
The `file` command figures out what type of file something is by looking at its content, not just the extension.

```bash
file script.sh          # Tells you it's a shell script
file image.png          # Confirms it's really a PNG image
file document.pdf       # Verifies it's a PDF document
file mysterious_file    # Figures out what this unknown file actually is
```

> 💡 **Why this matters:** Sometimes files have misleading extensions. A file named `picture.jpg` might actually be a PNG or even a text file. The `file` command doesn't trust extensions - it looks at the actual content.

### stat - Detailed File Info
For even more detailed information than `ls -l`, use `stat`. It shows all the metadata the filesystem stores about a file.

```bash
stat file.txt
```

> 💡 **What stat shows you:**
> - File size and blocks
> - Device and inode numbers
> - All three timestamps (access, modify, change)
> - Permissions in numeric form
> - Owner and group IDs
> 
> This is useful for debugging permission issues or understanding filesystem behavior.

---

## 🌳 tree - Visual Directory Structure
The `tree` command creates a visual map of your directory structure, showing folders and subfolders in an easy-to-understand format.

```bash
tree                    # Show tree of current directory
tree -L 2              # Limit depth to 2 levels (don't go too deep)
tree -d                # Show directories only (no files)
tree -a                # Include hidden files (those starting with .)
tree /home/user        # Show specific path instead of current directory
```

> 💡 **tree Tips:**
> - If you don't have tree installed, try: `sudo apt install tree` (Ubuntu/Debian) or `brew install tree` (macOS)
> - Great for understanding complex project structures at a glance
> - Use `tree -L 1` to see just the immediate contents of a directory
> - Combine with `-P` to show only specific patterns: `tree -P "*.txt"` shows only text files

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

# The -p flag creates parent directories as needed
# The {src,lib,tests,docs} syntax creates all four directories at once
mkdir -p myproject/{src,lib,tests,docs}

# Verify the structure was created correctly
tree myproject
```

> 💡 **What you'll learn:** How to create complex directory structures efficiently using brace expansion.

### Exercise 2: File Management Practice
```bash
# 1. Create an empty file
touch notes.txt

# 2. Write content to it (overwrites if file exists)
echo "My first note" > notes.txt

# 3. View the content
cat notes.txt

# 4. Create a backup copy
cp notes.txt notes_backup.txt

# 5. Rename the original file
mv notes.txt important_notes.txt

# 6. See all files with detailed information
ls -lah
```

> 💡 **What you'll learn:** The complete lifecycle of a file - creation, editing, backing up, renaming, and listing.

### Exercise 3: Log File Monitoring
```bash
# Watch a system log in real-time (press Ctrl+C to stop)
tail -f /var/log/syslog

# Alternative logs to try:
# tail -f /var/log/dmesg          # Kernel messages
# tail -f /var/log/auth.log       # Authentication attempts
# tail -f /var/log/nginx/access.log # Web server access (if nginx installed)
```

> 💡 **What you'll learn:** How to monitor files as they change - essential for debugging and system administration.

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

### Navigation
- **Previous:** [Stack 1 → Bash Fundamentals](01_fundamentals.md)
- **Next:** [Stack 3 → File Viewing & Editing](03_file_viewing_editing.md)

---