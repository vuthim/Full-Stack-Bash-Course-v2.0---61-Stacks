# 🌐 STACK 21: ADVANCED CURL & DATA EXTRACTION
## Practical HTTP & CLI Data Tools

> *"Note: For comprehensive REST API development, see Stack 58. This stack covers CLI-focused data extraction."*

---

## 🔰 curl Basics

```bash
# GET request
curl https://example.com

# Save to file
curl -o page.html https://example.com

# Follow redirects
curl -L https://example.com

# POST request
curl -X POST -d "param1=value1&param2=value2" https://api.example.com

# With headers
curl -H "Authorization: Bearer token" https://api.example.com

# JSON POST
curl -X POST -H "Content-Type: application/json" \
    -d '{"name":"John"}' https://api.example.com
```

---

## 📥 Simple Scraping

```bash
# Get page title
curl -s https://example.com | grep -o '<title>.*</title>'

# Extract links
curl -s https://example.com | grep -oE 'href="[^"]*"' | cut -d'"' -f2

# Extract emails
curl -s page.html | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
```

---

## 📡 API Integration

```bash
#!/bin/bash
# fetch_weather.sh

set -euo pipefail

API_KEY="your_api_key"
CITY="New York"

curl -s --get "https://api.weather.com/v3/wx/conditions/current" \
    --data-urlencode "city=${CITY}" \
    --data-urlencode "apikey=${API_KEY}" | \
    jq '.temperature, .conditions'
```

### JSON Parsing with jq
```bash
# Install jq
sudo apt install jq

# Parse JSON
curl -s https://api.example.com/data | jq '.result[0].name'
curl -s https://api.example.com/data | jq -r '.results[] | .name'
```

---

## 🌐 Simple Web Scraper

```bash
#!/bin/bash
# scraper.sh

set -euo pipefail

URL="https://example.com"
OUTPUT_DIR="./scraped"

mkdir -p "$OUTPUT_DIR"

# Get page
content=$(curl -fsSL "$URL")

# Extract data
printf '%s\n' "$content" | grep -oE 'https?://[^"<> ]+' | sort -u > "$OUTPUT_DIR/links.txt"
printf '%s\n' "$content" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' > "$OUTPUT_DIR/emails.txt"

echo "Scraped data saved to $OUTPUT_DIR"
```

### Safer Scraping Habits

- Quote URLs, output paths, and variables
- Use `curl -f` or `curl -fsSL` so HTTP errors fail the script
- Use `printf '%s\n'` instead of bare `echo` when passing arbitrary content through pipelines

---

## ✅ Stack 21 Complete!
