# 🎯 STACK 10: REGULAR EXPRESSIONS
## Pattern Matching Power

**What are Regular Expressions?** Think of regex as "search with superpowers." Normal search finds exact matches ("find the word hello"). Regex finds patterns ("find any word that starts with 'h', has 4 letters, and ends with 'o'"). It's the difference between finding one fish and finding every fish of a certain species!

**Why This Matters?** Regex lets you find, validate, and transform text patterns that would be impossible with simple search. Log parsing, data validation, text transformation - regex is essential for text processing.

---

## 📝 What Are Regular Expressions?

A sequence of characters that defines a search pattern.

### Regex Analogy for Beginners
```
Normal search:  "Find the exact word 'cat'"
Regex:           "Find any 3-letter word that starts with 'c' and ends with 't'"
                 → cat, cut, cot, cit, etc.

Normal search:  "Find emails I typed manually"
Regex:           "Find ANYTHING that looks like an email (word@word.word)"
                 → Finds all emails, even ones you've never seen before
```

### Types of Regex
- **Basic Regular Expressions (BRE)** - Used by `grep`, `sed` (default)
- **Extended Regular Expressions (ERE)** - Used by `egrep`, `grep -E` (more features)
- **Perl-Compatible (PCRE)** - Used by `grep -P` (most powerful)

**Pro Tip:** Start with basic patterns. Regex has a learning curve, but even 5 patterns cover 80% of use cases!

---

## 🔤 Basic Patterns

### Literal Characters
```bash
# Match exact string
echo "hello world" | grep "hello"
# Matches: hello world
```

### Special Characters (Need escaping)
```bash
.  ^  $  [  ]  \  *  +  ?  {  }  (  )  |
```

### Matching Any Character (.)
```bash
# . matches any single character
echo "cat" | grep "c.t"    # matches
echo "cut" | grep "c.t"    # matches
echo "coat" | grep "c.t"   # no match (2 chars)
```

### Anchors
```bash
# ^ - Start of line
echo "hello" | grep "^hello"    # matches (at start)
echo "say hello" | grep "^hello"  # no match

# $ - End of line
echo "hello" | grep "hello$"   # matches (at end)
echo "hello world" | grep "hello$"  # no match

# Combined
echo "hello world" | grep "^hello world$"
```

---

## 📦 Character Classes

### Common Classes
```bash
[abc]        # Any of a, b, or c
[^abc]       # Not a, b, or c
[a-z]        # Range: a to z
[A-Z]        # Uppercase
[0-9]        # Digit
[a-zA-Z]     # Letter
[a-zA-Z0-9]  # Alphanumeric
```

### Examples
```bash
# Match any vowel
echo "cat" | grep "[aeiou]"    # matches (a)

# Match any non-vowel
echo "cat" | grep "[^aeiou]"   # matches (c, t)

# Match any digit
echo "abc123" | grep "[0-9]"    # matches

# Match phone number pattern
echo "555-123-4567" | grep "[0-9]\{3\}-[0-9]\{3\}-[0-9]\{4\}"
```

### Named Character Classes
```bash
[:digit:]    # Same as [0-9]
[:alpha:]    # Letters
[:alnum:]    # Letters and digits
[:lower:]    # Lowercase
[:upper:]    # Uppercase
[:space:]    # Whitespace
[:punct:]    # Punctuation

# Usage
echo "hello" | grep "[[:alpha:]]+"      # matches
echo "123" | grep "[[:digit:]]"        # matches
```

---

## ➕ Quantifiers

### Basic Quantifiers
```bash
*       # 0 or more (same as {0,})
+       # 1 or more (same as {1,})
?       # 0 or 1 (same as {0,1})
{n}     # Exactly n times
{n,}    # n or more times
{n,m}   # Between n and m times
```

### Examples
```bash
# Zero or more
echo "gooooal" | grep "go*al"    # matches

# One or more
echo "cat" | grep "c.+t"         # matches (one or more)
echo "ct" | grep "c.+t"          # no match (needs at least 1)

# Zero or one
echo "color" | grep "colou?r"    # matches
echo "colour" | grep "colou?r"   # also matches (the u is optional)

# Exact count
echo "aab" | grep "a{2}b"        # matches (exactly 2 a's)

# Range
echo "aaaa" | grep "a{2,4}"      # matches (2-4 a's)
echo "aaa" | grep "a{2,4}"       # matches
echo "aaaaa" | grep "a{2,4}"    # no match (too many)
```

---

## 🔗 Grouping & Alternation

### Grouping
```bash
# () - Grouping
echo "abab" | grep "\(ab\)\{2\}"   # matches

# Capturing
echo "hello123world" | grep -o "\([a-z]+\)[0-9]*"
# Output: hello123
```

### Alternation (OR)
```bash
# | - Alternation (use grep -E for ERE)
echo "cat" | grep -E "cat|dog"     # matches
echo "dog" | grep -E "cat|dog"     # matches
echo "bird" | grep -E "cat|dog"    # no match
```

---

## 📍 Working with grep

### Basic grep
```bash
grep "pattern" file.txt

# Case insensitive
grep -i "error" log.txt

# Show line numbers
grep -n "error" log.txt

# Invert match
grep -v "debug" log.txt

# Show count only
grep -c "error" log.txt

# Show only matching part
grep -o "error" log.txt
```

### Extended Regex with -E
```bash
# Use | for OR (no escaping)
grep -E "error|warning|failed" log.txt

# Use + for 1 or more
grep -E "[0-9]+" file.txt

# Use ? for 0 or 1
grep -E "colou?r" file.txt

# Use {} as-is
grep -E "[0-9]{3}-[0-9]{4}" file.txt
```

---

## 🎯 Common Regex Patterns

### Email
```bash
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
```

### Phone (US)
```bash
[0-9]{3}-[0-9]{3}-[0-9]{4}
# or
\([0-9]{3}\) [0-9]{3}-[0-9]{4}
```

### IP Address
```bash
[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}
```

### URL
```bash
https?://[a-zA-Z0-9.-]+(/[a-zA-Z0-9._~:/?#\[\]@!$&'()*+,;=-]*)?
```

### Date (YYYY-MM-DD)
```bash
[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])
```

---

## 🛠️ Real-World Examples

### Example 1: Extract Emails
```bash
# From file
grep -Eo "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" file.txt

# From web page
curl -s page.html | grep -Eo "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" | sort -u
```

### Example 2: Extract IPs
```bash
# Find all IP addresses
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" log.txt | sort | uniq

# Filter valid IPs only
grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" log.txt | while read ip; do
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo $ip
    fi
done
```

### Example 3: Log Analysis
```bash
# Find ERROR lines
grep "ERROR" app.log

# Find ERROR or WARN
grep -E "ERROR|WARN|FATAL" app.log

# Find lines with timestamps
grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" app.log | grep "ERROR"
```

### Example 4: Password Validation
```bash
valid_password() {
    local pw=$1
    
    # At least 8 chars, 1 uppercase, 1 lowercase, 1 digit
    if [[ ${#pw} -ge 8 ]] && \
       [[ $pw =~ [A-Z] ]] && \
       [[ $pw =~ [a-z] ]] && \
       [[ $pw =~ [0-9] ]]; then
        return 0
    else
        return 1
    fi
}

valid_password "Pass1234" && echo "Valid" || echo "Invalid"
```

---

## 📋 Regex Quick Reference

| Pattern | Matches |
|---------|---------|
| `.` | Any character |
| `^` | Start of line |
| `$` | End of line |
| `[abc]` | Any of a, b, c |
| `[^abc]` | Not a, b, c |
| `[a-z]` | Range a to z |
| `*` | 0 or more |
| `+` | 1 or more |
| `?` | 0 or 1 |
| `{n}` | Exactly n |
| `{n,}` | n or more |
| `{n,m}` | n to m |
| `\|` | OR (with -E) |
| `\d` | Digit (with -P) |
| `\w` | Word char (with -P) |
| `\s` | Whitespace (with -P) |

---

## 🏆 Practice Exercises

### Exercise 1: Match Patterns
```bash
# Check if string starts with 'A'
[[ "Apple" =~ ^A ]] && echo "Yes"

# Check if number is exactly 3 digits
[[ "123" =~ ^[0-9]{3}$ ]] && echo "Yes"

# Check for valid hex color
[[ "#FF5733" =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]] && echo "Valid"
```

### Exercise 2: Parse Log File
```bash
# Extract timestamps and levels
grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}" app.log

# Find all unique error types
grep -oE "ERROR: [a-zA-Z ]+" app.log | sort -u
```

### Exercise 3: Data Validation
```bash
# Validate US phone number
validate_phone() {
    [[ $1 =~ ^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$ ]]
}

# Validate credit card (basic)
validate_cc() {
    [[ $1 =~ ^[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}$ ]]
}
```

---

## ✅ Stack 10 Complete!

You learned:
- ✅ What are regular expressions
- ✅ Basic patterns and anchors
- ✅ Character classes and ranges
- ✅ Quantifiers (*, +, ?, {})
- ✅ Alternation and grouping
- ✅ Working with grep (basic & extended)
- ✅ Common real-world patterns
- ✅ Email, phone, IP validation

### Next: Stack 11 → Process Management →