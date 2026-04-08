# 🔍 STACK 4: TEXT PROCESSING
## Your Text Processing Toolbox

> *"In the Unix philosophy, text is the universal interface."*
>
> Think of these tools as your Swiss Army knife for working with text - they let you search, filter, change, and analyze text in powerful ways.

---

## 🔍 grep - Your Text Search Tool

`grep` = **G**lobal **R**egular **E**xpression **P**rint
Think of grep as a super-powered "find" tool for text. It lets you search for patterns inside files.
### Basic Usage (Try These Examples)

Think of grep like a search engine for text inside files:

```bash
# Search for a pattern in a file (like Ctrl+F in a text editor)
grep "error" logfile.txt           # Find lines containing "error"

# Search in multiple files at once
grep "error" *.log                 # Search all .log files for "error"

# Search recursively in directories (search folder and all subfolders)
grep -r "error" /var/log/          # Search /var/log and all subfolders

# Case-insensitive search (ignore upper/lower case differences)
grep -i "error" logfile.txt        # Find "error", "ERROR", "Error", etc.

# Show line numbers (so you know where the match is)
grep -n "error" logfile.txt        # Show line numbers with matches

# Show only the matching part (not the whole line)
grep -o "error" logfile.txt        # Show just "error" for each match

# Count how many matches you found
grep -c "error" logfile.txt        # Count the number of matching lines

# Invert match (show lines that DON'T contain the pattern)
grep -v "error" logfile.txt        # Show all lines WITHOUT "error"
```

### grep Options Overview
| Option | Description |
|--------|-------------|
| `-i` | Ignore case |
| `-v` | Invert match |
| `-n` | Show line numbers |
| `-c` | Count matches |
| `-o` | Only matching part |
| `-l` | Show filenames only |
| `-L` | Show files WITHOUT match |
| `-r` | Recursive search |
| `-w` | Match whole word |
| `-x` | Match whole line |
| `-A n` | Show n lines after match |
| `-B n` | Show n lines before match |
| `-C n` | Show n lines context |

### grep Examples
```bash
# Find all IP addresses in a log
grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' access.log

# Find lines with "ERROR" or "WARN" or "FATAL"
grep -E 'ERROR|WARN|FATAL' app.log

# Find processes named "nginx"
ps aux | grep nginx

# Find files containing "TODO"
grep -r "TODO" --include="*.js" .
```

---

## sed - The Stream Editor

`sed` = **S**tream **ED**itor - Edit files without opening them

### Basic Structure
```bash
sed 's/old/new/' file.txt           # Replace first occurrence per line
sed 's/old/new/g' file.txt          # Replace all occurrences
sed -i 's/old/new/' file.txt        # In-place edit
```

### sed Commands
| Command | Description |
|---------|-------------|
| `s/` | Substitute |
| `d` | Delete |
| `p` | Print |
| `i\` | Insert before |
| `a\` | Append after |
| `c\` | Change line |

### sed Examples
```bash
# Replace "foo" with "bar" (first occurrence per line)
sed 's/foo/bar/' file.txt

# Replace ALL occurrences
sed 's/foo/bar/g' file.txt

# Replace on specific line number
sed '3s/foo/bar/' file.txt

# Delete lines containing "pattern"
sed '/pattern/d' file.txt

# Delete line 5
sed '5d' file.txt

# Insert line before line 3
sed '3i\New line here' file.txt

# Append after line 3
sed '3a\New line after' file.txt

# Print lines 5-10
sed -n '5,10p' file.txt

# Multiple commands
sed -e 's/foo/bar/' -e 's/baz/qux/' file.txt

# Use regex patterns
sed -E 's/[0-9]{3}/XXX/g' file.txt

# Use & as matched string reference
sed 's/word/(&)/g' file.txt        # word → (word)

# In-place editing (careful!)
sed -i 's/old/new/g' file.txt

# Backup before in-place edit
sed -i.bak 's/old/new/g' file.txt
```

---

## awk - The Advanced Text Processor

`awk` = **A**ho, **W**einberger, **K**ernighan

### Basic Usage
```bash
awk '{print}' file.txt              # Print all lines
awk '/pattern/ {print}' file.txt   # Print lines matching pattern
awk '{print $1}' file.txt          # Print first column
```

### Field References
```bash
$0    # Entire line
$1    # First field
$2    # Second field
$NF   # Last field
$NR   # Line number
$NF   # Number of fields
```

### awk Examples
```bash
# Print first column
awk '{print $1}' data.txt

# Print last column
awk '{print $NF}' data.txt

# Print multiple columns
awk '{print $1, $3}' data.txt

# Custom separator (colon)
awk -F: '{print $1}' /etc/passwd

# Use with if condition
awk '{if ($1 > 50) print $0}' data.txt

# Calculate sum
awk '{sum+=$1} END {print sum}' numbers.txt

# Print with formatting
awk '{printf "%-10s %s\n", $1, $2}' data.txt

# Multiple conditions
awk '/error/ || /fail/ {print "ALERT: " $0}' log.txt

# Built-in variables
awk 'BEGIN {FS=","} {print $1}' data.csv
```

### awk Variables
| Variable | Description |
|----------|-------------|
| `FS` | Field Separator |
| `OFS` | Output Field Separator |
| `RS` | Record Separator |
| `ORS` | Output Record Separator |
| `NR` | Number of Records (lines) |
| `NF` | Number of Fields |
| `FILENAME` | Current filename |

---

## sort - Sorting Lines

```bash
# Basic sort
sort file.txt

# Sort numerically
sort -n numbers.txt

# Sort in reverse order
sort -r file.txt

# Sort by column (e.g., column 2)
sort -k2 file.txt

# Sort numerically by column 3
sort -k3 -n file.txt

# Remove duplicates after sort
sort -u file.txt

# Sort by month
sort -M file.txt

# Case-insensitive sort
sort -f file.txt

# Check if file is sorted
sort -c file.txt
```

---

## uniq - Remove Duplicates

```bash
# Remove adjacent duplicates
uniq file.txt

# Show only duplicate lines
uniq -d file.txt

# Show unique lines only
uniq -u file.txt

# Count occurrences
uniq -c file.txt

# Case-insensitive
uniq -i file.txt

# Common: sort + uniq
sort file.txt | uniq
sort file.txt | uniq -c | sort -rn    # Count & sort by frequency
```

---

## wc - Word/Line Count

```bash
# All (lines, words, characters)
wc file.txt

# Lines only
wc -l file.txt

# Words only
wc -w file.txt

# Characters only
wc -c file.txt

# Max line length
wc -L file.txt

# Multiple files
wc -l *.txt

# Total for all files
wc -l *.txt | tail -1
```

---

## cut - Extract Columns

```bash
# Extract first field (by character position)
cut -c1-5 file.txt

# Extract columns 1-10
cut -c1-10 file.txt

# Extract by byte
cut -b1-100 file.txt

# Extract by delimiter (comma)
cut -d',' -f1 file.csv           # First field
cut -d',' -f1,3 file.csv        # Fields 1 and 3
cut -d',' -f1-3 file.csv        # Fields 1 to 3

# Extract all but specific field
cut -d',' --complement -f2 file.csv

# Use with other commands
ps aux | cut -d' ' -f1,11       # Get PID and command
```

---

## 🔗 Combining Tools (Pipelines)

The real power comes from combining these tools!

```bash
# Find errors, show line numbers, sort unique
grep -n "error" log.txt | cut -d: -f1 | sort -nu

# Top 10 most common errors
grep "ERROR" app.log | awk '{print $5}' | sort | uniq -c | sort -rn | head

# Extract emails from file
grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt | sort -u

# CSV: Find rows where column 3 > 100
awk -F',' '$3 > 100' data.csv

# Sum column 4
awk -F',' '{sum+=$4} END {print sum}' data.csv

# Replace text in multiple files
find . -name "*.txt" -exec sed -i 's/old/new/g' {} \;
```

---

## 🏆 Practice Exercises

### Exercise 1: Log Analysis
```bash
# Create sample log
cat > app.log << 'EOF'
2024-01-15 10:23:45 INFO Starting application
2024-01-15 10:23:46 ERROR Database connection failed
2024-01-15 10:23:47 WARN Retry attempt 1
2024-01-15 10:23:48 ERROR Database connection failed
2024-01-15 10:23:49 INFO Connected to database
2024-01-15 10:23:50 DEBUG Query executed
2024-01-15 10:23:51 ERROR Authentication failed
EOF

# All errors
grep "ERROR" app.log

# Count each error type
grep "ERROR" app.log | awk '{print $5}' | sort | uniq -c
```

### Exercise 2: Data Processing
```bash
# Create CSV data
cat > data.csv << 'EOF'
name,age,city,salary
John,25,NYC,50000
Jane,30,LA,60000
Bob,25,NYC,55000
Alice,28,NYC,58000
EOF

# Find people from NYC
awk -F',' '/NYC/ {print $1}' data.csv

# Average salary
awk -F',' 'NR>1 {sum+=$4; count++} END {print "Avg:", sum/count}' data.csv
```

### Exercise 3: System Monitoring
```bash
# Find top processes by memory
ps aux --sort=-%mem | awk 'NR<=6 {print $4"% "$11}'

# Find largest files
du -h /var/log/* 2>/dev/null | sort -hr | head -10

# Find files modified today
find . -type f -mtime 0 -ls
```

---

## ✅ Stack 4 Complete!

You learned:
- ✅ **grep** - Pattern matching & searching
- ✅ **sed** - Stream editing & substitution
- ✅ **awk** - Advanced text processing & calculations
- ✅ **sort** - Sorting lines
- ✅ **uniq** - Removing duplicates
- ✅ **wc** - Counting words/lines/characters
- ✅ **cut** - Extracting columns
- ✅ **Pipelines** - Combining tools for powerful processing

### Next: Stack 5 → Variables & Data Types →