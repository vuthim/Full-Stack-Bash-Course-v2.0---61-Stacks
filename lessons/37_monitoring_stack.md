# 📊 STACK 37: PROMETHEUS & GRAFANA
## Monitoring and Visualization

**What is Prometheus + Grafana?** Think of them as a dynamic duo:
- **Prometheus** = The data collector (gathers metrics from all your servers)
- **Grafana** = The dashboard artist (turns raw numbers into beautiful, readable charts)

**Why This Matters:** Raw metrics are useless without visualization. Prometheus collects, Grafana displays - together they give you real-time insight into everything!

---

## 🔰 What is Prometheus?

Prometheus is an open-source monitoring system with a dimensional data model, flexible query language, and alerting.

### How Prometheus Works (Simple Explanation)
```
1. Prometheus scrapes (pulls) metrics from your servers/apps
2. Stores them in a time-series database (metrics over time)
3. You query with PromQL (Prometheus Query Language)
4. Grafana displays the results as dashboards
```

### Components (Explained Simply)
| Component | What It Does | Analogy |
|-----------|--------------|---------|
| **Prometheus Server** | Collects and stores time series data | The main brain |
| **Exporters** | Expose metrics from services (CPU, memory, etc.) | Translators (turn system stats into metrics) |
| **Alertmanager** | Handles alerts (sends emails, Slack, etc.) | The alarm system |
| **Pushgateway** | Handles short-lived jobs | Drop-off point for jobs that can't be scraped |

**Pro Tip:** Prometheus "pulls" metrics (goes and gets them). Most monitoring tools "push" (send data to a central place). Pull is better because Prometheus controls the timing!

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

## 🎓 Final Project: Monitoring Stack Manager

Now that you've mastered the concepts of Prometheus and Grafana, let's see how a professional Site Reliability Engineer (SRE) might automate the management of their monitoring infrastructure. We'll examine the "Monitoring Stack Manager" — a tool that simplifies starting, stopping, and auditing your observability services.

### What the Monitoring Stack Manager Does:
1. **Automates Lifecycle Management** (start, stop, restart) for both Prometheus and Grafana.
2. **Audits Cluster Targets** to show you exactly which servers are being monitored.
3. **Checks Active Alerts** to identify system problems before users report them.
4. **Lists Grafana Dashboards** programmatically using the Grafana API.
5. **Streams Service Logs** directly to your terminal for quick troubleshooting.
6. **Handles Docker and Systemd** configurations interchangeably.

### Key Snippet: Auditing Prometheus Targets
Knowing which servers Prometheus is successfully "scraping" for data is critical. The manager uses the Prometheus API to give you a quick JSON summary.

```bash
cmd_prom_targets() {
    echo "=== Prometheus Monitoring Targets ==="
    # Call the local Prometheus API
    # jq . : Pretty-print the JSON output
    curl -s http://localhost:9090/api/v1/targets | jq . 2>/dev/null || \
        echo "Error: Could not reach Prometheus API."
}
```

### Key Snippet: Managing Service Logs
Instead of searching through `/var/log`, the manager provides a direct "one-stop-shop" for service history.

```bash
cmd_prom_logs() {
    # -u: Specific unit name
    # -n 50: Only the most recent 50 lines
    # --no-pager: Don't open in 'less', just print to screen
    sudo journalctl -u prometheus -n 50 --no-pager
}
```

**Pro Tip:** Automation like this ensures that your "eyes" (your monitoring stack) are always open and working correctly!

---

## ✅ Stack 37 Complete!

Congratulations! You've successfully built a professional "System Watchtower"! You can now:
- ✅ **Setup Prometheus** to collect real-time metrics from your servers
- ✅ **Install Node Exporter** to track CPU, RAM, and Disk health
- ✅ **Build beautiful Grafana dashboards** to visualize system trends
- ✅ **Write PromQL queries** to extract specific data from your metrics
- ✅ **Automate your monitoring stack** using Bash and the service APIs
- ✅ **Troubleshoot performance issues** before they become outages

### What's Next?
In the next stack, we'll dive into **Ansible Essentials**. You'll learn how to manage thousands of servers at once by writing simple, human-readable configuration files!

**Next: Stack 38 - Ansible Essentials →**

---

*End of Stack 37*