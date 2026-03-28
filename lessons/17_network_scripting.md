# 🔍 STACK 17: NETWORK SCRIPTING
## Network Diagnostics & Automation

---

## 🔰 Why Network Scripting?

Network scripting is essential for:
- **Troubleshooting** - Diagnose connectivity issues
- **Monitoring** - Track network health
- **Automation** - Manage network devices
- **Security** - Detect threats, manage firewall
- **Inventory** - Discover devices on network

---

## ⚙️ Network Basics

### Check Connectivity
```bash
# Ping host
ping -c 4 google.com
ping -c 4 8.8.8.8

# Continuous ping
ping -c 100 google.com

# Specific interface
ping -I eth0 google.com

# Packet size
ping -s 1000 google.com
```

### View IP Addresses
```bash
# Modern command (iproute2)
ip addr
ip -brief addr show
ip -4 addr show
ip -6 addr show

# Legacy command
ifconfig
hostname -I          # IPv4 only
hostname -I -6       # IPv6 only
```

### DNS Lookup
```bash
# Basic lookup
nslookup example.com
dig example.com
host example.com

# Detailed info
dig +short example.com
dig +trace example.com
dig -x 93.184.216.34  # Reverse lookup

# DNS over HTTPS
curl -s https://dns.google/resolve?name=example.com | jq
```

---

## 🔧 Network Diagnostic Commands

### Traceroute
```bash
# Install if needed
sudo apt install traceroute

# Basic traceroute
traceroute google.com

# ICMP (default)
traceroute -I google.com

# TCP SYN (stealth)
traceroute -T -p 80 google.com

# UDP
traceroute -U google.com

# Numeric only
traceroute -n google.com

# Tracepath (simpler)
tracepath google.com
```

### Port Scanning
```bash
# Check if port is open
nc -zv host 80
nc -zv host 80 2>&1

# Scan single port
nc -zv 192.168.1.1 22

# Scan port range
nc -zv 192.168.1.1 20-30

# With timeout
nc -zv -w 3 host 80
```

### Network Connections
```bash
# Modern tool (ss)
ss -tuln              # Listening TCP/UDP
ss -tun              # All TCP/UDP
ss -tan              # All TCP
ss -tun state established  # Established connections

# With process info
ss -tulpn
ss -tunp

# Statistics
ss -s
ss -i

# Legacy (netstat)
netstat -tuln
netstat -an
netstat -r           # Routing table
netstat -i           # Interface stats
```

### Network Interfaces
```bash
# Show interfaces
ip link show
ip addr show
ip -s link

# Interface details
ethtool eth0
ethtool -i eth0
mii-tool eth0

# Wireless
iwconfig
iwlist scan
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

HOST="$1"
START_PORT="${2:-1}"
END_PORT="${3:-1024}"

if [ -z "$HOST" ]; then
    echo "Usage: $0 <host> [start_port] [end_port]"
    exit 1
fi

echo "Scanning $HOST ports $START_PORT-$END_PORT..."

for port in $(seq $START_PORT $END_PORT); do
    if timeout 0.1 bash -c "echo >/dev/tcp/$HOST/$port" 2>/dev/null; then
        echo "Port $port is OPEN"
    fi
done
```

### Advanced Port Scanner
```bash
#!/bin/bash
# port_scanner.sh

set -euo pipefail

HOST="$1"
PORTS="${2:-22,80,443,3306,5432,6379,8080,8443}"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

scan_port() {
    local host="$1"
    local port="$2"
    
    if timeout 1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        echo -e "${GREEN}✓ Port $port: OPEN${NC}"
        return 0
    else
        echo -e "${RED}✗ Port $port: CLOSED${NC}"
        return 1
    fi
}

echo "Scanning $HOST..."
IFS=',' read -ra PORTS_ARRAY <<< "$PORTS"
for port in "${PORTS_ARRAY[@]}"; do
    scan_port "$HOST" "$port" &
done

wait
```

---

## 🌊 Bandwidth Monitoring

### Interface Bandwidth
```bash
#!/bin/bash
# bandwidth.sh

INTERFACE="${1:-eth0}"
INTERVAL="${2:-5}"

log_stats() {
    local rx_bytes=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    local tx_bytes=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    echo "$(date +%s) $rx_bytes $tx_bytes"
}

# First reading
read -r time1 rx1 tx1 <<< "$(log_stats)"
sleep "$INTERVAL"

# Second reading
read -r time2 rx2 tx2 <<< "$(log_stats)"

# Calculate rates
rx_rate=$(( (rx2 - rx1) / INTERVAL ))
tx_rate=$(( (tx2 - tx1) / INTERVAL ))

# Convert to human readable
rx_human=$(numfmt --to=iec-i --suffix=B $rx_rate)
tx_human=$(numfmt --to=iec-i --suffix=B $tx_rate)

echo "Interface: $INTERFACE"
echo "RX Rate: $rx_human/s"
echo "TX Rate: $tx_human/s"
```

### Continuous Bandwidth Monitor
```bash
#!/bin/bash
# bandwidth_monitor.sh

INTERFACE="${1:-eth0}"

while true; do
    rx_before=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    tx_before=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    
    sleep 1
    
    rx_after=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    tx_after=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    
    rx_rate=$(( (rx_after - rx_before) / 1024 ))
    tx_rate=$(( (tx_after - tx_before) / 1024 ))
    
    echo "$(date '+%H:%M:%S') RX: ${rx_rate}KB/s TX: ${tx_rate}KB/s"
done
```

### Network Traffic by Process
```bash
#!/bin/bash
# traffic_by_process.sh

# Install if needed: sudo apt install nethogs

# Monitor by process
sudo nethogs eth0

# Monitor by device
sudo nethogs -d 5 eth0

# Alternative: use iptraf-ng
sudo iptraf-ng
```

---

## 🔌 Network Automation

### Server Reachability Check
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
# inventory.sh

NETWORK="${1:-192.168.1}"
START="${2:-1}"
END="${3:-254}"

echo "Discovering hosts in $NETWORK.$START-$END..."

for ip in $(seq $START $END); do
    if timeout 0.5 ping -c 1 -W 1 "$NETWORK.$ip" > /dev/null 2>&1; then
        echo "Host found: $NETWORK.$ip"
        
        # Try to get hostname
        hostname=$(timeout 0.5 nslookup "$NETWORK.$ip" | grep "name =" | awk '{print $NF}')
        if [ -n "$hostname" ]; then
            echo "  Hostname: $hostname"
        fi
    fi
done
```

### Multi-Server Health Check
```bash
#!/bin/bash
# health_check.sh

SERVERS=(
    "192.168.1.10:22"
    "192.168.1.10:80"
    "192.168.1.10:443"
    "192.168.1.20:22"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check_service() {
    local host=$(echo "$1" | cut -d: -f1)
    local port=$(echo "$1" | cut -d: -f2)
    
    if timeout 1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        echo -e "${GREEN}✓ $host:$port${NC}"
    else
        echo -e "${RED}✗ $host:$port${NC}"
    fi
}

for server in "${SERVERS[@]}"; do
    check_service "$server" &
done

wait
```

---

## 🔐 Firewall Management

### iptables Basics
```bash
# List rules
sudo iptables -L -n -v
sudo iptables -L -n --line-numbers

# List specific chain
sudo iptables -L INPUT -n
sudo iptables -L OUTPUT -n

# Default policies
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
```

### Common iptables Rules
```bash
# Allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow localhost
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Block IP
sudo iptables -A INPUT -s 192.168.1.100 -j DROP

# Allow specific IP
sudo iptables -A INPUT -s 10.0.0.50 -j ACCEPT

# Rate limiting
sudo iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 20 -j DROP
```

### UFW (Ubuntu Firewall)
```bash
# Enable/Disable
sudo ufw enable
sudo ufw disable

# Status
sudo ufw status
sudo ufw status numbered

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow/deny ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 23/tcp

# Allow by service
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'

# Delete rules
sudo ufw delete allow 22/tcp
sudo ufw delete 1

# Application profiles
sudo ufw app list
sudo ufw app info 'Nginx Full'
```

### Firewall Script
```bash
#!/bin/bash
# setup_firewall.sh

set -euo pipefail

echo "Setting up firewall..."

# Flush existing rules
sudo iptables -F
sudo iptables -X

# Default policies
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow established
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow ping
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Save rules
if [ -f /etc/debian_version ]; then
    sudo iptables-save > /etc/iptables/rules.v4
elif [ -f /etc/redhat-release ]; then
    sudo service iptables save
fi

echo "Firewall configured!"
sudo iptables -L -n -v
```

---

## 📊 Network Report Script

### Comprehensive Network Report
```bash
#!/bin/bash
# network_report.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "       Network Status Report"
echo "========================================="
echo "Date: $(date)"
echo ""

# Hostname and OS
echo "=== System ==="
echo "Hostname: $(hostname)"
echo "Domain: $(hostname -d 2>/dev/null || echo 'N/A')"
echo ""

# IP Addresses
echo "=== IP Addresses ==="
ip -brief addr show | grep UP
echo ""

# Default Gateway
echo "=== Default Gateway ==="
ip route | grep default
echo ""

# DNS Servers
echo "=== DNS Servers ==="
grep nameserver /etc/resolv.conf
echo ""

# Connectivity Check
echo "=== Internet Connectivity ==="
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Internet: Connected${NC}"
else
    echo -e "${RED}✗ Internet: Disconnected${NC}"
fi
echo ""

# Listening Services
echo "=== Listening Services ==="
ss -tuln | grep LISTEN | head -10
echo ""

# Network Statistics
echo "=== Network Statistics ==="
cat /proc/net/dev | grep -v lo | awk '{print $1": RX "$2" TX "$10}'
echo ""

# Top Connections
echo "=== Top Connection States ==="
ss -tan | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
echo ""

echo "========================================="
echo "Report complete!"
```

---

## 🏆 Practice: Network Dashboard

### Complete Dashboard Script
```bash
#!/bin/bash
# network_dashboard.sh

INTERVAL="${1:-5}"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

while true; do
    clear
    
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}         Network Dashboard$(date '+ %Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
    
    # Date and Time
    echo "Date: $(date)"
    echo ""
    
    # IP Addresses
    echo "━━━ IP Addresses ━━━"
    ip -brief addr show | grep UP
    echo ""
    
    # Internet Connectivity
    echo "━━━ Connectivity ━━━"
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        echo -e "Internet: ${GREEN}✓ Connected${NC}"
    else
        echo -e "Internet: ${RED}✗ Disconnected${NC}"
    fi
    
    if ping -c 1 -W 2 1.1.1.1 > /dev/null 2>&1; then
        echo -e "DNS (Cloudflare): ${GREEN}✓ OK${NC}"
    else
        echo -e "DNS (Cloudflare): ${RED}✗ Failed${NC}"
    fi
    echo ""
    
    # Bandwidth
    echo "━━━ Bandwidth (5s average) ━━━"
    for iface in eth0 wlan0; do
        if [ -d /sys/class/net/$iface ]; then
            rx1=$(cat /sys/class/net/$iface/statistics/rx_bytes)
            tx1=$(cat /sys/class/net/$iface/statistics/tx_bytes)
            sleep 2
            rx2=$(cat /sys/class/net/$iface/statistics/rx_bytes)
            tx2=$(cat /sys/class/net/$iface/statistics/tx_bytes)
            
            rx_rate=$(( (rx2 - rx1) / 2 / 1024 ))
            tx_rate=$(( (tx2 - tx1) / 2 / 1024 ))
            
            echo "$iface: RX ${rx_rate}KB/s TX ${tx_rate}KB/s"
        fi
    done
    echo ""
    
    # Top Connections
    echo "━━━ Connection States ━━━"
    ss -tan | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
    echo ""
    
    # Listening Ports
    echo "━━━ Listening Services ━━━"
    ss -tuln | grep LISTEN | awk '{print $1, $5}' | column -t
    echo ""
    
    sleep "$INTERVAL"
done
```

---

## 🔍 Troubleshooting

### Common Network Issues
```bash
# No internet
# Check: ping 8.8.8.8
# Check: cat /etc/resolv.conf
# Check: ip route

# DNS not working
# Check: nslookup google.com
# Check: cat /etc/resolv.conf
# Restart: sudo systemctl restart systemd-resolved

# Can't connect to host
# Check: ping host
# Check: telnet host port
# Check: firewall status

# Slow network
# Check: traceroute host
# Check: ss -s
# Check: iftop
```

### Network Debug Script
```bash
#!/bin/bash
# network_debug.sh

HOST="${1:-google.com}"

echo "=== Network Debug for $HOST ==="

echo ""
echo "1. Checking DNS..."
nslookup "$HOST"

echo ""
echo "2. Checking connectivity..."
ping -c 3 "$HOST"

echo ""
echo "3. Tracing route..."
traceroute -m 15 "$HOST"

echo ""
echo "4. Checking port 443..."
nc -zv -w 5 "$HOST" 443

echo ""
echo "5. Getting IP..."
dig +short "$HOST"

echo ""
echo "6. Checking interface status..."
ip link show
ip addr show

echo ""
echo "7. Checking routing..."
ip route show

echo ""
echo "8. Checking DNS..."
cat /etc/resolv.conf
```

---

## 📋 Network Scripts Quick Reference

| Task | Command |
|------|---------|
| Check connectivity | `ping -c 4 host` |
| Trace route | `traceroute host` |
| DNS lookup | `dig host` |
| Port check | `nc -zv host port` |
| List connections | `ss -tuln` |
| Show IP | `ip addr` |
| Add IP | `ip addr add IP/24 dev eth0` |
| Default gateway | `ip route add default via GW` |
| Flush DNS | `sudo systemd-resolve --flush-caches` |

---

## ✅ Stack 17 Complete!

You learned:
- ✅ Network basics (ping, DNS, IP)
- ✅ Diagnostic commands (traceroute, netstat, ss)
- ✅ Port scanning scripts
- ✅ Bandwidth monitoring
- ✅ Server reachability automation
- ✅ Network discovery/inventory
- ✅ Firewall management (iptables, UFW)
- ✅ Comprehensive network reports
- ✅ Network dashboard
- ✅ Troubleshooting

### Next: Stack 18 - System Monitoring →

---

*End of Stack 17*
