# 📧 STACK 50: EMAIL SERVER
## Running Your Own Mail Server

---

## 🔰 Email Server Components

### What Makes an Email System?
| Component | Purpose |
|-----------|---------|
| MTA | Mail Transfer Agent (Postfix, Exim) |
| MDA | Mail Delivery Agent (Dovecot) |
| MUA | Mail User Agent (Thunderbird) |
| IMAP/POP3 | Retrieval protocols |

---

## ⚙️ Postfix Installation

### Basic Setup
```bash
# Install
sudo apt install postfix postfix-pcre

# Choose "Internet Site"
# Set system mail name: example.com
```

### Main Configuration
```ini
# /etc/postfix/main.cf

# Hostname
myhostname = mail.example.com
mydomain = example.com
myorigin = $mydomain
mydestination = $myhostname, localhost, localhost.localdomain

# Network settings
inet_interfaces = all
inet_protocols = ipv4

# Mail queue
home_mailbox = Maildir/
mailbox_command =

# Size limits (50MB attachments)
message_size_limit = 52428800
```

---

## 🔐 SMTP Authentication

### SASL Setup
```bash
# Install SASL
sudo apt install libsasl2-2 sasl2-bin

# Configure Postfix
# /etc/postfix/main.cf
smtpd_sasl_auth_enable = yes
smtpd_sasl_path = smtpd
smtpd_sasl_security_options = noanonymous
smtpd_sasl_local_domain = $myhostname
broken_sasl_auth_clients = yes

# Restrict to authenticated users
smtpd_recipient_restrictions =
    permit_sasl_authenticated,
    permit_mynetworks,
    reject_unauth_destination
```

### Create SASL Users
```bash
# Create user database
sudo saslpasswd2 -c -u mail.example.com username

# View users
sudo sasldblistusers2

# Set permissions
sudo chown postfix:postfix /etc/sasl2
```

---

## 📥 Dovecot Setup (IMAP/POP3)

### Installation
```bash
sudo apt install dovecot-core dovecot-imapd dovecot-pop3d
```

### Configuration
```ini
# /etc/dovecot/conf.d/10-mail.conf
mail_location = maildir:~/Maildir

# /etc/dovecot/conf.d/10-auth.conf
auth_mechanisms = plain login

# /etc/dovecot/conf.d/10-ssl.conf
ssl = required
ssl_cert = </etc/ssl/certs/mail.pem
ssl_key = </etc/ssl/private/mail.key
```

### Master Users
```ini
# /etc/dovecot/master-users
admin:$1$salt$hash  # App accounts
```

---

## 🛡️ SSL/TLS Configuration

### Generate Certificates
```bash
# Self-signed
sudo openssl req -new -x509 -days 365 -nodes \
    -out /etc/ssl/certs/mail.pem \
    -keyout /etc/ssl/private/mail.key

# Or use Let's Encrypt
sudo apt install certbot
sudo certbot certonly --standalone -d mail.example.com
```

### Postfix TLS
```ini
# /etc/postfix/main.cf
smtpd_tls_cert_file = /etc/ssl/certs/mail.pem
smtpd_tls_key_file = /etc/ssl/private/mail.key
smtpd_tls_security_level = may

# For submission (port 587)
submission inet n - - - - smtpd
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
```

---

## 🔍 Mail Queue Management

### Queue Commands
```bash
# View queue
postqueue -p

# Force delivery
postqueue -f

# Delete message
postsuper -d MESSAGE_ID

# Hold message
postsuper -h MESSAGE_ID

# Release
postsuper -H MESSAGE_ID
```

---

## 📝 Testing Email

### Test Script
```bash
#!/bin/bash
# test_mail.sh

# Send test email
echo "Test email body" | mail -s "Test Subject" user@example.com

# Check queue
postqueue -p

# View logs
tail -f /var/log/mail.log
```

### External Testing
```bash
# Verify SPF
dig txt example.com

# Verify DKIM
selector._domainkey.example.com

# Test from outside
telnet mail.example.com 25
```

---

## 🏆 Practice Exercises

### Exercise 1: Install Postfix
```bash
# Install
sudo apt install postfix

# Configure
sudo dpkg-reconfigure postfix

# Test sending
echo "Test" | mail -s "Test" root
tail /var/log/mail.log
```

### Exercise 2: Add IMAP (Dovecot)
```bash
# Install
sudo apt install dovecot-imapd

# Configure
sudo nano /etc/dovecot/dovecot.conf

# Restart
sudo systemctl restart dovecot

# Test
telnet localhost 143
```

### Exercise 3: Secure with TLS
```bash
# Generate cert
sudo openssl req -new -x509 -days 365 \
    -out /etc/ssl/certs/mail.pem \
    -keyout /etc/ssl/private/mail.key

# Configure Postfix
sudo postconf -e "smtpd_tls_cert_file=/etc/ssl/certs/mail.pem"
sudo postconf -e "smtpd_tls_key_file=/etc/ssl/private/mail.key"

# Reload
sudo systemctl reload postfix
```

---

## 📋 Email Commands

| Command | Description |
|---------|-------------|
| `mail` | Send email |
| `mutt` | Email client |
| `postqueue` | Queue management |
| `postsuper` | Queue control |

---

## ✅ Stack 50 Complete!

You learned:
- ✅ Email server components
- ✅ Postfix installation and config
- ✅ SMTP authentication
- ✅ Dovecot for IMAP/POP3
- ✅ SSL/TLS setup
- ✅ Queue management

### Next: Stack 51 - DNS Management →

---

*End of Stack 50*