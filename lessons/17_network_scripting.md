# 🔍 STACK 17: NETWORK Scripting
## Network Diagnostics & Automation

---

## 🌐 Network Basics

```bash
# Check connectivity
ping -c 4 google.com

# View IP address
ip addr
hostname -I
ifconfig

# DNS lookup
nslookup example.com
dig example.com
host example.com
```

---

## 🔧 Network Diagnostic Commands

```bash
# Trace route
traceroute google.com
tracepath google.com

# Check open ports
netstat -tuln
ss -tuln

# Test port connectivity
nc -zv host 80
telnet host 80

# View network connections
netstat -an
ss -tan
```

---

## 📡 Network Monitoring Scripts

### Connection Monitor
```bash
#!/bin/bash
# monitor_connections.sh

echo "=== Active Connections ==="
ss -tun | grep ESTAB

echo ""
echo "=== Listening Ports ==="
ss -tuln | grep LISTEN

echo ""
echo "=== Connection States ==="
ss -tan | awk '{print $1}' | sort | uniq -c | sort -rn
```

### Port Scanner
```bash
#!/bin/bash
# simple_port_scanner.sh

host=$1
start=${2:-1}
end=${3:-1024}

echo "Scanning $host ports $start-$end..."

for port in $(seq $start $end); do
    (echo > /dev/tcp/$host/$port) 2>/dev/null && echo "Port $port is open"
done
```

---

## 🌊 Bandwidth Monitoring

```bash
#!/bin/bash
# bandwidth.sh - Monitor interface bandwidth

interface=${1:-eth0}

rx_before=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_before=$(cat /sys/class/net/$interface/statistics/tx_bytes)

sleep 5

rx_after=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_after=$(cat /sys/class/net/$interface/statistics/tx_bytes)

rx_rate=$(( (rx_after - rx_before) / 5 ))
tx_rate=$(( (tx_after - tx_before) / 5 ))

echo "RX: $((rx_rate / 1024)) KB/s"
echo "TX: $((tx_rate / 1024)) KB/s"
```

---

## 🔌 Network Automation

### Test All Servers
```bash
#!/bin/bash
# check_servers.sh

SERVERS=("google.com" "facebook.com" "amazon.com")

for server in "${SERVERS[@]}"; do
    if ping -c 1 -W 2 "$server" > /dev/null 2>&1; then
        echo "✓ $server is reachable"
    else
        echo "✗ $server is DOWN"
    fi
done
```

### Dynamic Inventory
```bash
#!/bin/bash
# inventory.sh - Generate list of reachable hosts

for ip in 192.168.1.{1..254}; do
    if ping -c 1 -W 1 $ip > /dev/null 2>&1; then
        echo "$ip is up"
    fi
done
```

---

## 🔐 Firewall Management (iptables)

```bash
# List rules
sudo iptables -L -n

# Block IP
sudo iptables -A INPUT -s 192.168.1.100 -j DROP

# Allow port
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Save rules
sudo iptables-save > /etc/iptables/rules.v4
```

---

## 📊 Network Report Script

```bash
#!/bin/bash
# network_report.sh

echo "========================================="
echo "       Network Status Report"
echo "========================================="
echo "Date: $(date)"
echo ""

echo "=== IP Addresses ==="
ip -brief addr show | grep UP

echo ""
echo "=== Default Gateway ==="
ip route | grep default

echo ""
echo "=== DNS Servers ==="
cat /etc/resolv.conf | grep nameserver

echo ""
echo "=== Network Stats ==="
cat /proc/net/dev | grep -v lo | awk '{print $1, $2, $10}'
```

---

## 🏆 Practice: Network Dashboard

Create a script that:
1. Checks internet connectivity
2. Lists all network interfaces
3. Shows active connections
4. Displays DNS servers
5. Tests latency to 3 hosts

---

## ✅ Stack 17 Complete!