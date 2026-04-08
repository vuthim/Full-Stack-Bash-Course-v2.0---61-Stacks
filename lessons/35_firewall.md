# 🔥 STACK 35: FIREWALL & SECURITY
## Securing Your Linux System

**What is a Firewall?** Think of a firewall as a security guard at your door. It checks every visitor (network packet) against a list of rules: "You can come in, you can't, you need an appointment..."

**Why This Matters:** Without a firewall, every port on your system is open to the entire internet. That's like leaving every window and door of your house unlocked!

---

## 🔰 Firewall Basics

A firewall controls incoming and outgoing network traffic based on rules.

### Types of Firewalls
| Type | What It Protects | Examples |
|------|------------------|----------|
| **Host-based** | Protects a single machine | UFW, iptables, firewalld |
| **Network-based** | Protects entire network | Router firewalls, cloud security groups |
| **Software** | Runs on your OS | iptables, nftables |
| **Hardware** | Physical appliance firewalls | Cisco ASA, pfSense |

### The Firewall Mindset
```
Default policy: DENY everything
Then: ALLOW only what you need

Like a bouncer: "You're not on the list? Sorry, not getting in!"
```

**⚠️ Security First:** Always test firewall rules before applying! A bad rule can lock YOU out of your own server (especially over SSH)!

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

## 🎓 Final Project: Universal Firewall Manager

Now that you've mastered the concepts of network security, let's see how a professional security engineer might build a cross-platform tool. We'll examine the "Firewall Manager" — a script that automatically detects which firewall your system is using (UFW, Firewalld, or Iptables) and provides a single, simple command-line interface to manage them all.

### What the Universal Firewall Manager Does:
1. **Auto-Detects Firewall Engine** (identifies if the system uses `ufw`, `firewalld`, or standard `iptables`).
2. **Standardizes Allow/Deny Rules** (use `allow 80` regardless of the underlying tool).
3. **Manages Services** by name (e.g., `allow http` or `allow ssh`).
4. **Simplifies Lifecycle Management** (enabling, disabling, and resetting).
5. **Provides a Unified Status** showing active rules in a readable format.
6. **Persists Changes** by automatically reloading or saving rules as needed.

### Key Snippet: Firewall Engine Detection
Just like our package manager, the firewall tool needs to know "who is in charge" before it can send commands.

```bash
detect_firewall() {
    # Check for the presence of common firewall management commands
    if command -v ufw &>/dev/null; then
        echo "ufw"         # Common on Ubuntu/Debian
    elif command -v firewall-cmd &>/dev/null; then
        echo "firewalld"   # Common on Fedora/CentOS/RHEL
    elif command -v iptables &>/dev/null; then
        echo "iptables"    # The "classic" Linux firewall
    else
        echo "none"
    fi
}
```

### Key Snippet: Standardized Rule Creation
The manager uses a `case` statement to translate your simple "allow" request into the specific syntax required by the detected engine.

```bash
cmd_allow() {
    local port=$1
    local fw=$(detect_firewall)
    
    case $fw in
        ufw)
            sudo ufw allow "$port"/tcp
            ;;
        firewalld)
            # Add port permanently AND reload the config
            sudo firewall-cmd --add-port="$port"/tcp --permanent
            sudo firewall-cmd --reload
            ;;
        iptables)
            # Add a raw rule to the INPUT chain
            sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
            ;;
    esac
    log "Access allowed to port $port/tcp."
}
```

**Pro Tip:** Automation like this is the secret to maintaining security across a fleet of servers running different Linux distributions!

---

## ✅ Stack 35 Complete!

Congratulations! You've successfully built a "digital shield" around your system! You can now:
- ✅ **Manage system firewalls** like a pro using UFW and Firewalld
- ✅ **Secure your services** by allowing only necessary ports (HTTP, SSH, etc.)
- ✅ **Protect against attacks** by denying unauthorized traffic
- ✅ **Audit your security rules** to ensure your system is properly hardened
- ✅ **Automate firewall changes** across different Linux distributions
- ✅ **Understand the difference** between stateless and stateful firewalls

### What's Next?
In the next stack, we'll dive into **Terraform Basics**. You'll learn how to treat your entire infrastructure as code, allowing you to build and destroy entire clouds with a single command!

**Next: Stack 36 - Terraform Basics →**

---

*End of Stack 35*