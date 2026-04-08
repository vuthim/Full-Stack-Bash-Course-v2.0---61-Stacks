# 🔧 STACK 60: AWK DEEP DIVE
## Advanced Text Processing & Data Extraction

**What is AWK?** AWK is like a Swiss Army knife for text processing. Named after its creators (**A**ho, **W**einberger, **K**ernighan), it's designed specifically for processing column-based data and generating reports. If you've ever needed to "extract column 3 where column 1 matches X," you needed AWK!

**Why Learn AWK?** For text processing tasks, AWK is often faster to write than Python and more powerful than grep/sed alone. It's built into every Unix system and perfect for log analysis, report generation, and data transformation.

---

## 🔰 What is AWK?

AWK is a **pattern-matching** and **data processing** language.
- **A**ho, **W**einberger, **K**ernighan (the creators - yes, Brian Kernighan of K&R C fame!)
- Perfect for columnar data, reports, text transformation
- Built-in variables, functions, and control flow

### Why AWK? (When to Reach for It)
- ✅ **Faster than Python/Perl** for simple text tasks
- ✅ **Native to all Linux/Unix systems** - no installation needed
- ✅ **Powerful field parsing** - automatically splits lines into columns
- ✅ **Report generation** - BEGIN/middle/END structure is perfect for reports

### AWK Analogy for Beginners
```
Think of a spreadsheet:
- Each LINE is a row
- AWK automatically splits each row into columns (fields)
- You write rules like "if column 3 > 100, print columns 1 and 2"

That's AWK - it's a spreadsheet processor for the command line!
```

---

## 📊 Basic AWK Syntax

### Structure
```bash
awk 'pattern { action }' file.txt
awk 'pattern { action }' file1.txt file2.txt
command | awk 'pattern { action }'
```

### Fields and Records
```bash
# Default: whitespace separator
# $0 = entire line
# $1 = first field
# $2 = second field
# ...
# $NF = last field (Number of Fields)

echo "John 25 Engineer" | awk '{print $1}'
# Output: John

echo "John 25 Engineer" | awk '{print $NF}'
# Output: Engineer

echo "John 25 Engineer" | awk '{print $1, $3}'
# Output: John Engineer
```

---

## 🎯 Patterns

### Relational Patterns
```bash
# Print lines where 3rd field > 50
awk '$3 > 50' file.txt

# Print lines where 1st field equals "John"
awk '$1 == "John"' file.txt

# Print lines where 2nd field contains "test"
awk '$2 ~ /test/' file.txt

# Print lines where 2nd field does NOT contain "test"
awk '$2 !~ /test/' file.txt
```

### Regular Expressions
```bash
# Print lines containing "error"
awk '/error/' file.txt

# Print lines starting with "WARN"
awk '/^WARN/' file.txt

# Print lines ending with "done"
awk /done$/ file.txt

# Complex: lines with 3 or more digits
awk '/[0-9]{3,}/' file.txt
```

### Special Patterns
```bash
# BEGIN - runs before processing
awk 'BEGIN { print "Starting..." }' file.txt

# END - runs after processing
awk 'END { print "Done!" }' file.txt

# Both together
awk 'BEGIN { print "Processing..." } { print $0 } END { print "Complete!" }' file.txt
```

---

## 🔧 Built-in Variables

| Variable | Description |
|----------|-------------|
| `FS` | Field Separator (default: space/tab) |
| `OFS` | Output Field Separator |
| `RS` | Record Separator (default: newline) |
| `ORS` | Output Record Separator |
| `NF` | Number of Fields in current record |
| `NR` | Number of Records processed |
| `FNR` | Record number in current file |
| `FILENAME` | Current filename |
| `ARGC` | Number of arguments |
| `ARGV` | Array of arguments |

### Field Separators
```bash
# Input: comma-separated
awk -F',' '{print $1}' file.csv

# Multiple separators
awk -F'[,;]' '{print $1}' file.txt

# Using FS variable
awk 'BEGIN { FS="," } {print $1}' file.csv

# Output separator
awk 'BEGIN { OFS=" - " } {print $1, $2}' file.txt

# Both input and output
awk -F',' -v'OFS=|' '{print $1, $2}' file.csv
```

### Tab-Separated Values
```bash
# Using -F with tab
awk -F'\t' '{print $1}' file.tsv

# Using FS with \t
awk 'BEGIN { FS="\t" } {print $1}' file.tsv
```

---

## 🧮 Variables and Expressions

### Assignment
```bash
# Simple assignment
awk '{ sum = $1 + $2; print sum }' file.txt

# String concatenation
awk '{ name = $1 " " $2; print name }' file.txt

# Increment
awk '{ count++; print count }' file.txt

# Array assignment
awk '{ items[$1] = $2 }' file.txt
```

### Arithmetic Operators
```bash
# +, -, *, /, % (modulo), ^ (power)
awk '{ print $1 + $2 }' file.txt
awk '{ print $1 ^ 2 }' file.txt
awk '{ print $1 % 2 }' file.txt  # Modulo for odd/even
```

### Comparison
```bash
# ==, !=, <, >, <=, >=, ~, !~
awk '$1 > 100 { print $0 }' file.txt
awk '$1 ~ /test/ { print $0 }' file.txt
```

---

## 📝 Control Flow

### If-Else
```bash
awk '{
    if ($1 > 50) {
        print "High:", $1
    } else {
        print "Low:", $1
    }
}' file.txt

# Ternary operator
awk '{ print ($1 > 50) ? "High" : "Low" }' file.txt
```

### Loops
```bash
# For loop
awk '{
    for (i = 1; i <= NF; i++) {
        print $i
    }
}' file.txt

# While loop
awk '{
    i = 1
    while (i <= 3) {
        print $i
        i++
    }
}' file.txt

# Do-while
awk '{
    i = 1
    do {
        print $i
        i++
    } while (i <= 3)
}' file.txt
```

---

## 🔢 Arrays

### Basic Arrays
```bash
# Create and use array
awk '{ arr[NR] = $1 } END { for (i in arr) print i, arr[i] }' file.txt

# Associative arrays
awk '{ counts[$1]++ } END { for (name in counts) print name, counts[name] }' file.txt

# Check if key exists
awk 'BEGIN { if ("key" in arr) print "exists" }'

# Delete element
awk 'BEGIN { delete arr["key"] }'
```

### Common Array Patterns
```bash
# Count occurrences
awk '{count[$1]++} END {for (word in count) print word, count[word]}' file.txt

# Sum by category
awk '{sum[$1] += $2} END {for (cat in sum) print cat, sum[cat]}' file.txt

# Find max in each category
awk '{if ($2 > max[$1]) max[$1] = $2} END {for (k in max) print k, max[k]}' file.txt
```

---

## 📊 String Functions

### Common Functions
```bash
# length() - string length
awk '{ print length($0) }' file.txt

# substr() - substring
awk '{ print substr($1, 1, 5) }' file.txt  # First 5 chars

# index() - find position
awk '{ print index($1, "test") }' file.txt

# match() - regex match
awk '{ if (match($0, /[0-9]+/, arr)) print arr[0] }' file.txt

# split() - split into array
awk '{ split($1, parts, "-"); print parts[1] }' file.txt

# toupper() / tolower()
awk '{ print toupper($1) }' file.txt
awk '{ print tolower($1) }' file.txt

# gsub() - global substitute
awk '{ gsub(/foo/, "bar"); print }' file.txt

# sub() - first substitute
awk '{ sub(/foo/, "bar"); print }' file.txt

# sprintf() - format
awk '{ print sprintf("%.2f", $1) }' file.txt
```

### sprintf Examples
```bash
# Format numbers
awk '{ printf "Total: %-10s Amount: %8.2f\n", $1, $2 }' file.txt

# Padding
awk '{ printf "[%05d]\n", $1 }' file.txt
```

---

## 🔢 Numeric Functions

```bash
# rand() - random 0-1
awk 'BEGIN { print rand() }'

# srand() - seed
awk 'BEGIN { srand(); print rand() }'

# int() - truncate
awk 'BEGIN { print int(3.7) }'  # Output: 3

# sqrt() - square root
awk '{ print sqrt($1) }' file.txt
```

---

## 📋 Practical Examples

### Log Analysis
```bash
# Count error types
awk '/ERROR/ { errors[$NF]++ } END { for (e in errors) print e, errors[e] }' app.log

# Sum response times
awk '/GET/ { sum += $NF; count++ } END { print "Average:", sum/count }' access.log

# Find slowest requests
awk '{ if ($NF > 5) print $0 }' access.log | sort -k7 -n

# Extract IP addresses
awk '{ print $1 }' access.log | sort | uniq -c | sort -rn
```

### CSV Processing
```bash
# Print specific columns
awk -F',' '{print $1, $3, $5}' data.csv

# Skip header
awk -F',' 'NR>1 {print $1, $3}' data.csv

# Filter by column value
awk -F',' '$3 > 1000 {print $1, $3}' data.csv

# Calculate totals
awk -F',' '{sum += $3} END {print "Total:", sum}' data.csv

# Group by and sum
awk -F',' '{sum[$1] += $3} END {for (g in sum) print g, sum[g]}' data.csv
```

### System Administration
```bash
# Parse /etc/passwd
awk -F':' '{print $1, $6, $7}' /etc/passwd

# Analyze disk usage
df -h | awk 'NR>1 {print $5, $6}' | sort -n

# Process list
ps aux | awk 'NR>1 {sum[$11]++} END {for (p in sum) print sum[p], p}' | sort -rn

# Memory usage
free -h | awk 'NR==2 {printf "Used: %s / %s (%.2f%%)\n", $3, $2, ($3/$2)*100}'
```

### Report Generation
```bash
# Sales report
awk -F',' '
    BEGIN { print "=== Sales Report ===" }
    NR>1 {
        months[$2] += $3
        total += $3
    }
    END {
        for (m in months) print m ": $" months[m]
        print "Total: $" total
    }
' sales.csv
```

---

## 🎨 Formatting Output

### printf
```bash
# String formatting
awk '{printf "%-20s %10s\n", $1, $2}' file.txt

# Number formatting
awk '{printf "%.2f\n", $1}' file.txt

# Width and alignment
awk '{printf "[%5d] [%05d]\n", $1, $2}' file.txt
```

### Column Reports
```bash
# Create table
awk 'BEGIN { printf "%-15s %10s %8s\n", "Name", "Score", "Grade" }
     { printf "%-15s %10s %8s\n", $1, $2, ($2>=90)?"A":($2>=80)?"B":($2>=70)?"C":"F" }
     END { print "-------------------" }' grades.txt
```

---

## 🔗 Multi-Line Processing

### RS (Record Separator)
```bash
# Paragraph mode (blank line separator)
awk 'BEGIN { RS="" } {print NR, $0}' file.txt

# Fixed-width records
awk 'BEGIN { FIELDWIDTHS = "5 10 15" } {print $1, $2, $3}' file.txt
```

### Special Delimiters
```bash
# Multiple characters as separator
awk 'BEGIN { FPAT = "([^,]+)|(\"[^\"]+\")" } {print $1}' data.csv
```

---

## ⚡ Performance Tips

### Use Right Tools
```bash
# AWK is fast, but:
# - grep is faster for simple matching
# - sort/uniq is faster for counting
# - cut is faster for simple column extraction
```

### Optimization
```bash
# Avoid regex when possible
awk '$1 == "error"' file.txt    # Faster than /error/

# Use -F instead of FS=
awk -F',' '{print $1}' file.csv  # Faster

# Quit early with exit
awk 'NR==1 {print; exit}' file.txt

# Limit output
awk 'NR<=100' file.txt
```

---

## 🛠️ Advanced Techniques

### Two-File Processing
```bash
# Compare files
awk 'NR==FNR {a[$1]; next} !($1 in a)' file1.txt file2.txt

# Join files
awk 'NR==FNR {a[$1]=$2; next} {print $1, a[$1]}' file1.txt file2.txt
```

### Multi-line Records
```bash
# Process log entries spanning multiple lines
awk '/^Start/ {buf=""} {buf=buf $0 ORS} /End/ {print buf}' app.log
```

### Function Definitions
```bash
awk '
    function max(a, b) { return a > b ? a : b }
    { print max($1, $2) }
' file.txt
```

---

## 📝 AWK One-Liners

```bash
# Print line numbers
awk '{print NR, $0}'

# Print last field of every line
awk '{print $NF}'

# Print lines longer than 80 chars
awk 'length > 80' file.txt

# Reverse each line
awk '{for(i=NF;i>=1;i--) printf "%s ", $i; print ""}'

# Randomize lines
awk 'BEGIN {srand()} {print rand(), $0}' file.txt | sort -k1 | cut -d' ' -f2-

# Calculate column average
awk '{sum+=$1} END {print sum/NR}'

# Find duplicates
awk 'seen[$0]++ {print $0}' file.txt
```

---

## 🔍 AWK vs Other Tools

| Task | Best Tool |
|------|-----------|
| Simple search | grep |
| Simple replace | sed |
| Column extraction | cut |
| Column processing | awk |
| Complex transforms | awk/perl |
| Numeric analysis | awk |
| Report generation | awk |

---

## 🎓 Final Project: AWK Log Analyzer & Report Generator

Now that you've mastered the fields, patterns, and functions of AWK, let's see how a professional Data Engineer might use it. We'll examine a "Log Analyzer" — a tool that parses a raw Nginx access log, calculates total bandwidth, counts status codes, and identifies the most frequent visitors.

### What the AWK Log Analyzer Does:
1. **Parses Nginx Access Logs** by identifying fields like IP, Status Code, and Bytes Sent.
2. **Calculates Total Traffic** by summing up the "Bytes" column across thousands of lines.
3. **Identifies Error Trends** by counting the occurrences of 404 and 500 status codes.
4. **Finds Top Visitors** using an associative array to map IP addresses to hit counts.
5. **Generates a Formatted Report** with headers and footers using `BEGIN` and `END` blocks.
6. **Filters Slow Requests** by identifying lines where response time exceeds a threshold.

### Key Snippet: The "Report Card" Structure
AWK is perfect for this because of its `BEGIN { ... } { ... } END { ... }` structure.

```awk
# access_report.awk
BEGIN {
    FS=" "; # Space separated
    print "=== WEB ACCESS REPORT ==="
    print "IP ADDRESS      | STATUS | BYTES"
    print "--------------------------------"
}

# The main loop (runs for every line)
{
    # $1: IP, $9: Status Code, $10: Bytes
    total_bytes += $10
    status_counts[$9]++
    ips[$1]++
    
    # Print a formatted row for every line (optional)
    # printf "%-15s | %6s | %5d\n", $1, $9, $10
}

END {
    print "--------------------------------"
    print "TOTAL TRAFFIC: " total_bytes / 1024 / 1024 " MB"
    print "UNIQUE VISITORS: " length(ips)
    print "=== STATUS CODES ==="
    for (s in status_counts) {
        printf "Code %s: %d hits\n", s, status_counts[s]
    }
}
```

**Pro Tip:** This single AWK script replaces dozens of lines of Python or Java. When it comes to "quick and dirty" data processing, AWK is the undisputed king!

---

## ✅ Stack 60 Complete!

Congratulations! You've unlocked the "Data Science" powers of the Linux terminal! You can now:
- ✅ **Process columnar data** (CSV, logs, space-separated) with ease
- ✅ **Build complex reports** using `BEGIN` and `END` logic
- ✅ **Perform math on data streams** (Sums, Averages, Max/Min)
- ✅ **Use associative arrays** to count and group complex datasets
- ✅ **Write high-performance text filters** that outperform Python
- ✅ **Standardize raw data** into clean, professional formats

### What's Next?
In the next stack, we'll dive into **Tmux & Screen**. You'll learn how to manage persistent terminal sessions, allowing your scripts to run forever, even if you disconnect!

**Next: Stack 61 - tmux & Screen →**

---

*End of Stack 60*

- - **Previous:** [Stack 59 → Multi-Cluster Orchestration](59_multi_cluster.md)
- - **Next:** [Stack 61 - tmux & Screen](61_tmux_screen.md)