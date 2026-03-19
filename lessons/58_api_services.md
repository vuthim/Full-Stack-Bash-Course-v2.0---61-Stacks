# 🌐 STACK 58: API & WEB SERVICES SCRIPTING
## REST APIs, JSON, and Web Automation

---

## 🔰 What You'll Learn
- REST API consumption
- JSON parsing with jq
- Web scraping
- Authentication methods
- Webhooks and callbacks

---

## 📡 REST API Basics

### GET Request
```bash
#!/bin/bash
# api_get.sh

# Simple GET request
response=$(curl -s "https://api.example.com/data")

# With headers
response=$(curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    "https://api.example.com/users")

# With query parameters
response=$(curl -s "https://api.example.com/search?q=bash&limit=10")

# Save to file
curl -s -o response.json "https://api.example.com/data"

# With timeout
curl -s --max-time 30 "https://api.example.com/data"
```

### POST Request
```bash
#!/bin/bash
# api_post.sh

# POST JSON data
response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"name": "John", "age": 30}' \
    "https://api.example.com/users")

# With file
response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d @data.json \
    "https://api.example.com/users")

# Form data
response=$(curl -s -X POST \
    -d "username=john" \
    -d "password=secret" \
    "https://api.example.com/login")

# File upload
response=$(curl -s -X POST \
    -F "file=@document.pdf" \
    "https://api.example.com/upload")
```

---

## 📊 JSON Processing with jq

### Basic Parsing
```bash
#!/bin/bash
# json_basics.sh

# Sample JSON
json='{"name": "John", "age": 30, "city": "NYC"}'

# Extract fields
echo "$json" | jq '.name'      # "John"
echo "$json" | jq '.age'       # 30
echo "$json" | jq '.city'      # "NYC"

# Extract all keys
echo "$json" | jq 'keys'       # ["age","city","name"]

# Extract all values
echo "$json" | jq '.[]'       # 30, "NYC", "John"
```

### Array Operations
```bash
#!/bin/bash
# json_arrays.sh

json='{"users": [
    {"id": 1, "name": "Alice", "email": "alice@example.com"},
    {"id": 2, "name": "Bob", "email": "bob@example.com"},
    {"id": 3, "name": "Charlie", "email": "charlie@example.com"}
]}'

# Get array length
echo "$json" | jq '.users | length'   # 3

# Get first element
echo "$json" | jq '.users[0]'          # {"id":1,"name":"Alice",...}

# Map/transform
echo "$json" | jq '.users[] | .name'   # Alice, Bob, Charlie

# Filter
echo "$json" | jq '.users[] | select(.id > 1)'

# Extract specific fields
echo "$json" | jq '.users[] | {name: .name, email: .email}'

# Create new array
echo "$json" | jq '[.users[] | select(.id > 1) | .name]'
```

### Complex JSON
```bash
#!/bin/bash
# json_complex.sh

json='{
    "response": {
        "status": "success",
        "data": {
            "users": [
                {"id": 1, "name": "Alice", "address": {"city": "NYC", "zip": "10001"}},
                {"id": 2, "name": "Bob", "address": {"city": "LA", "zip": "90001"}}
            ],
            "total": 100
        }
    }
}'

# Nested access
echo "$json" | jq '.response.status'
echo "$json" | jq '.response.data.total'

# Deep nesting
echo "$json" | jq '.response.data.users[].address.city'

# Object to array
echo "$json" | jq '[.response.data.users[] | {name: .name, city: .address.city}]'
```

---

## 🔐 Authentication

### API Key
```bash
#!/bin/bash
# api_key_auth.sh

# Query parameter
response=$(curl -s "https://api.example.com/data?api_key=$API_KEY")

# Header
response=$(curl -s -H "X-API-Key: $API_KEY" "https://api.example.com/data")

# Custom header
response=$(curl -s -H "Authorization: ApiKey $API_KEY" "https://api.example.com/data")
```

### Bearer Token (OAuth)
```bash
#!/bin/bash
# bearer_token.sh

# Get token
token_response=$(curl -s -X POST "https://auth.example.com/token" \
    -d "grant_type=client_credentials" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET")

token=$(echo "$token_response" | jq -r '.access_token')

# Use token
response=$(curl -s -H "Authorization: Bearer $token" \
    "https://api.example.com/protected")

# Token refresh
refresh_token=$(echo "$token_response" | jq -r '.refresh_token')
new_token_response=$(curl -s -X POST "https://auth.example.com/token" \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$refresh_token")

new_token=$(echo "$new_token_response" | jq -r '.access_token')
```

### Basic Auth
```bash
#!/bin/bash
# basic_auth.sh

# Encode credentials
credentials=$(echo -n "$USER:$PASS" | base64)

# Use basic auth
response=$(curl -s -H "Authorization: Basic $credentials" \
    "https://api.example.com/data")
```

---

## 🏗️ Web Service Client

### API Client Library
```bash
#!/bin/bash
# api_client.sh

# Configuration
BASE_URL="https://api.example.com/v1"
API_KEY="${API_KEY:-}"

# Helper function
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    local curl_cmd="curl -s -X $method"
    
    # Add headers
    curl_cmd+=" -H 'Content-Type: application/json'"
    [ -n "$API_KEY" ] && curl_cmd+=" -H 'Authorization: Bearer $API_KEY'"
    
    # Add data
    [ -n "$data" ] && curl_cmd+=" -d '$data'"
    
    # Add URL
    curl_cmd+=" ${BASE_URL}${endpoint}"
    
    # Execute and return
    eval "$curl_cmd"
}

# GET
api_get() {
    api_request "GET" "$1" ""
}

# POST
api_post() {
    api_request "POST" "$1" "$2"
}

# PUT
api_put() {
    api_request "PUT" "$1" "$2"
}

# DELETE
api_delete() {
    api_request "DELETE" "$1" ""
}

# Usage
echo "Fetching users:"
users=$(api_get "/users")
echo "$users" | jq '.'

echo "Creating user:"
new_user=$(api_post "/users" '{"name": "John", "email": "john@example.com"}')
echo "$new_user" | jq '.'
```

### Paginated API
```bash
#!/bin/bash
# paginated.sh

BASE_URL="https://api.example.com/users"
API_KEY="your_key"
PER_PAGE=100

fetch_all_pages() {
    local page=1
    local all_data="[]"
    
    while true; do
        response=$(curl -s -H "Authorization: Bearer $API_KEY" \
            "${BASE_URL}?page=$page&per_page=$PER_PAGE")
        
        # Check if more pages
        total=$(echo "$response" | jq -r '.total // 0')
        current_page=$(echo "$response" | jq -r '.page')
        data=$(echo "$response" | jq '.data')
        
        if [ "$data" = "null" ] || [ "$current_page" = "null" ]; then
            break
        fi
        
        # Combine data
        all_data=$(echo "$all_data $data" | jq -s 'add')
        
        # Check if last page
        if [ $((current_page * PER_PAGE)) -ge "$total" ]; then
            break
        fi
        
        ((page++))
    done
    
    echo "$all_data"
}

# Usage
all_users=$(fetch_all_pages)
echo "$all_users" | jq '.'
```

---

## 🕷️ Web Scraping

### Extract Links
```bash
#!/bin/bash
# scrape_links.sh

# Get all links from a page
curl -s "https://example.com" | \
    grep -oP '<a\s+(?:[^>]*?\s+)?href=(["\'])(.*?)\1' | \
    cut -d'"' -f2 | \
    grep '^http'

# Using grep -o (GNU grep)
curl -s "https://example.com" | \
    grep -oE 'href="[^"]*"' | \
    sed 's/href="//;s/"//'
```

### Extract Data
```bash
#!/bin/bash
# scrape_data.sh

html='<div class="product">
    <h2 class="title">Product Name</h2>
    <span class="price">$99.99</span>
</div>'

# Extract using grep/sed
echo "$html" | grep -oP '(?<=class="title">)[^<]+'
echo "$html" | grep -oP '(?<=class="price">)[^<]+'

# Or use pup (HTML parser)
# curl -s page.html | pup '.title text{}'
# curl -s page.html | pup '.price text{}'
```

### Form Submission
```bash
#!/bin/bash
# form_submit.sh

# GET form
curl -s "https://search.example.com" \
    -G --data-urlencode "q=search term" \
    --data-urlencode "category=books"

# POST form
curl -s -X POST "https://login.example.com" \
    -d "username=user" \
    -d "password=pass" \
    -c cookies.txt \
    -L  # Follow redirects
```

---

## 🔄 Webhooks

### Create Webhook
```bash
#!/bin/bash
# webhook_handler.sh

# Simple webhook endpoint using netcat
listen_webhook() {
    local port="${1:-8080}"
    echo "Listening on port $port..."
    
    while true; do
        # Read incoming request
        request=$(nc -l -p "$port" | head -20)
        
        # Parse payload
        payload=$(echo "$request" | sed -n '/^{/,/^}$/p')
        
        # Process webhook
        event_type=$(echo "$request" | grep -i "x-github-event:" | cut -d: -f2 | tr -d ' \r')
        
        echo "Event: $event_type"
        
        case "$event_type" in
            push)
                echo "$payload" | jq '.commits[].message'
                # Run deployment
                ;;
            pull_request)
                pr_action=$(echo "$payload" | jq -r '.action')
                echo "PR action: $pr_action"
                ;;
        esac
    done
}

# Usage
# listen_webhook 8080
```

### Send Webhook
```bash
#!/bin/bash
# send_webhook.sh

# Send webhook notification
send_webhook() {
    local url="$1"
    local event="$2"
    local payload="$3"
    
    curl -s -X POST "$url" \
        -H "Content-Type: application/json" \
        -H "X-Webhook-Event: $event" \
        -d "$payload"
}

# Usage
send_webhook "https://hooks.example.com/webhook" "deploy" \
    '{"service": "api", "status": "deployed", "version": "1.2.3"}'
```

---

## 🌊 Async Operations

### Parallel API Calls
```bash
#!/bin/bash
# parallel_api.sh

# Fetch multiple APIs in parallel
urls=(
    "https://api1.example.com/data"
    "https://api2.example.com/data"
    "https://api3.example.com/data"
)

# Using xargs for parallelism
echo "${urls[@]}" | xargs -P 3 -I {} curl -s {} | jq -s '.'

# Or with background processes
for url in "${urls[@]}"; do
    curl -s "$url" &
done
wait

echo "All requests complete"
```

---

## 🏆 Practice Exercises

### Exercise 1: Weather API
Create a weather app using a free weather API

### Exercise 2: GitHub API
Build a GitHub repository manager

### Exercise 3: Web Scraper
Scrape a news site and extract headlines

---

## ✅ Stack 58 Complete!

You learned:
- ✅ REST API basics (GET/POST/PUT/DELETE)
- ✅ JSON parsing with jq
- ✅ Array and object operations
- ✅ Authentication (API key, Bearer, Basic)
- ✅ Building API client libraries
- ✅ Pagination handling
- ✅ Web scraping
- ✅ Webhooks

### Next: Stack 59 - Multi-Cluster Orchestration →

---

*End of Stack 58*