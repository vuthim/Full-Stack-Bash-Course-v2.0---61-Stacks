#!/bin/bash
# Stack 4 Solution: Log Analyzer

LOG_FILE="data/sample_logs/app.log"

# Create sample log if it doesn't exist
mkdir -p data/sample_logs
if [ ! -f "$LOG_FILE" ]; then
    cat > "$LOG_FILE" << 'EOF'
2024-01-15 10:23:45 INFO Starting application
2024-01-15 10:23:46 ERROR Database connection failed
2024-01-15 10:23:47 WARN Retry attempt 1
2024-01-15 10:23:48 ERROR Database connection failed
2024-01-15 10:23:49 INFO Connected to database
2024-01-15 10:23:50 DEBUG Query executed
2024-01-15 10:23:51 ERROR Authentication failed
2024-01-15 10:23:52 INFO User logged in
2024-01-15 10:23:53 ERROR Payment processing failed
2024-01-15 10:23:54 INFO Transaction completed
EOF
fi

echo "=== Log Analysis Results ==="
echo ""

# Count total lines
echo "Total log entries: $(wc -l < "$LOG_FILE")"

# Count by level
echo ""
echo "Breakdown by level:"
grep -o 'INFO\|ERROR\|WARN\|DEBUG' "$LOG_FILE" | sort | uniq -c

# Show only errors
echo ""
echo "=== Errors ==="
grep "ERROR" "$LOG_FILE"

# Extract error messages only
echo ""
echo "=== Error Messages Only ==="
grep "ERROR" "$LOG_FILE" | awk '{print $5, $6, $7}'

# Find unique errors
echo ""
echo "=== Unique Error Types ==="
grep "ERROR" "$LOG_FILE" | awk '{print $5}' | sort | uniq -c | sort -rn