# 📊 STACK 64: LOG AGGREGATION
## ELK Stack & Loki for Centralized Logging

**What is Log Aggregation?** Imagine you have 50 servers, each generating thousands of log lines per minute. Reading them one by one is impossible. Log aggregation collects ALL logs into one place, where you can search, analyze, and visualize them together. It's like having a single dashboard for your entire infrastructure!

**Why This Matters?** When something breaks in production, you need to find the issue FAST. Without aggregation, you're SSH-ing into servers and reading individual log files. With it, you search one dashboard and find the problem in seconds.

---

## 🔰 Why Log Aggregation?

| Benefit | What It Means | Real-World Impact |
|---------|--------------|-------------------|
| **Centralize logs** | All logs in one searchable place | No more SSH-ing into 20 servers |
| **Search and analyze** | Find patterns across all logs instantly | Debug issues that span multiple services |
| **Build dashboards** | Visualize log trends and anomalies | See problems before users report them |
| **Alert on patterns** | Auto-notify when specific log patterns appear | Catch errors in real-time |
| **Troubleshoot production** | Full context when things go wrong | Reduce MTTR (Mean Time To Recovery) |

### The Log Aggregation Architecture
```
Servers/Apps → Collect/Ship → Store/Index → Search/Visualize
     ↓              ↓             ↓              ↓
  (logs)        (Beats/       (Elastic      (Kibana/
                Promtail)      /Loki)        Grafana)
```

---

## 🏗️ ELK Stack Architecture

```
┌─────────┐    ┌─────────┐    ┌─────────┐
│  Beats  │───▶│ Elastic │◀───│ Kibana  │
│(Shipper)│    │search   │    │ (UI)    │
└─────────┘    └────┬────┘    └─────────┘
                    │
               ┌────▼────┐
               │ Logstash│
               │(Parser) │
               └─────────┘
```

---

## ⚙️ Filebeat (Lightweight Shipper)

### Installation
```bash
# Ubuntu/Debian
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.x-amd64.deb
sudo dpkg -i filebeat-8.x-amd64.deb
```

### Basic Configuration
```yaml
# /etc/filebeat/filebeat.yml

filebeat.inputs:
- type: log
  paths:
    - /var/log/syslog
    - /var/log/auth.log
    - /var/log/nginx/*.log
  
  fields:
    service: system
    environment: production

output.logstash:
  hosts: ["localhost:5044"]

setup.kibana:
  host: "localhost:5601"
```

### Start Filebeat
```bash
sudo systemctl enable filebeat
sudo systemctl start filebeat

# Test configuration
filebeat test config

# View status
filebeat setup --dashboards
```

### Custom Log Parsing
```yaml
filebeat.inputs:
- type: log
  paths:
    - /var/log/myapp/*.log
  
  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
  
  fields:
    service: myapp
```

---

## 🔄 Logstash (Parser & Processor)

### Installation
```bash
# Install Java first
sudo apt install openjdk-11-jdk

# Add repo and install
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | \
    sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt update
sudo apt install logstash
```

### Pipeline Configuration
```ruby
# /etc/logstash/conf.d/01-input.conf
input {
  beats {
    port => 5044
  }
}

# /etc/logstash/conf.d/02-filter.conf
filter {
  if [fields][service] == "nginx" {
    grok {
      match => { "message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} %{NUMBER:bytes:int} "%{DATA:referrer}" "%{DATA:agent}"' }
    }
    
    date {
      match => [ "timestamp", "dd/MMM/YYYY:HH:mm:ss Z" ]
      target => "@timestamp"
    }
  }
  
  # Add geoip for IPs
  if [clientip] {
    geoip {
      source => "clientip"
    }
  }
}

# /etc/logstash/conf.d/03-output.conf
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "logstash-%{+YYYY.MM.dd}"
  }
}
```

### Start Logstash
```bash
sudo systemctl enable logstash
sudo systemctl start logstash

# Test pipeline
/etc/logstash/bin/logstash --config.test_and_exit -f /etc/logstash/conf.d/
```

---

## 🔍 Kibana (Visualization)

### Installation
```bash
sudo apt install kibana
```

### Configuration
```yaml
# /etc/kibana/kibana.yml

server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
```

### Start Kibana
```bash
sudo systemctl enable kibana
sudo systemctl start kibana

# Access UI
# http://localhost:5601
```

### Create Index Pattern
```bash
# Via API
curl -X POST "localhost:5601/api/saved_objects/index-pattern" \
  -H "Content-Type: application/json" \
  -H "kbn-xsrf: true" \
  -d '{"attributes":{"title":"logstash-*","timeFieldName":"@timestamp"}}'
```

---

## 📦 Alternative: Loki ( Grafana Labs)

### Why Loki?
- Simpler than ELK
- Built by Grafana Labs
- Lower resource usage
- Integrates with Prometheus

### Installation
```bash
# Download Loki
curl -fSL https://github.com/grafana/loki/releases/download/v2.x/loki-linux-amd64.zip -o loki.zip
unzip loki.zip
sudo mv loki-linux-amd64 /usr/local/bin/loki

# Create config
sudo mkdir -p /etc/loki
sudo nano /etc/loki/local-config.yaml
```

### Loki Configuration
```yaml
# /etc/loki/local-config.yaml

auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  path_prefix: /var/lib/loki
  storage:
    filesystem:
      chunks_directory: /var/lib/loki/chunks
      rules_directory: /var/lib/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-05-15
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h
```

### Promtail (Loki Agent)
```yaml
# /etc/promtail/config.yml

server:
  http_listen_port: 9080
  grpc_listen_port: 9081

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: syslog
      __path__: /var/log/syslog
  - targets:
      - localhost
    labels:
      job: auth
      __path__: /var/log/auth.log
```

### Start Services
```bash
# Start Loki
sudo systemctl enable loki
sudo systemctl start loki

# Start Promtail
sudo systemctl enable promtail
sudo systemctl start promtail
```

---

## 📝 Bash Scripts for Log Management

### Ship Custom Logs to ELK
```bash
#!/bin/bash
# ship_logs.sh

set -euo pipefail

LOG_FILE="$1"
INDEX_NAME="${2:-custom-logs}"

if [ -z "$LOG_FILE" ]; then
    echo "Usage: $0 <log_file> [index_name]"
    exit 1
fi

# Configure filebeat dynamically
cat > /tmp/filebeat-custom.yml << EOF
filebeat.inputs:
- type: log
  paths:
    - $LOG_FILE
  fields:
    index: $INDEX_NAME

output.elasticsearch:
  hosts: ["localhost:9200"]
  index: "$INDEX_NAME-%{+yyyy.MM.dd}"

setup.template.name: "$INDEX_NAME"
setup.template.pattern: "$INDEX_NAME-*"
EOF

# Run filebeat with custom config
filebeat -c /tmp/filebeat-custom.yml
```

### Parse Application Logs
```bash
#!/bin/bash
# parse_app_logs.sh

# Add to logstash pipeline
cat >> /etc/logstash/conf.d/app-logs.conf << 'EOF'

filter {
  if [fields][service] == "myapp" {
    grok {
      match => { 
        "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{DATA:class} - %{GREEDYDATA:message}" 
      }
    }
    
    # Remove raw message if parsed
    if [message] {
      mutate {
        remove_field => ["message"]
      }
    }
    
    # Add computed field
    ruby {
      code => "event.set('indexed_at', Time.now.utc)"
    }
  }
}
EOF

# Reload logstash
sudo systemctl reload logstash
```

### Alert on Log Patterns
```bash
#!/bin/bash
# alert_errors.sh

ES_HOST="localhost:9200"
INDEX="logstash-$(date +%Y.%m.%d)"

# Check for errors in last hour
ERRORS=$(curl -s -X GET "$ES_HOST/$INDEX/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "bool": {
      "must": [
        { "match": { "level": "ERROR" }}
      ],
      "filter": {
        "range": {
          "@timestamp": { "gte": "now-1h" }
        }
      }
    }
  },
  "size": 100
}' | jq '.hits.total.value')

if [ "$ERRORS" -gt 0 ]; then
    echo "🚨 ALERT: $ERRORS errors in last hour"
    # Send alert (email, Slack, etc.)
    echo "Alert: $ERRORS errors found" | mail -s "Log Alert" admin@example.com
fi
```

---

## 📊 Query Examples

### Kibana / Dev Tools
```json
// Find all errors in last 24 hours
{
  "query": {
    "bool": {
      "must": [
        { "match": { "level": "ERROR" }}
      ],
      "filter": {
        "range": {
          "@timestamp": { "gte": "now-24h" }
        }
      }
    }
  }
}

// Find specific user activity
{
  "query": {
    "bool": {
      "must": [
        { "match": { "user.id": "12345" }}
      ]
    }
  },
  "sort": [{ "@timestamp": "desc" }],
  "size": 50
}
```

### Loki (LogQL)
```logql
# Find errors
{job="syslog"} |= "ERROR"

# Find with regex
{service="myapp"} |~ "failed.*connection"

# Count by level
count_over_time({job="myapp"}[5m])

# Metrics query
sum(rate({job="myapp"} |= "ERROR"[5m])) by (level)
```

---

## 🎓 Final Project: The Bash Log Shipper & Alerter

Now that you've mastered centralized logging, let's see how a professional SRE might build a lightweight alternative to heavy agents. We'll examine the "Log Shipper" — a script that monitors local logs for critical errors and "ships" them to a central server (like Elasticsearch or Loki) while sending instant alerts to your team.

### What the Bash Log Shipper & Alerter Does:
1. **Monitors Log Files in Real-Time** using `tail -F` to watch for new entries.
2. **Filters for "High-Priority" Patterns** (e.g., "FATAL", "CRITICAL", "Out of Memory").
3. **Deduplicates Alerts** to ensure you don't get 1,000 notifications for the same repeating error.
4. **Ships Data to Central APIs** using `curl` to POST logs directly into Elasticsearch or Loki.
5. **Sends Instant Notifications** via Slack, Discord, or Email when a crash is detected.
6. **Rotates Local Archive Logs** to ensure the shipper itself doesn't consume all your disk space.

### Key Snippet: Real-Time Error Alerting
The shipper uses a "continuous loop" pattern to watch a log file and take action the moment a specific word appears.

```bash
#!/bin/bash
# watch_and_alert.sh

log_file="/var/log/myapp/production.log"

# tail -F: keep reading even if the file is rotated
tail -n 0 -F "$log_file" | while read -r line; do
    # Check if the line contains 'ERROR'
    if echo "$line" | grep -q "ERROR"; then
        echo "🚨 Critical Error Detected: $line"
        
        # Ship to central logging (Elasticsearch)
        curl -s -X POST "http://elk-server:9200/alerts/_doc" \
            -H "Content-Type: application/json" \
            -d "{\"timestamp\": \"$(date)\", \"message\": \"$line\"}"
            
        # Send to Slack
        # curl -X POST -d "payload={\"text\": \"Error: $line\"}" $SLACK_WEBHOOK
    fi
done
```

### Key Snippet: Shipping Logs to Loki (LogQL)
Loki allows you to send logs via a simple HTTP API. Our script formats the data exactly how Loki wants it.

```bash
ship_to_loki() {
    local message=$1
    local timestamp=$(date +%s%N) # Nanoseconds for Loki
    
    # Loki expects a specific JSON structure with labels
    local payload="{\"streams\": [{ \"stream\": { \"job\": \"bash-shipper\" }, \"values\": [ [ \"$timestamp\", \"$message\" ] ] }]}"
    
    curl -s -X POST "http://loki-server:3100/loki/api/v1/push" \
        -H "Content-Type: application/json" \
        -d "$payload"
}
```

**Pro Tip:** While tools like Filebeat are great, a 50-line Bash shipper is often all you need for simple applications, and it consumes 90% less memory!

---

## ✅ Stack 64 Complete!

Congratulations! You've successfully built a "Central Command" for your data! You can now:
- ✅ **Centralize logs** from hundreds of servers into one dashboard
- ✅ **Implement the ELK Stack** (Elasticsearch, Logstash, Kibana)
- ✅ **Use Loki and Grafana** for high-performance, low-cost logging
- ✅ **Build automated log shippers** using pure Bash and Curl
- ✅ **Create real-time alerts** to catch production issues instantly
- ✅ **Analyze global trends** across your entire infrastructure

### What's Next?
In the final stack of the course, we'll dive into **Service Mesh Basics**. You'll learn the cutting-edge technology used to manage complex microservice communications using Istio and Linkerd!

**Next: Stack 65 - Service Mesh Basics →**

---

*End of Stack 64*
