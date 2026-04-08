# 🔒 STACK 52: SSL/TLS CERTIFICATES
## Secure Communications for DevOps

**What is SSL/TLS?** Think of SSL/TLS as a sealed, tamper-proof envelope for your data. Without it, your data travels like a postcard - anyone handling it can read it. With SSL/TLS, it's like a locked safe that only the sender and receiver can open.

**Why This Matters:** Every website, API, and email service needs SSL/TLS. Without it, passwords, credit cards, and personal data are exposed. It's not optional anymore - it's essential.

---

## 🔰 SSL/TLS Fundamentals

### What is SSL/TLS?
- **SSL** (Secure Sockets Layer) - Original protocol (deprecated, don't use!)
- **TLS** (Transport Layer Security) - Modern successor (what we actually use now)
- Provides **encryption** (scrambles data), **authentication** (verifies identity), and **integrity** (detects tampering)

### Why It Matters (Real-World Impact)
- ✅ **Encrypts data in transit** - Hackers can't read your passwords or credit cards
- ✅ **Authenticates server** - You're talking to the REAL site, not an imposter
- ✅ **Prevents man-in-the-middle attacks** - No eavesdropping on your connection
- ✅ **Required for HTTPS, secure email, etc.** - Modern browsers block non-HTTPS sites

### TLS Handshake (Simplified Analogy)
```
Think of it like meeting someone in a secure building:

1. Client: "Hi, I want to talk securely!" (Client Hello)
2. Server: "Here's my ID badge (certificate) and a lock box" (Server Hello + Certificate)
3. Client: "Let me verify your badge... OK, here's a secret key for the lock box" (Verify + key exchange)
4. Server: "Got it! We're now secure" (Finished)
5. → All conversation is now encrypted and private!
```

---

## 📜 Certificate Basics

### Types of Certificates
| Type | Use Case | Validation Level |
|------|----------|------------------|
| **DV** (Domain Validation) | Basic HTTPS | Email/DNS verification |
| **OV** (Organization Validation) | Business sites | Company verification |
| **EV** (Extended Validation) | High-security | Thorough verification |

### Certificate Chain
```
Root CA (Certificate Authority)
    ↓
Intermediate CA 1
    ↓
Intermediate CA 2
    ↓
Server Certificate ← Your server
```

### Common File Formats
| Format | Extension | Use |
|--------|-----------|-----|
| PEM | .pem, .crt, .cer | Most common, text-based |
| DER | .der, .cer | Binary format |
| PKCS#12 | .p12, .pfx | Multiple certs + private key |
| PKCS#7 | .p7b, .p7c | Certificate chain |

---

## 🔧 OpenSSL Commands

### Generate Self-Signed Certificate
```bash
# Basic self-signed certificate (development only)
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# With subject alternatives (SAN)
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem \
    -days 365 -nodes \
    -addext "subjectAltName=DNS:example.com,DNS:www.example.com"

# With full details
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem \
    -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com"
```

### Generate CSR (Certificate Signing Request)
```bash
# Generate private key
openssl genrsa -out private.key 4096

# Generate CSR
openssl req -new -key private.key -out request.csr

# Generate CSR with SAN
openssl req -new -key private.key -out request.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com" \
    -addext "subjectAltName=DNS:example.com,DNS:www.example.com"

# View CSR
openssl req -in request.csr -text -noout
```

### View Certificate Details
```bash
# View certificate info
openssl x509 -in cert.pem -text -noout

# View in human-readable format
openssl x509 -in cert.pem -text -noout | head -30

# Check specific fields
openssl x509 -in cert.pem -subject -issuer -dates -noout

# Check subject alternative names
openssl x509 -in cert.pem -text | grep -A1 "Subject Alternative Name"

# Verify certificate matches private key
openssl x509 -noout -modulus -in cert.pem | openssl md5
openssl rsa -noout -modulus -in key.pem | openssl md5
# These should match!
```

### Certificate Format Conversion
```bash
# DER to PEM
openssl x509 -in cert.der -inform DER -outform PEM -out cert.pem

# PEM to DER
openssl x509 -in cert.pem -outform DER -out cert.der

# PEM to PKCS#12 (for IIS, Tomcat)
openssl pkcs12 -export -out certificate.p12 -inkey key.pem -in cert.pem

# PKCS#12 to PEM
openssl pkcs12 -in certificate.p12 -out cert.pem -nodes

# Combine certificate with chain
cat cert.pem intermediate.pem root.pem > fullchain.pem
```

### Check Certificate Expiry
```bash
# Check expiry date
openssl x509 -in cert.pem -dates -noout

# Days until expiry
openssl x509 -in cert.pem -noout -enddate

# Quick check (returns 0 if valid, 1 if expired)
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -checkend 0
```

### Test SSL Connection
```bash
# Basic connection test
openssl s_client -connect example.com:443

# Check specific cipher suites
openssl s_client -connect example.com:443 -cipher 'ECDHE-RSA-AES256-GCM-SHA384'

# Show full certificate chain
openssl s_client -showcerts -connect example.com:443

# Check TLS version
openssl s_client -tls1_2 -connect example.com:443
openssl s_client -tls1_3 -connect example.com:443

# Check SNI (Server Name Indication)
openssl s_client -servername example.com -connect example.com:443
```

---

## 🛡️ Let's Encrypt (Certbot)

### Installation
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install certbot python3-certbot-nginx
sudo apt install python3-certbot-apache

# CentOS/RHEL
sudo yum install certbot python3-certbot-nginx

# Standalone (no web server)
sudo certbot certonly --standalone -d example.com -d www.example.com
```

### Basic Usage with Web Servers
```bash
# Nginx
sudo certbot --nginx -d example.com -d www.example.com

# Apache
sudo certbot --apache -d example.com -d www.example.com

# Multiple domains
sudo certbot --nginx -d example.com -d www.example.com -d api.example.com
```

### Non-Interactive/Renewal
```bash
# Dry run (test renewal)
sudo certbot renew --dry-run

# Force renewal
sudo certbot renew --force-renewal

# Renew specific certificate
sudo certbot renew --cert-name example.com
```

### Manual DNS Challenge
```bash
# For wildcard certificates
sudo certbot certonly --manual \
    --preferred-challenges dns \
    -d example.com \
    -d *.example.com
```

### Certificate Management
```bash
# List certificates
sudo certbot certificates

# Delete certificate
sudo certbot delete --cert-name example.com

# Add domain to existing certificate
sudo certbot certonly --cert-name example.com -d newdomain.example.com

# Edit configuration
sudo certbot --nginx edit --cert-name example.com
```

---

## 🔐 Certificate Security

### Key Generation Best Practices
```bash
# RSA 4096-bit (widely compatible)
openssl genrsa -out key.pem 4096

# ECDSA P-256 (modern, faster)
openssl ecparam -genkey -name prime256v1 -out key.pem

# ECDSA P-384 (higher security)
openssl ecparam -genkey -name secp384r1 -out key.pem

# Ed25519 (modern, recommended)
openssl genpkey -algorithm Ed25519 -out key.pem
```

### Key Permissions
```bash
# Critical: Protect your private key!
chmod 600 key.pem
chmod 400 key.pem  # Even more restrictive

# Check permissions
ls -la key.pem
# Should show: -rw------- 1 root root ... key.pem
```

### Generate DH Parameters
```bash
# Generate DH parameters (for DHE ciphers)
openssl dhparam -out dhparam.pem 4096

# Modern alternative (FFDHE group)
# Use predefined groups from RFC 7919
```

---

## 📋 Automation Scripts

### Check Certificate Expiry Script
```bash
#!/bin/bash
# check_certs.sh - Monitor certificate expiry

set -euo pipefail

WARNING_DAYS=30
CRITICAL_DAYS=7

check_cert() {
    local cert_file="$1"
    local name="$2"
    
    local expiry=$(openssl x509 -in "$cert_file" -noout -enddate 2>/dev/null | cut -d= -f2)
    local expiry_epoch=$(date -d "$expiry" +%s)
    local now_epoch=$(date +%s)
    local days_left=$(( (expiry_epoch - now_epoch) / 86400 ))
    
    if [ $days_left -le 0 ]; then
        echo "🚨 CRITICAL: $name certificate EXPIRED!"
        return 2
    elif [ $days_left -le $CRITICAL_DAYS ]; then
        echo "🚨 CRITICAL: $name expires in $days_left days"
        return 2
    elif [ $days_left -le $WARNING_DAYS ]; then
        echo "⚠️  WARNING: $name expires in $days_left days"
        return 1
    else
        echo "✅ OK: $name expires in $days_left days"
        return 0
    fi
}

# Check multiple certificates
check_cert "/etc/letsencrypt/live/example.com/fullchain.pem" "Example.com"
check_cert "/etc/ssl/certs/server.crt" "Custom Cert"

exit_code=$?
exit $exit_code
```

### Auto-Renewal Script
```bash
#!/bin/bash
# renew_certs.sh

set -euo pipefail

LOGFILE="/var/log/cert-renewal.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

# Reload nginx after renewal
reload_services() {
    log "Reloading services..."
    systemctl reload nginx 2>/dev/null || true
    systemctl reload apache2 2>/dev/null || true
}

# Main
log "Starting certificate renewal..."

if certbot renew --quiet --deploy-hook "/usr/local/bin/reload-services.sh"; then
    log "Certificates renewed successfully"
    reload_services
else
    log "No certificates needed renewal"
fi
```

---

## 🧪 Troubleshooting

### Common Issues
```bash
# Issue: Certificate not trusted
# Solution: Install intermediate certificates
cat intermediate.pem >> fullchain.pem

# Issue: Private key doesn't match certificate
# Solution: Regenerate and get new certificate

# Issue: Name mismatch
# Solution: Check CN and SANs match the hostname

# Issue: Chain incomplete
# Solution: Include full certificate chain
cat cert.pem intermediate.pem > chain.pem

# Issue: Expired certificate
# Solution: Renew with certbot or regenerate
```

### Verify Installation
```bash
# Test with openssl
openssl s_client -connect example.com:443

# Check certificate chain
echo | openssl s_client -showcerts -connect example.com:443 2>/dev/null | grep "Certificate chain" -A 10

# Test specific TLS version
openssl s_client -tls1_2 -connect example.com:443
openssl s_client -tls1_3 -connect example.com:443

# Online check
# https://www.ssllabs.com/ssltest/
```

---

## 📊 Certificate Tools Comparison

| Tool | Purpose | Best For |
|------|---------|----------|
| **OpenSSL** | Everything CLI | Full control, scripting |
| **Certbot** | Let's Encrypt | Free automated certs |
| **acme.sh** | ACME protocol | Lightweight, docker |
| **Smallstep** | PKI | Internal CA |
| **CFSSL** | CloudFlare PKI | Scalable PKI |

---

## 🔒 Security Hardening

### Nginx SSL Configuration
```nginx
# /etc/nginx/snippets/ssl-params.conf

# SSL Protocols
ssl_protocols TLSv1.2 TLSv1.3;

# SSL Ciphers (Mozilla Intermediate)
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';

# Prefer server ciphers
ssl_prefer_server_ciphers on;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;

# HSTS (HTTP Strict Transport Security)
add_header Strict-Transport-Security "max-age=63072000" always;

# SSL Session
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;
```

### Apache SSL Configuration
```apache
# /etc/apache2/sites-available/ssl.conf

SSLEngine on
SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
SSLOpenSSLConfCmd TLSv1.2
SSLOpenSSLConfCmd Curves prime256v1

Header always set Strict-Transport-Security "max-age=63072000"
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
```

---

## 🎓 Final Project: The SSL/TLS Certificate Manager

Now that you've mastered the encryption protocols of the web, let's see how a professional Security Engineer might automate certificate management. We'll examine the "SSL/TLS Manager" — a tool that simplifies creating certificates, auditing expiration dates, and verifying secure configurations across your servers.

### What the SSL/TLS Certificate Manager Does:
1. **Generates Self-Signed Certificates** instantly for internal testing and development.
2. **Audits Certificate Information** (Subject, Issuer, Valid Dates) with a single command.
3. **Monitors Expiration Dates** to prevent service outages due to expired certs.
4. **Automates Let's Encrypt Workflows** by wrapping `certbot` for easy renewals.
5. **Performs SSL Health Checks** on remote domains to verify their encryption strength.
6. **Grades Security Configurations** by integrating with professional auditing APIs.

### Key Snippet: Monitoring Certificate Expiration
The manager uses `openssl` to extract the "enddate" from a certificate file and presents it in a human-readable format.

```bash
cmd_expire() {
    local cert_file=$1
    echo "=== Expiration Check for $cert_file ==="
    
    # 1. Extract the enddate field
    # 2. Use cut to remove the 'notAfter=' label
    local expiry=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
    
    echo "Certificate Expires on: $expiry"
    
    # Pro Tip: Run this in a cron job to email you 30 days 
    # before your production certificates expire!
}
```

### Key Snippet: Remote SSL Verification
Instead of opening a browser, the manager can verify the SSL configuration of any website directly from your terminal.

```bash
cmd_test() {
    local domain=$1
    echo "Testing SSL Connection for $domain..."
    
    # s_client: OpenSSL's tool for testing SSL connections
    # We pipe the output to 'x509' to extract just the summary info
    echo | openssl s_client -connect "$domain":443 2>/dev/null | \
        openssl x509 -noout -subject -issuer -dates
}
```

**Pro Tip:** Automating your certificate lifecycle is one of the best ways to improve the security and reliability of your entire infrastructure!

---

## ✅ Stack 52 Complete!

Congratulations! You've successfully encrypted the world! You can now:
- ✅ **Understand the SSL/TLS Handshake** and how encryption works
- ✅ **Manage SSL Certificates** (Generate, View, Verify) using OpenSSL
- ✅ **Automate Let's Encrypt** for free, professional-grade certificates
- ✅ **Audit expiration dates** to prevent embarrassing service outages
- ✅ **Configure secure servers** using Nginx and Apache best practices
- ✅ **Troubleshoot encryption issues** like a security professional

### What's Next?
In the next stack, we'll dive into **Terminal UI (TUI)**. You'll learn how to build beautiful, interactive graphical interfaces directly inside your Linux terminal!

**Next: Stack 53 - Terminal UI →**

---

*End of Stack 52*
-- **Previous:** [Stack 51 → DNS Management](51_dns_management.md)
-- **Next:** [Stack 53 - Terminal UI](53_terminal_ui.md)