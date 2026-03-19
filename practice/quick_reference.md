# 🐚 BASH QUICK REFERENCE
## All Essential Commands in One Place

---

## 📁 File Operations
```bash
ls -lah                    # List all files detailed
cd /path                   # Change directory
pwd                        # Current directory
mkdir -p dir/subdir        # Create nested directories
cp -r source dest          # Copy recursively
mv old new                 # Move/rename
rm -rf dir                 # Force remove
ln -s target link          # Symbolic link
touch file                 # Create empty file
```

## 📝 Viewing Files
```bash
cat file.txt               # Display file
head -n 20 file.txt        # First 20 lines
tail -n 20 file.txt        # Last 20 lines
tail -f file.txt           # Follow live
less file.txt              # Page through
wc -l file.txt             # Count lines
```

## ✏️ Editing
```bash
nano file.txt              # Easy editor
vim file.txt               # Powerful editor
```

## 🔍 Search & Replace
```bash
grep "pattern" file        # Search
grep -r "pattern" dir/     # Recursive search
sed 's/old/new/g' file     # Replace all
awk '{print $1}' file      # Print column 1
```

## 🔢 Variables
```bash
var="value"                # Create variable
echo $var                  # Use variable
echo ${var}                # Alternative
arr=(one two three)        # Array
echo ${arr[0]}             # First element
echo ${arr[@]}             # All elements
```

## ➕ Arithmetic
```bash
echo $((10 + 5))           # Addition
echo $((10 - 5))           # Subtraction  
echo $((10 * 5))           # Multiplication
echo $((10 / 5))           # Division
echo $((10 % 5))           # Modulus
```

## 🔀 Logic
```bash
if [ $a -eq $b ]; then    # If equal
elif [ $a -gt $b ]; then  # Else if
else                       # Else
fi                         # End

case $var in
    a) echo "A" ;;
    b) echo "B" ;;
    *) echo "Default" ;;
esac
```

## 🔁 Loops
```bash
for i in {1..5}; do
    echo $i
done

while read line; do
    echo "$line"
done < file.txt
```

## ⚙️ Functions
```bash
function myfunc() {
    echo "Arg: $1"
}
myfunc "hello"
```

## 💾 Input/Output
```bash
command > file.txt          # Redirect stdout
command >> file.txt         # Append stdout
command 2> err.txt         # Redirect stderr
command > out.txt 2>&1     # Both
command1 | command2        # Pipe
```

## ⚡ Special Variables
```bash
$0        # Script name
$1-$9     # Arguments
$@        # All arguments
$#        # Argument count
$$        # Current PID
$?        # Last exit status
```

## 📦 Arrays
```bash
arr=(a b c d)
${arr[@]}      # All elements
${#arr[@]}     # Count
${arr[0]}      # First element
arr+=(e)       # Append
unset arr[0]   # Remove
```

## 🎯 Regex
```bash
grep -E "^a.*z$" file      # Start with a, end with z
grep -E "[0-9]+" file       # Numbers
grep -E "[a-zA-Z]" file     # Letters
```

## 👥 Process Control
```bash
ps aux                     # Show processes
kill -9 pid               # Force kill
pkill name                # Kill by name
jobs                      # Background jobs
fg                        # Foreground
bg                        # Background
```

## 🔧 System Info
```bash
uname -a                  # System info
hostname                  # Hostname
whoami                    # Current user
date                      # Current date
uptime                    # System uptime
```

## 📋 Permissions
```bash
chmod +x file             # Make executable
chmod 755 file            # rwx r-x r-x
chown user:group file     # Change owner
```

## ⭐ Pro Tips
```bash
# Use quotes always!
"${var}"                  # Safe with spaces

# Check if file exists
[ -f file ] && echo "yes"

# Default value
${var:-"default"}

# Check exit status
command && echo "OK" || echo "FAIL"

# Command substitution
result=$(command)
```

---

*Quick Reference Card - Print & Keep!*