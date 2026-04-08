# 🌟 STACK 49: HIGH AVAILABILITY
## Building Resilient Systems

**What is High Availability?** Think of HA as a "spare tire for your systems." When something breaks (and it will), HA automatically switches to a backup so users never notice. It's the difference between "the site is down!" and "huh, one server crashed but the site is still running."

**Why This Matters:** Downtime costs money. Every minute your system is down, you lose users, revenue, and trust. HA minimizes that risk.

---

## 🔰 What is High Availability?

High Availability (HA) ensures systems remain operational even when components fail.

### Key Metrics (What "Uptime" Actually Means)
| Metric | What It Means | Why It Matters |
|--------|--------------|----------------|
| **Uptime** | Percentage of time system is operational | The big number everyone looks at |
| **SLA** | Service Level Agreement (promise to customers) | Legal commitment - miss it, pay penalties |
| **RTO** | Recovery Time Objective (how fast to recover) | "How long until we're back up?" |
| **RPO** | Recovery Point Objective (how much data can we lose) | "How far back do we restore from?" |

### Uptime Targets
| Availability | Downtime/Year | Downtime/Week |
|--------------|---------------|---------------|
| 99% | 87.6 hours | 1.68 hours |
| 99.9% | 8.76 hours | 10.1 minutes |
| 99.99% | 52.6 minutes | 1 minute |
| 99.999% | 5.26 minutes | 6 seconds |

---

## 🏗️ HA Architecture

### Components
- **Redundancy**: Multiple instances of components
- **Failover**: Automatic switching to backup
- **Load Distribution**: Balance across nodes
- **Monitoring**: Detect failures quickly

### Common Setup
```
Internet
    ↓
Load Balancer ← (HAProxy/NGINX)
    ↓
[Web Server 1] [Web Server 2] [Web Server 3]
    ↓                   ↓           ↓
[DB Primary] ←→ [DB Standby]
```

---

## ⚙️ Keepalived (VRRP)

### Installation
```bash
# Install
sudo apt install keepalived

# Enable IP forwarding
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
```

### Configuration (Master)
```ini
# /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
    state MASTER
    interface ens3
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass mypassword
    }
    virtual_ipaddress {
        192.168.1.100
    }
}
```

### Configuration (Backup)
```ini
# On backup server
vrrp_instance VI_1 {
    state BACKUP
    interface ens3
    virtual_router_id 51
    priority 90
    # ... rest same as master
}
```

### Health Check Script
```ini
vrrp_script chk_haproxy {
    script "/usr/bin/pgrep haproxy"
    interval 2
    weight 2
}

vrrp_instance VI_1 {
    # ...
    track_script {
        chk_haproxy
    }
}
```

---

## 💾 Database HA

### PostgreSQL Streaming Replication
```bash
# On primary (postgresql.conf)
wal_level = replica
max_wal_senders = 3
wal_keep_segments = 8
hot_standby = on

# pg_hba.conf on primary
host replication replica_user 192.168.1.0/24 md5

# Create replication user
CREATE USER replica_user REPLICATION LOGIN PASSWORD 'password';

# On standby (postgresql.conf)
hot_standby = on

# Backup and create standby
pg_basebackup -h primary_ip -D /var/lib/postgresql/14/main -U replica_user -P -Xs

# Create recovery.conf
standby_mode = 'on'
primary_conninfo = 'HOST=primary_ip PORT=5432 USER=replica_user PASSWORD=password'
```

---

## 📊 Monitoring for HA

### Health Check Script
```bash
#!/bin/bash
# health_check.sh

# Check service
systemctl is-active --quiet nginx || exit 1

# Check ports
netstat -tuln | grep -q :80 || exit 1

# Check memory
MEMORY=$(free -m | awk '/Mem:/ {print $3}')
if [ "$MEMORY" -gt 9000 ]; then
    exit 1
fi

exit 0
```

---

## 🔄 Failover Scripts

### Automatic Failover
```bash
#!/bin/bash
# failover.sh

VIP="192.168.1.100"
NEW_MASTER="192.168.1.11"

# Promote new master
ssh $NEW_MASTER "promote.sh"

# Wait for promotion
sleep 5

# StartVIP on new master
ssh $NEW_MASTER "ip addr add $VIP dev eth0"

# Update DNS or load balancer
curl -X POST http://lb.example.com/update -d "server=$NEW_MASTER"
```

---

## 📋 HA Monitoring Tools

| Tool | Description |
|------|-------------|
| Prometheus | Metrics collection |
| Grafana | Visualization |
| Nagios | Monitoring |
| Zabbix | Enterprise monitoring |
| Monit | Process monitoring |

---

## 🏆 Practice Exercises

### Exercise 1: Keepalived Setup
```bash
# Install keepalived
sudo apt install keepalived

# Configure
sudo nano /etc/keepalived/keepalived.conf

# Test config
sudo keepalived -t

# Start
sudo systemctl start keepalived
```

### Exercise 2: Health Check
```bash
# Create health check
cat > /usr/local/bin/monitor.sh << 'EOF'
#!/bin/bash
if systemctl is-active nginx >/dev/null 2>&1; then
    exit 0
else
    exit 1
fi
EOF
chmod +x /usr/local/bin/monitor.sh

# Add as cron
# */5 * * * * /usr/local/bin/monitor.sh || alert
```

### Exercise 3: Database Replication
```bash
# Configure PostgreSQL replication
# See "PostgreSQL Streaming Replication" above
```

---

## 🎓 Final Project: High Availability Cluster Manager

Now that you've mastered the concepts of High Availability (HA), let's see how a professional Infrastructure Engineer might automate the management of a server cluster. We'll examine the "HA Manager" — a tool that provides a unified interface for monitoring cluster health, managing resources, and performing manual failovers.

### What the High Availability Cluster Manager Does:
1. **Provides a Real-Time Cluster Status** showing the health of all nodes and resources.
2. **Lists Cluster Nodes** and identifies which ones are currently "Online" vs "Offline".
3. **Manages Cluster Resources** (start, stop, and status) with simplified commands.
4. **Automates Resource Migration** allowing you to move services between nodes for maintenance.
5. **Audits Corosync and Pacemaker** status to ensure the underlying cluster engine is healthy.
6. **Detects Missing Tools** and warns you if the system isn't configured for high availability.

### Key Snippet: Cluster Resource Migration
One of the most important tasks in an HA cluster is moving a service from one machine to another. The manager uses the `pcs` (Pacemaker Configuration System) tool to do this safely.

```bash
cmd_migrate() {
    local resource=$1
    local destination_node=$2
    
    echo "Migrating resource '$resource' to node '$destination_node'..."
    
    # pcs resource move: forces a resource to run on a specific node
    if pcs resource move "$resource" "$destination_node"; then
        log "Resource migration initiated successfully!"
    else
        error "Failed to migrate resource. Check cluster status."
    fi
}
```

### Key Snippet: Cross-Tool Status Auditing
Since different systems might use different monitoring tools, the manager checks for several common utilities to ensure you always get a status report.

```bash
cmd_status() {
    echo "=== Global Cluster Health ==="
    
    # Check for PCS (Red Hat/CentOS style) or CRM (Debian/Ubuntu style)
    if command -v pcs &>/dev/null; then
        pcs status
    elif command -v crm_mon &>/dev/null; then
        crm_mon -1
    else
        error "No cluster monitoring tools found on this system."
    fi
}
```

**Pro Tip:** Automation like this is the difference between a 10-minute outage and a 10-second failover. In the world of High Availability, every second counts!

---

## ✅ Stack 49 Complete!

Congratulations! You've successfully built a "system that never sleeps"! You can now:
- ✅ **Architect "Zero-Downtime" systems** using multi-node clusters
- ✅ **Understand critical metrics** like SLA (Service Level Agreements) and RTO
- ✅ **Configure Keepalived** for automatic virtual IP failover
- ✅ **Setup Database Replication** to ensure your data is always safe
- ✅ **Manage Cluster Engines** like Corosync and Pacemaker
- ✅ **Perform safe service migrations** across your entire infrastructure

### What's Next?
In the next stack, we'll dive into **Email Server Management**. You'll learn how to setup and secure your own professional mail servers (Postfix, Dovecot) and navigate the complex world of SPF, DKIM, and DMARC!

**Next: Stack 50 - Email Server →**

---

*End of Stack 49*