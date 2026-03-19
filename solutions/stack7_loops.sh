#!/bin/bash
# Stack 7 Solution: Loops

# ================ FOR LOOPS ================
echo "=== For Loop: Array ==="
fruits=("apple" "banana" "cherry" "date")
for fruit in "${fruits[@]}"; do
    echo "I like $fruit"
done

echo ""
echo "=== For Loop: Range ==="
for i in {1..5}; do
    echo "Count: $i"
done

echo ""
echo "=== For Loop: Step ==="
for i in {0..10..2}; do
    echo "Even: $i"
done

echo ""
echo "=== For Loop: Files ==="
for file in lessons/*.md; do
    echo "Lesson: $file"
done

echo ""
echo "=== For Loop: Command Output ==="
for user in $(who | awk '{print $1}' | sort | uniq); do
    echo "Logged in user: $user"
done

# ================ WHILE LOOPS ================
echo ""
echo "=== While Loop ==="
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

echo ""
echo "=== While Loop: Read File ==="
echo "First 3 lines of COURSE_OUTLINE.md:"
while IFS= read -r line; do
    echo "$line"
done < bash-course/COURSE_OUTLINE.md | head -3

# ================ UNTIL LOOPS ================
echo ""
echo "=== Until Loop ==="
num=1
until [ $num -gt 3 ]; do
    echo "Number: $num"
    ((num++))
done

# ================ LOOP CONTROL ================
echo ""
echo "=== Break and Continue ==="
for i in {1..10}; do
    if [ $i -eq 3 ]; then
        continue  # Skip 3
    fi
    if [ $i -eq 7 ]; then
        break     # Stop at 7
    fi
    echo "Number: $i"
done

# ================ PRACTICAL EXAMPLES ================
echo ""
echo "=== Batch Rename Files ==="
# Create test files for renaming
mkdir -p /tmp/test_rename
touch /tmp/test_rename/file{1..3}.txt

# Rename .txt to .bak
for file in /tmp/test_rename/*.txt; do
    mv "$file" "${file%.txt}.bak"
    echo "Renamed: $file -> ${file%.txt}.bak"
done

echo ""
echo "=== Process Files in Directory ==="
total=0
for file in $(find lessons -name "*.md" 2>/dev/null); do
    lines=$(wc -l < "$file")
    total=$((total + lines))
    echo "$file: $lines lines"
done
echo "Total lines: $total"