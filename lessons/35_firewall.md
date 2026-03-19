# 🔥 STACK 35: FIREWALL & SECURITY
## Securing Your Linux System

---

## 🔰 Firewall Basics

A firewall controls incoming and outgoing network traffic based on rules.

### Types
| Type | Description |
|------|-------------|
| Host-based | Protects single machine |
| Network-based | Protects entire network |
| Software | iptables, nftables |
| Hardware | Appliance firewalls |

---

## 🛡️ UFW (Uncomplicated Firewall)

### Installation & Status
```bash
# Install
sudo apt install ufw

# Check status
sudo ufw status

# Default status
sudo ufw status verbose
```

### Basic Configuration
```bash
# Set defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable
```

### Common Rules
```bash
# Allow SSH
sudo ufw allow ssh
sudo ufw allow 22/tcp

# Allow specific port
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow port range
sudo ufw allow 6000:6005/tcp

# Allow from specific IP
sudo ufw allow from 192.168.1.100

# Allow from subnet
sudo ufw allow from 192.168.1.0/24

# Allow service on specific port to IP
sudo ufw allow from 192.168.1.0/24 to any port 22
```

### Delete Rules
```bash
# List numbered rules
sudo ufw status numbered

# Delete by number
sudo ufw delete 2

# Delete by rule
sudo ufw delete allow ssh
```

### Examples
```bash
# Web server
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp

# Disable ping (ICMP)
sudo ufw insert 1 deny in to any proto icmp
```

---

## 🔧 firewalld (RHEL/CentOS)

### Installation & Status
```bash
# Install
sudo dnf install firewalld

# Start service
sudo systemctl enable --now firewalld

# Check status
sudo firewall-cmd --status
```

### Basic Commands
```bash
# List zones
sudo firewall-cmd --list-all-zones

# Default zone
sudo firewall-cmd --get-default-zone

# Set default zone
sudo firewall-cmd --set-default-zone=public

# List active services
sudo firewall-cmd --list-services

# Add service
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Add port
sudo firewall-cmd --permanent --add-port=8080/tcp

# Remove
sudo firewall-cmd --permanent --remove-service=http

# Reload
sudo firewall-cmd --reload
```

---

## 🔒 iptables (Legacy)

### Basic Commands
```bash
# List rules
sudo iptables -L -v -n

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Drop everything else
sudo iptables -A INPUT -j DROP

# Save rules
sudo iptables-save > /etc/iptables/rules.v4
```

---

## 📜 Basic System Security

### Important Settings
```bash
# Disable unnecessary services
sudo systemctl stop cups
sudo systemctl disable cups

# Disable IPv6 (if not needed)
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

# Configure sysctl
sudo sysctl -p

# Limit fork bombs
echo "* hard nproc 1000" | sudo tee -a /etc/security/limits.conf
```

### SSH Security
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Key settings:
# Port 2222
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
# MaxAuthTries 3

# Restart SSH
sudo systemctl restart sshd
```

### Fail2ban Install
```bash
# Install
sudo apt install fail2ban

# Configure
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit
sudo nano /etc/fail2ban/jail.local
```

---

## 🔐 File Permissions

### Important Permissions
```bash
# Secure SSH keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

# Secure log files
chmod 640 /var/log/auth.log

# World-writable files (dangerous!)
find / -type f -perm -002 2>/dev/null

# Sticky bit on/tmp
chmod +t /tmp
```

---

## 🏆 Practice Exercises

### Exercise 1: Configure UFW
```bash
# Start fresh
sudo ufw disable

# Set defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp

# Allow web
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable
sudo ufw enable

# Check status
sudo ufw status verbose
```

### Exercise 2: SSH Security
```bash
# Backup config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Edit config
sudo nano /etc/ssh/sshd_config

# Change port
Port 2222

# Disable root login
PermitRootLogin no

# Restart
sudo systemctl restart sshd
```

### Exercise 3: Fail2ban
```bash
# Install
sudo apt install fail2ban

# Copy config
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit
sudo nano /etc/fail2ban/jail.local

# Set bantime, findtime

# Start
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status
```

---

## 📋 Firewall Cheat Sheet

| Command | Description |
|---------|-------------|
| `ufw status` | Check UFW status |
| `ufw allow` | Allow port |
| `ufw deny` | Deny port |
| `firewall-cmd` | Firewalld |
| `iptables` | Legacy iptables |

---

## ✅ Stack 35 Complete!

You learned:
- ✅ UFW setup and usage
- ✅ firewalld (RHEL/CentOS)
- ✅ Basic SSH security
- ✅ Fail2ban installation
- ✅ System hardening basics

### Next: Stack 36 - Terraform Basics →

---

*End of Stack 35*