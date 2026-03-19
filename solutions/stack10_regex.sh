#!/bin/bash
# Stack 10 Solution: Regular Expressions

# ================ BASIC REGEX METACHARACTERS ================

echo "=== Regex Metacharacters ==="

# Create test data
echo -e "test123\nhello\ntest456\nworld789" > /tmp/test_data.txt

# Match any character (.)
echo "Match 3 chars starting with 't':"
grep -E 't..' /tmp/test_data.txt

# Match start of line (^)
echo ""
echo "Lines starting with 'test':"
grep -E '^test' /tmp/test_data.txt

# Match end of line ($)
echo ""
echo "Lines ending with digit:"
grep -E '[0-9]$' /tmp/test_data.txt

# Match zero or more (*)
echo ""
echo "Matches for 't*':"
echo "ttttest" | grep -E 't*est'

# Match one or more (+)
echo ""
echo "Lines with one or more digits:"
grep -E '[0-9]+' /tmp/test_data.txt

# Match optional (?)
echo ""
echo "Color/gr with optional u:"
echo -e "color\ncolour\ncolr" | grep -E 'colou?r'

# ================ CHARACTER CLASSES ================

echo ""
echo "=== Character Classes ==="

# Digits
echo "Digits: $(echo 'abc123def' | grep -oE '[0-9]+')"

# Words
echo "Words: $(echo 'hello world test 123' | grep -oE '[a-zA-Z]+')"

# Whitespace
echo "Test string:" 
echo "hello  world" | sed 's/  / /g'

# Negation
echo "Non-digits: $(echo 'a1b2c3' | grep -oE '[^0-9]+')"

# ================ QUANTIFIERS ================

echo ""
echo "=== Quantifiers ==="

echo -e "a\nab\nabc\nabcd" | grep -E '^a{2,3}$'

# ================ GROUPS AND ALTERNATIVES ================

echo ""
echo "=== Groups and Alternation ==="

echo -e "cat\ndog\nbat\nrat" | grep -E '(c|d)at'

# ================ PRACTICAL EXAMPLES ================

echo ""
echo "=== Practical Examples ==="

# Validate email
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Valid: $email"
    else
        echo "Invalid: $email"
    fi
}

validate_email "user@example.com"
validate_email "invalid-email"

# Extract IP addresses
echo ""
echo "Extracting IPs:"
echo "Server 192.168.1.1 connected to 10.0.0.1" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'

# Extract dates in various formats
echo ""
echo "Extracting dates:"
echo "2024-01-15, 01/15/2024, 15-01-2024" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}/[0-9]{2}/[0-9]{4}'

# Extract URLs
echo ""
echo "Extracting URLs:"
echo "Visit https://example.com or http://test.org for more info" | grep -oE 'https?://[^ ]+'

# Extract phone numbers
echo ""
echo "Extracting phones:"
echo "Call 123-456-7890 or (555) 123-4567" | grep -oE '[0-9]{3}[- ]?[0-9]{3}[- ]?[0-9]{4}'

# Extract hashtags
echo ""
echo "Extracting hashtags:"
echo "Learning #Bash #Programming #100DaysOfCode" | grep -oE '#[a-zA-Z][a-zA-Z0-9_]*'

# ================ SED WITH REGEX ================

echo ""
echo "=== Sed with Regex ==="

# Replace all digits with X
echo "abc123def456" | sed 's/[0-9]/X/g'

# Replace words
echo "Hello World Bash" | sed 's/[A-Z][a-z]*/"&"/g'

# Extract between delimiters
echo "name:value:data" | sed 's/.*name:\([^:]*\).*/\1/'

# ================ BASH [[ =~ ]] ================

echo ""
echo "=== Bash [[ =~ ]] Operator ==="

text="My email is user@example.com"

if [[ $text =~ [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
    echo "Email found in text!"
fi

# Capture groups
if [[ $text =~ ([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}) ]]; then
    echo "Local part: ${BASH_REMATCH[1]}"
    echo "Domain: ${BASH_REMATCH[2]}"
fi