# 🌐 STACK 16: SSH & REMOTE MANAGEMENT
## Secure Remote Scripting

---

## 🔰 SSH Fundamentals

```bash
# Connect to server
ssh user@hostname
ssh -p 2222 user@hostname    # Custom port

# SSH with key
ssh -i ~/.ssh/my_key user@host

# Copy files over SSH
scp file.txt user@host:/tmp/
scp -r folder/ user@host:~/

# SSH with tunnel
ssh -L 8080:localhost:80 user@host
```

---

## 🔐 SSH Key Management

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Copy key to server
ssh-copy-id user@hostname

# Or manually
cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

---

## 📡 Remote Command Execution

```bash
# Run command on remote
ssh user@host "uptime"
ssh user@host "df -h"

# Run local script on remote
cat script.sh | ssh user@host "bash"

# Remote script execution
ssh user@host 'bash -s' < local_script.sh
```

---

## 🔄 SSH Config for Easy Access

```bash
# ~/.ssh/config
Host myserver
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/id_rsa

Host prod
    HostName prod.example.com
    User deploy
    ProxyJump jump-server
```

```bash
# Now connect easily
ssh myserver
ssh prod
```

---

## 🔒 SSH Security Best Practices

```bash
# Disable password auth
sudo cat > /etc/ssh/sshd_config.d/security.conf << 'EOF'
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
MaxAuthTries 3
EOF

# Restart SSH
sudo systemctl restart sshd
```

---

## 🤖 SSH Automation Script

```bash
#!/bin/bash
# deploy.sh - Deploy to multiple servers

SERVERS=("server1" "server2" "server3")
USER="deploy"
SCRIPT="/tmp/update.sh"

for server in "${SERVERS[@]}"; do
    echo "Deploying to $server..."
    ssh -o ConnectTimeout=10 $USER@$server "bash -s" < $SCRIPT
    echo "$server deployed!"
done
```

---

## ⛓ SSH Jump Server (ProxyJump)

```bash
# Through bastion host
ssh -J bastion@jump.example.com user@internal.host

# Multiple jumps
ssh -J user1@host1,user2@host2 final@host3
```

---

## 📊 Remote Monitoring Script

```bash
#!/bin/bash
# monitor_remote.sh

HOSTS=("web1" "web2" "db1")

for host in "${HOSTS[@]}"; do
    echo "=== $host ==="
    ssh $host "echo 'Memory:'; free -h | grep Mem; echo 'Uptime:'; uptime"
done
```

---

## 🏆 Practice: Create Deployment Script

```bash
# 1. Create deploy script
cat > deploy.sh << 'EOF'
#!/bin/bash
echo "Deploying to $(hostname)..."
git pull
./build.sh
systemctl restart myapp
echo "Deployed!"
EOF

# 2. Deploy to servers
for server in prod1 prod2 prod3; do
    ssh admin@$server "mkdir -p /app"
    scp deploy.sh admin@$server:/app/
    ssh admin@$server "chmod +x /app/deploy.sh && /app/deploy.sh"
done
```

---

## ✅ Stack 16 Complete!