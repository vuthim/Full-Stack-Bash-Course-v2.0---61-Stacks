# 🌐 STACK 51: DNS MANAGEMENT
## Domain Name System Configuration

**What is DNS?** Think of DNS as the internet's phonebook. Instead of remembering IP addresses like `142.250.80.46`, you type `google.com` and DNS translates it for you. Without DNS, you'd need to memorize numbers for every website!

**Why This Matters:** DNS is foundational to everything on the internet. Understanding it helps you troubleshoot "website not loading" issues, set up your own domains, and understand how the internet actually works.

---

## 🔰 What is DNS?

DNS (Domain Name System) translates domain names to IP addresses.

### DNS Record Types (Explained Simply)
| Record | What It Does | Example | Analogy |
|--------|--------------|---------|---------|
| **A** | Points to an IPv4 address | `example.com → 93.184.216.34` | Street address |
| **AAAA** | Points to an IPv6 address | `example.com → 2606:2800:220:1:248:1893:25c8:1946` | Street address (new format) |
| **CNAME** | Alias (points to another domain) | `www.example.com → example.com` | "Also known as" |
| **MX** | Mail server location | Where to send email for this domain | Mail routing instructions |
| **TXT** | Text records (verification, security) | SPF, DKIM for email authentication | Notes/signs on the door |
| **NS** | Name server (who manages DNS) | Which server holds the records | The phonebook publisher |
| **SOA** | Start of Authority (primary DNS info) | Serial number, refresh rates | The "last updated" info |

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

## 🎓 Final Project: DNS Operations Manager

Now that you've mastered the record types and zones of the DNS world, let's see how a professional Network Engineer might automate their daily lookups. We'll examine the "DNS Manager" — a tool that provides a unified interface for performing advanced queries across multiple record types (A, MX, TXT, etc.) and managing local DNS services.

### What the DNS Operations Manager Does:
1. **Performs Multi-Type Queries** (A, AAAA, MX, NS, TXT) with one-word commands.
2. **Simplifies Lookup Results** by utilizing `dig +short` for clean, scriptable output.
3. **Automates Service Management** for local DNS resolvers like `dnsmasq`.
4. **Handles Record Auditing** to verify if your domain changes have propagated correctly.
5. **Provides a Standardized CLI** for network diagnostic tasks.
6. **Validates Record Syntax** to ensure consistency across your DNS environment.

### Key Snippet: Clean Record Lookups
The manager uses the `+short` flag of the `dig` command to strip away the "header" noise and give you just the data you need for your scripts.

```bash
cmd_mx() {
    local domain=$1
    echo "=== MX (Mail) Records for $domain ==="
    
    # +short: only show the priority and server name
    dig +short MX "$domain"
    
    # Pro Tip: No results usually means the domain doesn't exist
    # or it's not configured to receive email!
}
```

### Key Snippet: Managing Local DNS Resolvers
For developers, managing a local `dnsmasq` instance is common. The manager makes restarting and checking status easy.

```bash
cmd_dnsmasq_restart() {
    log "Restarting local DNS resolver (dnsmasq)..."
    
    # Restart the service to apply any new local domain overrides
    sudo systemctl restart dnsmasq
    
    log "DNS resolver restarted successfully."
}
```

**Pro Tip:** Automating your DNS lookups is essential for writing health-check scripts that monitor your domain's availability across the global network!

---

## ✅ Stack 51 Complete!

Congratulations! You've successfully mastered the "Phonebook of the Internet"! You can now:
- ✅ **Understand all DNS record types** (A, CNAME, MX, TXT, etc.)
- ✅ **Setup and configure BIND9** for professional zone management
- ✅ **Perform advanced queries** like a network pro using `dig` and `nslookup`
- ✅ **Manage Forward and Reverse zones** for complex network setups
- ✅ **Implement DNSSEC** to protect your domains from "poisoning" attacks
- ✅ **Automate DNS diagnostics** using custom power-user scripts

### What's Next?
In the next stack, we'll dive into **SSL/TLS**. You'll learn how to secure your websites and services with encryption certificates and navigate the world of HTTPS!

**Next: Stack 52 - SSL/TLS →**

---

*End of Stack 51*
-- **Previous:** [Stack 50 → Email Server Management](50_email_server.md)
-- **Next:** [Stack 52 - SSL/TLS](52_ssl_tls.md)