# 📊 STACK 64: LOG AGGREGATION
## ELK Stack & Loki for Centralized Logging

---

## 🔰 Why Log Aggregation?

- Centralize logs from multiple servers
- Search and analyze across all logs
- Build dashboards
- Alert on patterns
- Troubleshooting production issues

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

## ✅ Stack 64 Complete!

You learned:
- ✅ ELK stack architecture
- ✅ Filebeat installation and configuration
- ✅ Logstash pipeline setup
- ✅ Kibana visualization
- ✅ Loki as lightweight alternative
- ✅ Promtail agent configuration
- ✅ Custom log shipping scripts
- ✅ Alerting on log patterns

---

*End of Stack 64*
