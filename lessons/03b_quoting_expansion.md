# 🛡️ STACK 3B: QUOTING & EXPANSION
## Safe File Handling & The "Space" Problem

**The Problem:** In Bash, spaces are "delimiters." They tell Bash where one word ends and the next begins. This is great for commands, but TERRIBLE for filenames like `My Resume.docx`. Without proper quoting, Bash thinks you're talking about two files: `My` and `Resume.docx`.

**The Solution:** Master the art of Quoting and Expansion. This is the difference between a script that works on your machine and a script that safely handles real-world data without crashing!

---

## 🔰 The Golden Rule of Bash
> **"If it's a variable, wrap it in double quotes!"**

### Analogy: The Shipping Container
```
Variable WITHOUT quotes:  Loose items in a truck. If the truck hits a bump (a space), items fly everywhere.
Variable WITH quotes:     Items inside a locked shipping container. No matter how many bumps, the items stay together.
```

---

## 📋 The Three Types of Quotes

| Quote Type | Character | What it Does |
|------------|-----------|--------------|
| **Double Quotes** | `"` | **Protect** spaces but allow variables to expand. |
| **Single Quotes** | `'` | **Literal** text. Stops all expansion (variables stay as `$VAR`). |
| **Backticks** | `` ` `` | **Old Command Substitution**. Replaced by `$(...)`. |

### Examples
```bash
NAME="John Doe"

echo "Hello $NAME"   # Output: Hello John Doe (Expanding variable)
echo 'Hello $NAME'   # Output: Hello $NAME (Literal text)
```

---

## 🚀 Common Expansion Pitfalls

### 1. The "ls in a loop" mistake
**NEVER** use `$(ls)` to loop over files. If a filename has a space, your script will break.

```bash
# ❌ WRONG (Breaks on spaces)
for file in $(ls *.txt); do
    rm $file
done

# ✅ CORRECT (Works on everything)
for file in *.txt; do
    rm "$file"
done
```

### 2. The "$@" vs "$*" confusion
When passing arguments to another script or function:
- **`"$@"` (Use this!):** Keeps every argument as a separate "container."
- **`"$*"` (Avoid this!):** Smashes all arguments into one giant string.

---

## 🔧 Pro Techniques for Safe Handling

### Nullglob: The "Empty Directory" Fix
By default, if no `.jpg` files exist, `*.jpg` stays as the literal string `*.jpg`. This causes errors in loops.

```bash
shopt -s nullglob  # If no files match, the loop just doesn't run!
for file in *.jpg; do
    echo "Processing $file"
done
shopt -u nullglob  # Turn it off when done
```

---

## 🎓 Final Project: The Safe File Processor

Now that you've mastered quoting, let's look at how a professional scripter handles a directory full of messy filenames (spaces, dots, and weird characters). We'll examine a "Safe Processor" — a script that performs operations on files while ensuring no filename is ever split incorrectly.

### What the Safe File Processor Does:
1. **Uses Globs, not ls** to ensure spaces in filenames are handled natively by the shell.
2. **Implements Defensive Checks** to verify a file actually exists before processing.
3. **Uses Double-Quoting** on every variable to prevent word-splitting.
4. **Handles "Empty Matches"** using `nullglob` so the script doesn't error out in empty folders.
5. **Passes Arguments Safely** to sub-functions using `"$@"` to preserve the original structure.

### Key Snippet: The Safe Loop Pattern
This is the "standard" way to write a file loop in production-grade Bash.

```bash
process_logs() {
    # Enable nullglob so we don't loop over the literal string "*.log"
    shopt -s nullglob
    
    for log_file in *.log; do
        # Defensive check: Ensure it's a real file (not a directory)
        if [[ -f "$log_file" ]]; then
            echo "Successfully locked onto: $log_file"
            # Always quote the variable here!
            tail -n 10 "$log_file" >> "combined_report.txt"
        fi
    done
    
    shopt -u nullglob
}
```

**Pro Tip:** 90% of Bash bugs are caused by missing quotes. If you master this stack, you are already better than 90% of casual scripters!

---

## ✅ Stack 3B Complete!

Congratulations! You've mastered the "Invisible Shield" of Bash! You can now:
- ✅ **Handle filenames with spaces** without breaking your scripts
- ✅ **Use Double vs Single quotes** for the right situations
- ✅ **Avoid command substitution loops** (`ls`) in favor of globs
- ✅ **Manage script arguments** safely using `"$@"`
- ✅ **Configure shell options** like `nullglob` for robust automation
- ✅ **Write defensive code** that doesn't crash on empty directories

### Navigation
- **Previous:** [Stack 3B → Quoting & Expansion](03b_quoting_expansion.md)
- **Next:** [Stack 4 - Text Processing Tools](04_text_processing.md)

---

*End of Stack 3B*
