# 📊 STACK 37: PROMETHEUS & GRAFANA
## Monitoring and Visualization

---

## 🔰 What is Prometheus?

Prometheus is an open-source monitoring system with a dimensional data model, flexible query language, and alerting.

### Components
| Component | Purpose |
|-----------|---------|
| Prometheus Server | Collects and stores time series data |
| Exporters | Expose metrics from services |
| Alertmanager | Handle alerts |
| Pushgateway | Handle short-lived jobs |

---

## ⚡ Installing Prometheus

### Manual Installation
```bash
# Download
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz

# Extract
tar xzf prometheus-2.47.0.linux-amd64.tar.gz

# Create user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create directories
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Move binaries
sudo cp prometheus-2.47.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.47.0.linux-amd64/promtool /usr/local/bin/
```

### Configuration
```yaml
# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

### Service File
```ini
# /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
```

---

## 📦 Node Exporter

### Install
```bash
# Download
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz

# Extract
tar xzf node_exporter-1.6.1.linux-amd64.tar.gz

# Move
sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

# Run
node_exporter
```

---

## 📈 Grafana Installation

### Install on Ubuntu
```bash
# Install dependencies
sudo apt-get install -y apt-transport-https software-properties-common

# Add GPG key
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Add repository
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Install
sudo apt-get update
sudo apt-get install grafana

# Start
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

### Access
```bash
# Default credentials
# URL: http://localhost:3000
# Username: admin
# Password: admin
```

---

## 🔌 Setting Up Dashboards

### Add Prometheus Data Source
1. Open Grafana (http://localhost:3000)
2. Go to Configuration > Data Sources
3. Add Prometheus
4. URL: http://localhost:9090
5. Save & Test

### Add Dashboard
1. Go to Dashboards > Import
2. Enter dashboard ID (e.g., 1860 for Node Exporter)
3. Select Prometheus as data source
4. Import

### Common Dashboard IDs
| ID | Dashboard |
|----|-----------|
| 1860 | Node Exporter Full |
| 9588 | Prometheus 2.0 Stats |
| 10856 | Redis |

---

## 📊 Basic Queries

### PromQL Examples
```promql
# CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk usage
100 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)

# Network traffic
rate(node_network_receive_bytes_total[5m])
```

---

## 🔔 Alerting

### Alert Rules
```yaml
# /etc/prometheus/rules.yml
groups:
  - name: server_alerts
    rules:
      - alert: HighCPU
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          description: "CPU usage is above 80% on {{ $labels.instance }}"
    
      - alert: HighMemory
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
        for: 5m
        labels:
          severity: critical
```

### Alertmanager Config
```yaml
# /etc/alertmanager/alertmanager.yml
route:
  receiver: 'email'

receivers:
  - name: 'email'
    email_configs:
      - to: 'admin@example.com'
        send_resolved: true
```

---

## 🏆 Practice Exercises

### Exercise 1: Install and Run
```bash
# Install Prometheus
# (use manual install above)

# Create config
sudo nano /etc/prometheus/prometheus.yml

# Start
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Check
curl localhost:9090
```

### Exercise 2: Add Node Exporter
```bash
# Install node exporter
sudo cp node_exporter /usr/local/bin/

# Create service
sudo tee /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter

[Service]
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload and start
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Add to prometheus config
sudo nano /etc/prometheus/prometheus.yml

# Restart prometheus
sudo systemctl restart prometheus
```

### Exercise 3: Create Grafana Dashboard
```bash
# Access Grafana
# http://localhost:3000

# Add Prometheus as datasource

# Import node_exporter dashboard
# Dashboard ID: 1860
```

---

## 📋 Commands Cheat Sheet

| Command | Purpose |
|---------|---------|
| `curl localhost:9090` | Check Prometheus UI |
| `curl localhost:9100/metrics` | Node exporter metrics |
| `systemctl status prometheus` | Check status |

---

## ✅ Stack 37 Complete!

You learned:
- ✅ Prometheus basics and installation
- ✅ Node Exporter setup
- ✅ Grafana installation
- ✅ Creating dashboards
- ✅ Basic PromQL queries
- ✅ Alerting

### Next: Stack 38 - Ansible Essentials →

---

*End of Stack 37*