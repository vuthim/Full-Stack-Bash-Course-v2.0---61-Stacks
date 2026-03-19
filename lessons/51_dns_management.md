# 🌐 STACK 51: DNS MANAGEMENT
## Domain Name System Configuration

---

## 🔰 What is DNS?

DNS (Domain Name System) translates domain names to IP addresses.

### DNS Records Types
| Record | Purpose |
|--------|---------|
| A | IPv4 address |
| AAAA | IPv6 address |
| CNAME | Alias |
| MX | Mail server |
| TXT | Text/verification |
| NS | Name server |
| SOA | Start of Authority |

---

## ⚡ DNS Server Types

### Types of DNS
| Type | Description |
|------|-------------|
| Authoritative | Has original zone data |
| Recursive | Resolves for clients |
| Caching | Caches queries |
| Forwarder | Forwards to upstream |

---

## 🏗️ BIND9 Installation

### Install BIND
```bash
sudo apt install bind9 bind9utils bind9-doc

# Start service
sudo systemctl enable --now bind9
```

### Main Config
```bash
# /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    dnssec-validation auto;
    listen-on { any; };
};
```

---

## 📝 Zone Configuration

### Create Forward Zone
```bash
# /etc/bind/named.conf.local
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
    allow-transfer { any; };
};
```

### Zone File
```bash
# /etc/bind/db.example.com
$TTL    86400
@       IN      SOA     ns1.example.com. admin.example.com. (
                        2024011501 ; Serial
                        3600       ; Refresh (1 hour)
                        1800       ; Retry (30 min)
                        604800     ; Expire (1 week)
                        86400 )    ; Minimum (1 day)

; Name servers
@       IN      NS      ns1.example.com.
@       IN      NS      ns2.example.com.

; A records
@       IN      A       192.168.1.10
ns1     IN      A       192.168.1.11
ns2     IN      A       192.168.1.12
www     IN      A       192.168.1.10
mail    IN      A       192.168.1.20

; MX record
@       IN      MX      10 mail.example.com.

; TXT record (SPF)
@       IN      TXT     "v=spf1 mx ~all"

; CNAME
blog    IN      CNAME   www
```

### Reverse Zone
```bash
# /etc/bind/named.conf.local
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.1";
};

# /etc/bind/db.192.168.1
$TTL    86400
@       IN      SOA     ns1.example.com. admin.example.com. (
                        2024011501 ; Serial
                        3600       ; Refresh
                        1800       ; Retry
                        604800     ; Expire
                        86400 )    ; Minimum

@       IN      NS      ns1.example.com.
10      IN      PTR     example.com.
11      IN      PTR     ns1.example.com.
12      IN      PTR     ns2.example.com.
```

---

## 🔄 Dynamic DNS (DDNS)

### DHCP Updates
```bash
# /etc/bind/named.conf.local
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
    allow-update { key "ddns-key"; };
};

# Generate key
dnssec-keygen -a HMAC-MD5 -b 128 -n HOST ddns-key

# Add key to config
include "/etc/bind/ddns.key";
```

---

## 🛡️ DNSSEC

### Enable DNSSEC
```bash
# Sign zone
sudo dnssec-signzone -A -3 $(date +%Y%m%d%H) -N increment -o example.com /etc/bind/db.example.com

# Configure validation
# /etc/bind/named.conf.options
dnssec-validation yes;

# Add trust anchors
managed-keys {
    "." initial-key 257 3 8 "AwEAAagAI...";
};
```

---

## 🔍 DNS Testing

### Query Commands
```bash
# Using dig
dig example.com A
dig example.com MX
dig -x 192.168.1.10

# Using nslookup
nslookup example.com
nslookup -type=MX example.com

# Using host
host example.com
host -t MX example.com
```

### Testing Script
```bash
#!/bin/bash
# dns_check.sh

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 domain"
    exit 1
fi

echo "=== DNS Check for $DOMAIN ==="
echo "A Record:"
dig +short $DOMAIN A

echo "MX Record:"
dig +short $DOMAIN MX

echo "NS Record:"
dig +short $DOMAIN NS

echo "TXT Record:"
dig +short $DOMAIN TXT

echo "Reverse:"
host $(dig +short $DOMAIN A | head -1)
```

---

## 📦 Using DNS in Scripts

### Parse DNS Results
```bash
#!/bin/bash
# get_ip.sh

# Get A record
IP=$(dig +short example.com A | tail -1)
echo "IP: $IP"

# Check if resolves
if dig +short example.com >/dev/null; then
    echo "Domain resolves"
else
    echo "Domain does not resolve"
fi
```

---

## 🏆 Practice Exercises

### Exercise 1: Install and Configure
```bash
# Install BIND
sudo apt install bind9

# Check status
sudo systemctl status bind9

# Test with dig
dig google.com
```

### Exercise 2: Local Zone
```bash
# Create zone file
sudo tee /etc/bind/db.localdomain << 'EOF'
$TTL    604800
@       IN      SOA     localhost. root.localhost. (
                        2024011501
                        604800
                        86400
                        2419200
                        604800 )
@       IN      NS      localhost.
@       IN      A       127.0.0.1
EOF

# Add zone to config
sudo nano /etc/bind/named.conf.local

# Reload
sudo rndc reload

# Test
dig @localhost test.localdomain
```

### Exercise 3: DNS Health Check
```bash
# Check all DNS servers
for server in 8.8.8.8 1.1.1.1; do
    if dig google.com @$server +short >/dev/null; then
        echo "OK: $server"
    fi
done
```

---

## 📋 DNS Commands Cheat Sheet

| Command | Description |
|---------|-------------|
| `dig` | Query DNS |
| `nslookup` | Query DNS |
| `host` | Simple lookup |
| `rndc` | BIND control |
| `named-checkconf` | Validate config |

---

## ✅ Stack 51 Complete!

You learned:
- ✅ DNS basics and record types
- ✅ BIND9 installation
- ✅ Zone configuration
- ✅ Forward and reverse zones
- ✅ DNSSEC basics
- ✅ Testing tools

### Next: Stack 52 - SSL/TLS →

---

*End of Stack 51*