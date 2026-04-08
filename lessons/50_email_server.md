# 📧 STACK 50: EMAIL SERVER
## Running Your Own Mail Server

**What is an Email Server?** Think of it like running your own post office. Instead of relying on Gmail or Outlook, YOU control the mailboxes, rules, and delivery. It's complex but gives you complete control and privacy.

**⚠️ Reality Check:** Running an email server is one of the MORE complex Linux tasks. Spam filtering, deliverability, and security are ongoing challenges. Start in a lab environment before production!

---

## 🔰 Email Server Components

### What Makes an Email System?
| Component | What It Does | Popular Options | Analogy |
|-----------|--------------|-----------------|---------|
| **MTA** | Mail Transfer Agent (sends/receives mail between servers) | Postfix, Exim | The mail truck (transports mail) |
| **MDA** | Mail Delivery Agent (delivers to individual mailboxes) | Dovecot, Procmail | The mail carrier (sorts to boxes) |
| **MUA** | Mail User Agent (what YOU read mail with) | Thunderbird, Outlook | Your mailbox at home |
| **IMAP/POP3** | Protocols for retrieving email | IMAP (syncs), POP3 (downloads) | How you check your mail |

### Email Flow (Simplified)
```
You compose email → MTA sends it → Internet → Recipient's MTA → MDA delivers → Their MUA shows it
```

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

## 🎓 Final Project: The Enterprise Mail Server Manager

Now that you've mastered the protocols of the email world, let's see how a professional Mail Administrator might automate their daily operations. We'll examine the "Mail Server Manager" — a tool that provides a unified interface for managing both Postfix (sending) and Dovecot (receiving) services.

### What the Enterprise Mail Server Manager Does:
1. **Provides a Unified Status** showing the health of both Postfix and Dovecot.
2. **Simplifies Lifecycle Management** (Start, Stop, Restart) for all mail services at once.
3. **Audits the Mail Queue** to identify stuck messages or delivery delays.
4. **Automates Service Reloading** ensuring configuration changes take effect safely.
5. **Performs Delivery Tests** by sending automated test emails to verify the system.
6. **Checks User Mailboxes** to confirm that mail is being received correctly.

### Key Snippet: Auditing the Mail Queue
The manager uses the `mailq` or `postqueue` commands to give you an instant report on any messages that haven't been delivered yet.

```bash
cmd_queue() {
    echo "=== Current Mail Delivery Queue ==="
    
    # Try the classic mailq first, fallback to postqueue
    if ! mailq 2>/dev/null; then
        postqueue -p
    fi
    
    # Pro Tip: A large queue usually means your server is blocked 
    # or the internet connection is down!
}
```

### Key Snippet: Automated Delivery Testing
One of the best ways to ensure a server is working is to actually use it. The manager can send a "pulse" email to any address you specify.

```bash
cmd_test() {
    local destination=$1
    local subject="Server Pulse Check: $(hostname)"
    
    # Use the 'mail' command to send a simple message
    echo "This is an automated test from your Mail Server Manager." | \
        mail -s "$subject" "$destination"
    
    log "Test email dispatched to $destination successfully."
}
```

**Pro Tip:** Managing mail servers is notoriously complex. Building a manager like this is the only way to stay sane when managing high-volume enterprise email!

---

## ✅ Stack 50 Complete!

Congratulations! You've successfully built your own professional communication hub! You can now:
- ✅ **Setup and configure Postfix** for high-performance SMTP delivery
- ✅ **Install Dovecot** to provide IMAP and POP3 access to users
- ✅ **Secure your mail server** with SSL/TLS encryption
- ✅ **Manage the mail queue** and troubleshoot delivery issues
- ✅ **Automate delivery testing** to ensure 100% uptime
- ✅ **Navigate the world of DNS** (SPF, DKIM, DMARC) for email reliability

### What's Next?
In the next stack, we'll dive into **DNS Management**. You'll learn how to manage the "Phonebook of the Internet" and configure your own domain names like a network professional!

**Next: Stack 51 - DNS Management →**

---

*End of Stack 50*
-- **Previous:** [Stack 49 → High Availability](49_high_availability.md)  
-- **Next:** [Stack 51 - DNS Management](51_dns_management.md)