# 🌐 STACK 21: ADVANCED CURL & DATA EXTRACTION
## Practical HTTP & CLI Data Tools

> *"Note: For comprehensive REST API development, see Stack 58. This stack covers CLI-focused data extraction."*

**What is Web Scraping?** Think of it as a robot reading web pages for you. Instead of manually opening a browser and copying data, your script does it automatically.

**⚠️ Ethics & Legal Warning:** Always respect:
- `robots.txt` files (they tell you what's OK to scrape)
- Website terms of service
- Rate limits (don't hammer servers)
- Copyright and data ownership laws

---

## 🔰 Why curl & Web Scraping?

- ✅ **Automate API interactions** - Test APIs without a GUI tool
- ✅ **Extract data from websites** - Monitor prices, news, weather
- ✅ **Download files in bulk** - Automate repetitive downloads
- ✅ **Monitor web services** - Check if sites are up, track changes
- ✅ **Build dashboards from web data** - Pull data into your own tools

### curl Analogy for Beginners
`curl` is like a programmable web browser. Instead of clicking and scrolling, you tell it exactly what to fetch and what to do with it.

---

## ⚙️ curl Essentials

### Basic Requests
```bash
# GET request
curl https://example.com
curl -s https://example.com           # Silent (no progress)
curl -v https://example.com           # Verbose (show headers)

# Save to file
curl -o page.html https://example.com        # Save as page.html
curl -O https://example.com/file.zip         # Save as filename

# Follow redirects
curl -L https://example.com

# Download in background
curl -O https://example.com/largefile.zip &
```

### HTTP Methods
```bash
# POST request (form data)
curl -X POST -d "param1=value1&param2=value2" https://api.example.com

# POST with JSON
curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"John","age":30}' \
    https://api.example.com

# PUT request
curl -X PUT -d "updated=data" https://api.example.com/resource/1

# DELETE request
curl -X DELETE https://api.example.com/resource/1
```

### Headers and Authentication
```bash
# Custom headers
curl -H "Authorization: Bearer token123" https://api.example.com
curl -H "Accept: application/json" https://api.example.com
curl -H "User-Agent: MyScript/1.0" https://api.example.com

# Basic authentication
curl -u username:password https://api.example.com

# Bearer token
curl -H "Authorization: Bearer YOUR_TOKEN" https://api.example.com

# API key as header
curl -H "X-API-Key: YOUR_KEY" https://api.example.com
```

### Advanced Options
```bash
# Timeout
curl --max-time 30 https://example.com
curl --connect-timeout 10 https://example.com

# Retry on failure
curl --retry 3 --retry-delay 5 https://example.com

# Resume download
curl -C - -O https://example.com/largefile.zip

# Rate limit
curl --limit-rate 100K https://example.com

# Ignore SSL errors (development only!)
curl -k https://self-signed.example.com
curl --insecure https://self-signed.example.com
```

---

## 📥 Data Extraction Techniques

### Extract Using grep/sed
```bash
# Get page title
curl -s https://example.com | grep -o '<title>.*</title>' | sed 's/<title>//;s/<\/title>//'

# Extract all links
curl -s https://example.com | grep -oE 'href="[^"]*"' | cut -d'"' -f2

# Extract all emails
curl -s page.html | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

# Extract phone numbers
curl -s page.html | grep -oE '\+?[0-9]{1,4}?[-. ]?\(?[0-9]{1,3}?\)?[-. ]?[0-9]{1,4}[-. ]?[0-9]{1,9}'

# Extract IP addresses
curl -s https://api.ipify.org | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
```

### HTML Parsing with pup (JSON output)
```bash
# Install pup
go install github.com/ericchiang/pup@latest

# Extract elements
curl -s https://example.com | pup 'a json'
curl -s https://example.com | pup 'div.content json{}'
curl -s https://example.com | pup 'img attr{src}'
```

### HTML Parsing withlynx (text only)
```bash
# Convert HTML to text
curl -s https://example.com | lynx -dump -stdin

# Useful for extracting text content
curl -s https://example.com | lynx -dump -stdin | grep -A2 "Section Title"
```

---

## 📡 API Integration

### Working with JSON
```bash
# Install jq
sudo apt install jq

# Parse JSON
curl -s https://api.example.com/data | jq '.result'
curl -s https://api.example.com/data | jq '.result[0].name'
curl -s https://api.example.com/data | jq -r '.results[] | .name'

# Filter JSON
curl -s https://api.example.com/data | jq '.results[] | select(.active == true)'

# Map fields
curl -s https://api.example.com/data | jq '[.results[] | {name: .name, id: .id}]'

# Transform to CSV
curl -s https://api.example.com/data | jq -r '.results[] | [.name, .email] | @csv'

# Pretty print
curl -s https://api.example.com/data | jq .
```

### Real-World API Examples

#### Weather API
```bash
#!/bin/bash
# weather.sh

API_KEY="your_api_key"
CITY="${1:-New York}"

response=$(curl -s --get "https://api.openweathermap.org/data/2.5/weather" \
    --data-urlencode "q=${CITY}" \
    --data-urlencode "appid=${API_KEY}" \
    --data-urlencode "units=metric")

temp=$(echo "$response" | jq -r '.main.temp')
humidity=$(echo "$response" | jq -r '.main.humidity')
description=$(echo "$response" | jq -r '.weather[0].description')

echo "Weather in $CITY:"
echo "  Temperature: ${temp}C"
echo "  Humidity: ${humidity}%"
echo "  Conditions: $description"
```

#### GitHub API
```bash
#!/bin/bash
# github_stats.sh

REPO="${1:-torvalds/linux}"

# Get repo info
curl -s "https://api.github.com/repos/${REPO}" | jq '{
    name: .full_name,
    stars: .stargazers_count,
    forks: .forks_count,
    issues: .open_issues_count,
    language: .language
}'

# List recent releases
curl -s "https://api.github.com/repos/${REPO}/releases?per_page=5" | \
    jq -r '.[] | "\(.tag_name) - \(.published_at)"'
```

#### COVID-19 Data
```bash
#!/bin/bash
# covid_stats.sh

COUNTRY="${1:-USA}"

curl -s "https://api.covid19api.com/live/country/${COUNTRY}" | \
    jq '.[-1] | {
        country: .Country,
        confirmed: .Confirmed,
        deaths: .Deaths,
        recovered: .Recovered,
        date: .Date
    }'
```

---

## 🕷️ Web Scraping Scripts

### Basic Page Scraper
```bash
#!/bin/bash
# scraper.sh

set -euo pipefail

URL="${1:-https://example.com}"
OUTPUT_DIR="./scraped_data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR"

log() { echo "[$(date)] $*"; }

log "Fetching $URL..."

# Fetch page with error handling
content=$(curl -fsSL "$URL") || {
    log "Failed to fetch $URL"
    exit 1
}

# Extract various data
echo "$content" | grep -oE 'href="[^"]*"' | cut -d'"' -f2 > "$OUTPUT_DIR/${TIMESTAMP}_links.txt"
echo "$content" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' > "$OUTPUT_DIR/${TIMESTAMP}_emails.txt"

# Extract images
echo "$content" | grep -oE '<img[^>]+src="[^"]*"' | grep -oE 'src="[^"]*"' | cut -d'"' -f2 > "$OUTPUT_DIR/${TIMESTAMP}_images.txt"

log "Scraping complete. Files saved to $OUTPUT_DIR"

# Summary
echo "Links found: $(wc -l < "$OUTPUT_DIR/${TIMESTAMP}_links.txt")"
echo "Emails found: $(wc -l < "$OUTPUT_DIR/${TIMESTAMP}_emails.txt")"
echo "Images found: $(wc -l < "$OUTPUT_DIR/${TIMESTAMP}_images.txt")"
```

### Product Price Monitor
```bash
#!/bin/bash
# price_monitor.sh

set -euo pipefail

PRODUCT_URL="$1"
TARGET_PRICE="${2:-100}"

if [ -z "$PRODUCT_URL" ]; then
    echo "Usage: $0 <url> <target_price>"
    exit 1
fi

# Fetch page (adjust selector based on website)
price=$(curl -s "$PRODUCT_URL" | \
    grep -oE '\$[0-9,]+\.[0-9]{2}' | \
    head -1 | tr -d '$,')

echo "Current price: $$price"
echo "Target price: $$TARGET_PRICE"

# Compare (using bc for floating point)
if (( $(echo "$price < $TARGET_PRICE" | bc -l) )); then
    echo "Price is below target! Consider buying now."
    # Send notification
    echo "Price alert: $PRODUCT_URL is now \$$price" | mail -s "Price Alert" you@example.com
else
    echo "Price is above target. Waiting..."
fi
```

### Link Checker
```bash
#!/bin/bash
# link_checker.sh

set -euo pipefail

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Usage: $0 <file_with_urls>"
    exit 1
fi

echo "Checking links in $FILE..."

while read -r url; do
    [ -z "$url" ] && continue
    
    status=$(curl -o /dev/null -s -w "%{http_code}" -L --max-time 10 "$url")
    
    if [ "$status" -eq 200 ]; then
        echo "✅ $url"
    elif [ "$status" -eq 301 ] || [ "$status" -eq 302 ]; then
        echo "➡️  $url (redirect)"
    elif [ "$status" -eq 404 ]; then
        echo "❌ 404: $url"
    else
        echo "⚠️  $status: $url"
    fi
done < "$FILE"
```

### Batch Download
```bash
#!/bin/bash
# download_images.sh

set -euo pipefail

PAGE_URL="$1"
OUTPUT_DIR="${2:-./downloads}"

mkdir -p "$OUTPUT_DIR"

# Extract image URLs (adjust based on site)
images=$(curl -s "$PAGE_URL" | grep -oE 'https?://[^"]+\.(jpg|jpeg|png|gif)' | sort -u)

echo "Found $(echo "$images" | wc -l) images"

count=0
while read -r img_url; do
    [ -z "$img_url" ] && continue
    
    filename=$(basename "$img_url")
    echo "Downloading: $filename"
    
    curl -s -L -o "$OUTPUT_DIR/$filename" "$img_url" &
    
    ((count++))
    
    # Limit parallel downloads
    if [ $((count % 5)) -eq 0 ]; then
        wait
    fi
done <<< "$images"

wait
echo "Downloaded $count images to $OUTPUT_DIR"
```

---

## ⚠️ Best Practices & Ethics

### Always
```bash
# ✅ Check robots.txt first
curl -s https://example.com/robots.txt

# ✅ Respect rate limits
sleep 1  # Wait between requests

# ✅ Set proper User-Agent
curl -H "User-Agent: MyBot/1.0 (contact@example.com)" https://example.com

# ✅ Use `-f` for HTTP errors
curl -fsSL https://example.com

# ✅ Handle timeouts
curl --max-time 30 https://example.com
```

### Never
```bash
# ❌ Scrape without permission
# ❌ Bypass authentication
# ❌ Overwhelm servers with requests
# ❌ Ignore robots.txt for public sites
# ❌ Store sensitive data improperly
```

### Rate Limiting Example
```bash
#!/bin/bash
# Respectful scraper with rate limiting

RATE_LIMIT=2  # seconds between requests

while read -r url; do
    curl -s -L "$url"
    echo "Waiting ${RATE_LIMIT}s..."
    sleep "$RATE_LIMIT"
done < urls.txt
```

---

## 🔍 Troubleshooting

### Common curl Issues

#### SSL Certificate Errors
```bash
# Check certificate
curl --verbose https://example.com

# Update certificates
sudo update-ca-certificates

# Use insecure (temp fix, not for production)
curl -k https://self-signed.example.com
```

#### Connection Timeout
```bash
# Increase timeout
curl --max-time 60 --connect-timeout 30 https://example.com

# Check network
ping example.com
traceroute example.com
```

#### HTTP 403 Forbidden
```bash
# Add User-Agent
curl -H "User-Agent: Mozilla/5.0" https://example.com

# Add referer
curl -H "Referer: https://google.com" https://example.com

# Check cookies (some sites require them)
curl -c cookies.txt -b cookies.txt https://example.com
```

#### JSON Parse Errors
```bash
# Check response is valid JSON
curl -s https://api.example.com | jq .

# Handle empty responses
response=$(curl -s https://api.example.com)
if [ -n "$response" ]; then
    echo "$response" | jq .
fi
```

### Debugging Tips
```bash
# Show all headers
curl -v https://example.com

# Show only response headers
curl -I https://example.com

# Show request headers
curl -v -I https://example.com 2>&1 | grep -E "^(>| |<)"

# Save headers to file
curl -D headers.txt -o page.html https://example.com
```

---

## 📝 Exercises

### Exercise 1: Weather CLI Tool
Create a script that:
1. Accepts city name as argument
2. Fetches weather from OpenWeatherMap API
3. Displays temperature, humidity, and conditions

### Exercise 2: Link Checker
Create a script that:
1. Reads URLs from a file
2. Checks each URL's HTTP status
3. Reports broken links (404)

### Exercise 3: Price Monitor
Create a script that:
1. Monitors a product URL
2. Extracts current price
3. Sends email if price drops below target

---

## ✅ Stack 21 Complete!

You learned:
- ✅ curl essentials and advanced options
- ✅ Data extraction techniques (grep, sed, jq)
- ✅ API integration with JSON parsing
- ✅ Web scraping scripts (scraper, monitor, checker)
- ✅ Best practices and ethical scraping
- ✅ Troubleshooting common issues

### Next: Stack 22 - Testing Bash Scripts →

---

*End of Stack 21*
