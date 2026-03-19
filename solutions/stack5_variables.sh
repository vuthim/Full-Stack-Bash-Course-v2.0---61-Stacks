#!/bin/bash
# Stack 5 Solution: Variables & Data Types

# String variables
name="John"
age=25
city="NYC"

# Array
fruits=("apple" "banana" "cherry" "date")

# Combining variables
echo "=== String Operations ==="
echo "Name: $name, Age: $age, City: $city"
echo "Full info: ${name} is ${age} years old and lives in ${city}"

# Arithmetic
echo ""
echo "=== Arithmetic ==="
echo "Age + 5: $((age + 5))"
echo "Age * 2: $((age * 2))"
echo "Modulo: $((age % 3))"

# Array operations
echo ""
echo "=== Array Operations ==="
echo "All fruits: ${fruits[@]}"
echo "Count: ${#fruits[@]}"
echo "First: ${fruits[0]}"
echo "Last: ${fruits[-1]}"

# Loop through array
echo ""
echo "=== Loop Through Array ==="
for fruit in "${fruits[@]}"; do
    echo "  - $fruit"
done

# Environment variables
echo ""
echo "=== Environment Variables ==="
echo "HOME: $HOME"
echo "USER: $USER"
echo "PWD: $PWD"
echo "SHELL: $SHELL"

# Read-only variable
declare -r CONSTANT="This cannot be changed"
echo ""
echo "Constant: $CONSTANT"

# Associative array (Bash 4+)
declare -A user_info
user_info["name"]="Alice"
user_info["email"]="alice@example.com"
user_info["phone"]="123-456-7890"

echo ""
echo "=== Associative Array ==="
for key in "${!user_info[@]}"; do
    echo "$key: ${user_info[$key]}"
done