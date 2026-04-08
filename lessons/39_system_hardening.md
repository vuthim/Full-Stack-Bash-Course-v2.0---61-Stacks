# 🔒 STACK 39: SYSTEM HARDENING
## Securing Your Linux System

**What is System Hardening?** Think of hardening like fortifying a house: you lock doors, close windows, install alarms, and remove ladders that burglars could use. System hardening means closing every unnecessary entry point and tightening security.

**⚠️ WARNING:** Hardening changes can break things. Always:
1. Test on a non-production system first
2. Document every change you make
3. Have a rollback plan
4. Keep SSH access open while testing (don't lock yourself out!)

---

## 🔰 Why Hardening?

System hardening reduces attack surface and protects against common vulnerabilities.

### The Attack Surface Analogy
```
A fresh Linux install is like a house with all windows and doors open
Hardening = Close what you don't need, lock what you do, monitor the rest

Each unnecessary service/ports = An open window a burglar could use
```

### Key Hardening Areas
| Area | What It Means | Why It Matters |
|------|--------------|----------------|
| **Kernel parameters** | OS-level security settings | Prevents certain types of attacks |
| **File permissions** | Who can read/write/execute | Stops unauthorized access |
| **User access** | Who can log in, what they can do | Limits damage from compromised accounts |
| **Services** | What's running and listening | Fewer services = fewer entry points |
| **Network settings** | Firewall, IP forwarding, etc. | Controls traffic flow |
| **Logging and monitoring** | Recording what happens | Detects and helps investigate breaches |

---

## ⚙️ Kernel Hardening

### sysctl Configuration
```bash
# /etc/sysctl.conf

# Network hardening
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Disable ICMP redirect acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Log suspicious packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Disable packet forwarding
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
```

```bash
# Apply
sudo sysctl -p
```

---

## 👤 User Access Hardening

### Password Policies
```bash
# Install libpam-cracklib
sudo apt install libpam-cracklib

# Edit PAM password config
sudo nano /etc/pam.d/common-password
# Add: password required pam_cracklib.so retry=3 minlen=12 difok=3

# Login history
echo "HISTTIMEFORMAT=\"%F %T \"" >> ~/.bashrc
readonly HISTSIZE=1000
readonly HISTFILESIZE=2000
```

### Disable Unnecessary Users
```bash
# Lock accounts
sudo passwd -l lp
sudo passwd -l games
sudo passwd -l news

# Remove unneeded shells
sudo usermod -s /sbin/nologin ftp
```

---

## 📁 File System Hardening

### Mount Options
```bash
# /etc/fstab
# /tmp with noexec,nosuid,nodev
UUID=xxx /tmp ext4 defaults,noexec,nosuid,nodev 0 2

# /var with nosuid,nodev
UUID=xxx /var ext4 defaults,nosuid,nodev 0 2

# Separate /var/log
UUID=xxx /var/log ext4 defaults,nosuid,nodev 0 2
```

### Permissions
```bash
# Secure important files
chmod 600 /etc/passwd
chmod 600 /etc/shadow
chmod 644 /etc/group

# World-writable files
find / -type f -perm -0002 -print 2>/dev/null

# Set sticky bits
chmod +t /tmp
chmod +t /var/tmp
```

---

## 🔌 Network Hardening

### SSH Hardening
```bash
# /etc/ssh/sshd_config
Port 2222
Protocol 2
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
X11Forwarding no
AllowUsers user1 user2
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60

# Reload
sudo systemctl reload sshd
```

### Firewall
```bash
# UFW defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

---

## 📦 Service Hardening

### Disable Unnecessary Services
```bash
# List services
systemctl list-unit-files

# Disable
sudo systemctl disable cups
sudo systemctl disable bluetooth
sudo systemctl mask cups
```

### TCP Wrappers
```bash
# /etc/hosts.deny
ALL: ALL

# /etc/hosts.allow
sshd: 192.168.1.0/24
```

---

## 🔍 Logging and Monitoring

### Auditd
```bash
# Install
sudo apt install auditd

# Configure rules
sudo nano /etc/audit/audit.rules

# Monitor important files
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/ssh/sshd_config -p wa -k ssh_changes

# Restart auditd
sudo systemctl restart auditd
```

### AIDE (File Integrity)
```bash
# Install
sudo apt install aide

# Initialize
sudo aideinit

# Check
sudo aide --check
```

---

## 🔄 Automated Hardening Scripts

### Hardening Script
```bash
#!/bin/bash
# harden.sh

echo "Starting system hardening..."

# Update system
apt update && apt upgrade -y

# Configure sysctl
cat > /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
EOF

sysctl -p

# Create non-root user
adduser admin

# Configure SSH
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

# Enable UFW
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

echo "Hardening complete!"
```

---

## 📋 Hardening Checklist

| Area | Action |
|------|--------|
| Kernel | Configure sysctl |
| Network | Disable unused ports |
| SSH | Disable root login |
| Users | Strong passwords |
| Files | Set correct permissions |
| Services | Disable unused |
| Monitoring | Enable logging |

---

## 🏆 Practice Exercises

### Exercise 1: Apply sysctl Settings
```bash
# Apply network hardening
cat > /tmp/harden.conf << 'EOF'
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
EOF

sudo cp /tmp/harden.conf /etc/sysctl.d/10-hardening.conf
sudo sysctl -p /etc/sysctl.d/10-hardening.conf
```

### Exercise 2: Secure SSH
```bash
# Backup config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Edit config
sudo nano /etc/ssh/sshd_config

# Test config
sudo sshd -t

# Restart
sudo systemctl restart sshd
```

### Exercise 3: Create Non-Root User
```bash
# Create admin user
sudo useradd -m -s /bin/bash -G sudo admin

# Set password
sudo passwd admin

# Generate SSH key
ssh-keygen -t ed25519 -C "admin@server"

# Copy to server
ssh-copy-id admin@server
```

---

## 🎓 Final Project: System Security Hardening Tool

Now that you've mastered the concepts of system hardening, let's see how a professional security engineer might automate the lockdown of their servers. We'll examine the "Security Hardening Tool" — a script that performs a full security audit, checks for vulnerabilities, and enforces strict permission policies automatically.

### What the System Security Hardening Tool Does:
1. **Performs a Full Security Audit** showing system info, open ports, and failed logins.
2. **Audits Critical File Permissions** (e.g., `/etc/shadow`) to ensure they are secure.
3. **Identifies SUID Files** which are common targets for "privilege escalation" attacks.
4. **Hardens SSH Configuration** by disabling root login and password authentication.
5. **Enforces Firewall Policies** (UFW or Firewalld) to deny all unauthorized incoming traffic.
6. **Audits User Accounts** for inactive users who may need to be locked.

### Key Snippet: Securing SSH with Sed
Manually editing `/etc/ssh/sshd_config` is slow and error-prone. The hardener uses `sed` to search for and replace insecure settings with one command.

```bash
cmd_secure_ssh() {
    log "Hardening SSH configuration..."
    local config="/etc/ssh/sshd_config"
    
    # -i: edit the file in-place
    # s/^#*Old/New/: find the line (even if commented) and replace it
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$config"
    sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$config"
    
    # Restart the service to apply changes
    sudo systemctl restart sshd
}
```

### Key Snippet: Auditing Open Ports
The hardener provides a clean list of exactly what is "listening" on your network, making it easy to spot unauthorized services.

```bash
cmd_audit() {
    echo "=== Network Audit ==="
    # ss -tlnp: show TCP, Listening, Numeric ports, and Process info
    ss -tlnp 2>/dev/null | grep LISTEN || \
        echo "Error: Could not perform network audit."
}
```

**Pro Tip:** Running a hardening script like this on every new server ensures a "security baseline" that keeps your infrastructure protected from the moment it's created!

---

## ✅ Stack 39 Complete!

Congratulations! You've successfully built a "fortress" for your Linux system! You can now:
- ✅ **Perform professional security audits** on any Linux server
- ✅ **Harden your SSH configuration** to prevent brute-force attacks
- ✅ **Secure critical system files** (Passwd, Shadow, Group)
- ✅ **Enforce strict firewall policies** using UFW or Firewalld
- ✅ **Identify and manage SUID files** to prevent privilege escalation
- ✅ **Monitor failed logins** and audit active user accounts

### What's Next?
In the next stack, we'll dive into **GitLab CI/CD**. You'll learn how to build professional pipelines within the GitLab ecosystem to automate your entire testing and deployment workflow!

**Next: Stack 40 - GitLab CI/CD →**

---

*End of Stack 39*
-- **Previous:** [Stack 38 → Ansible Essentials](38_ansible.md)
-- **Next:** [Stack 40 - GitLab CI/CD](40_gitlab_ci.md)