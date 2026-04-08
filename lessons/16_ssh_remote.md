# 🌐 STACK 16: SSH & REMOTE MANAGEMENT
## Secure Remote Scripting

**What is SSH?** SSH (Secure Shell) is like a secure, encrypted phone line to another computer. Only you can "hear" the conversation, and no one can eavesdrop.

**SSH Key Analogy:** Think of SSH keys like a special lock and key:
- **Public key** = A padlock anyone can use to lock a box (put on the server)
- **Private key** = Only YOUR key opens that padlock (stays on your computer)
- No passwords needed - the lock and key do the authentication!

---

## 🔰 Why SSH?

SSH (Secure Shell) is essential for:
- ✅ **Remote access** - Securely manage servers anywhere in the world
- ✅ **File transfer** - Encrypted copying between computers
- ✅ **Tunneling** - Secure port forwarding (like a private tunnel through the internet)
- ✅ **Automation** - Run scripts on remote machines automatically
- ✅ **Security** - All communication is encrypted

### Real-World Use Case
You deploy a web app to a server in another country. SSH lets you:
1. Connect securely to that server
2. Run deployment scripts
3. Check logs and fix issues
4. All without leaving your terminal!

---

## ⚙️ SSH Installation & Basics

### Install SSH
```bash
# Ubuntu/Debian
sudo apt install openssh-server
sudo apt install openssh-client

# CentOS/RentOS
sudo yum install openssh-server
sudo dnf install openssh-server

# Start service
sudo systemctl start sshd
sudo systemctl enable sshd
```

### Basic Connection

**Step 1: Connect with a password**
```bash
# Basic connection
ssh user@hostname
ssh user@192.168.1.100

# Custom port (if server uses non-standard port)
ssh user@hostname -p 2222
```

**Step 2: Run a command and return**
```bash
# Run one command and get back to your shell
ssh user@hostname "uptime"
ssh user@hostname "df -h"

# Run multiple commands
ssh user@hostname "df -h && free -m"
```

**Pro Tip:** First time connecting to a server? SSH will ask to save the server's "fingerprint". This is normal - it prevents man-in-the-middle attacks!

---

## 🔐 SSH Key Management

### Generate SSH Keys
```bash
# Ed25519 (recommended - modern, fast, secure)
ssh-keygen -t ed25519 -C "your@email.com"

# RSA (legacy compatibility)
ssh-keygen -t rsa -b 4096 -C "your@email.com"

# Ed25519 with custom filename
ssh-keygen -t ed25519 -f ~/.ssh/work_key -C "work@email.com"

# RSA with passphrase (more secure)
ssh-keygen -t rsa -b 4096 -C "your@email.com"
# Enter passphrase when prompted
```

### Copy Key to Server
```bash
# Easy method (installs key automatically)
ssh-copy-id user@hostname
ssh-copy-id -i ~/.ssh/my_key.pub user@hostname

# Manual method
cat ~/.ssh/id_ed25519.pub | ssh user@hostname "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Verify permissions
ssh user@hostname "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

### SSH Agent
```bash
# Start agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_rsa

# List keys in agent
ssh-add -l

# Add to keychain (macOS)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Add to keychain (Linux)
ssh-add ~/.ssh/id_ed25519
# Add to ~/.bashrc or ~/.zshrc for auto-start:
# eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/id_ed25519 2>/dev/null
```

---

## 📡 Remote Command Execution

### Execute Single Command
```bash
# Simple command
ssh user@hostname "uptime"

# Multiple commands
ssh user@hostname "df -h && free -m && ps aux | head -5"

# With sudo (if configured)
ssh user@hostname "sudo systemctl restart nginx"
```

### Execute Local Script Remotely
```bash
# Method 1: Pipe script to bash
cat local_script.sh | ssh user@hostname "bash"

# Method 2: Redirect stdin
ssh user@hostname 'bash -s' < local_script.sh

# Method 3: Copy and execute
scp local_script.sh user@hostname:/tmp/
ssh user@hostname "bash /tmp/local_script.sh && rm /tmp/local_script.sh"

# Method 4: Execute with arguments
ssh user@hostname 'bash -s' -- < script.sh arg1 arg2
```

### Execute Commands on Multiple Servers
```bash
#!/bin/bash
# parallel_ssh.sh

SERVERS=("server1" "server2" "server3")
USER="deploy"
CMD="${1:-uptime}"

for server in "${SERVERS[@]}"; do
    echo "=== $server ==="
    ssh -o ConnectTimeout=5 "$USER@$server" "$CMD" &
done

wait
```

---

## 🔄 SSH Config for Easy Access

### Basic SSH Config
```bash
# ~/.ssh/config

# Simple server
Host myserver
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/id_rsa

# With custom options
Host prod
    HostName prod.example.com
    User deploy
    Port 22
    IdentityFile ~/.ssh/work_key
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Development server
Host dev
    HostName dev.example.com
    User developer
    IdentityFile ~/.ssh/dev_key
    ForwardAgent yes
```

### Advanced SSH Config
```bash
# ~/.ssh/config

# Default options for all hosts
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes
    IdentitiesOnly yes

# Jump server / Bastion
Host internal
    HostName 10.0.1.50
    User admin
    ProxyJump bastion@jump.example.com

# Through bastion host
Host behind-bastion
    HostName 192.168.1.100
    User app
    ProxyJump admin@bastion.example.com

# Multiple hops
Host final-destination
    HostName 10.0.2.50
    User admin
    ProxyJump user1@host1,user2@host2

# Port forwarding
Host tunnel
    HostName remote.server.com
    User admin
    LocalForward 8080 localhost:80
    RemoteForward 2222 localhost:22

# Git over SSH
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_key
```

### Using SSH Config Aliases
```bash
# Instead of: ssh -i ~/.ssh/key -p 2222 admin@192.168.1.100
# Just use:
ssh myserver

# For SCP:
scp file.txt myserver:/tmp/

# For rsync:
rsync -avz myserver:/var/www/ ./www/
```

---

## 🤖 SSH Automation Scripts

### Multi-Server Deploy Script
```bash
#!/bin/bash
# deploy.sh

set -euo pipefail

SERVERS=("prod1" "prod2" "prod3")
USER="deploy"
DEPLOY_DIR="/var/www/html"
TIMEOUT=30

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# Check for SSH timeout
ssh_opts="-o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no"

# Deploy to each server
for server in "${SERVERS[@]}"; do
    log "Deploying to $server..."
    
    # Copy files
    rsync -az --delete \
        -e "ssh $ssh_opts" \
        ./dist/ "$USER@$server:$DEPLOY_DIR/"
    
    # Run post-deploy commands
    ssh $ssh_opts "$USER@$server" "cd $DEPLOY_DIR && npm run build" || {
        error "Build failed on $server"
    }
    
    # Restart service
    ssh $ssh_opts "$USER@$server" "sudo systemctl restart nginx"
    
    log "Deployed to $server successfully"
done

log "Deployment complete!"
```

### Parallel Execution Script
```bash
#!/bin/bash
# parallel_exec.sh

set -euo pipefail

SERVERS=("server1" "server2" "server3")
USER="admin"
MAX_PARALLEL=5

run_on_server() {
    local server="$1"
    local cmd="$2"
    
    if ssh -o ConnectTimeout=10 "$USER@$server" "$cmd" 2>/dev/null; then
        echo "✓ $server: Success"
    else
        echo "✗ $server: Failed"
    fi
}

export -f run_on_server
export USER

# Run commands in parallel
printf '%s\n' "${SERVERS[@]}" | xargs -P "$MAX_PARALLEL" -I {} bash -c 'run_on_server "$@"' _ {} "$1"
```

### Health Check Script
```bash
#!/bin/bash
# health_check.sh

SERVERS=("web1" "web2" "db1")
USER="admin"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check_server() {
    local server="$1"
    
    # Check SSH connection
    if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$USER@$server" "exit 0" 2>/dev/null; then
        echo -e "${RED}✗ $server: SSH failed${NC}"
        return 1
    fi
    
    # Get stats
    stats=$(ssh "$USER@$server" "
        echo 'Uptime:'
        uptime -p 2>/dev/null || uptime
        echo 'Memory:'
        free -h | grep Mem
        echo 'Disk:'
        df -h / | tail -1
    " 2>/dev/null)
    
    echo -e "${GREEN}✓ $server${NC}"
    echo "$stats" | sed "s/^/   /"
}

for server in "${SERVERS[@]}"; do
    check_server "$server"
    echo ""
done
```

---

## ⛓ SSH Jump Server (ProxyJump)

### Basic Jump Server
```bash
# Through bastion host
ssh -J bastion@jump.example.com user@internal.host

# Or use config
Host internal-host
    HostName 10.0.1.100
    User admin
    ProxyJump bastion@jump.example.com
```

### Multiple Hops
```bash
# Three-hop connection
ssh -J user1@host1,user2@host2 user3@host3

# Config for multiple hops
Host final
    HostName 10.0.2.50
    User admin
    ProxyJump user1@host1,user2@host2
```

### Agent Forwarding
```bash
# Enable agent forwarding
ssh -A user@bastion

# In config
Host bastion
    ForwardAgent yes
```

---

## 🔒 SSH Security Best Practices

### Hardening SSH Daemon
```bash
# /etc/ssh/sshd_config.d/security.conf

# Disable password authentication
PasswordAuthentication no

# Disable root login
PermitRootLogin no

# Use only specific authentication
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Limit login attempts
MaxAuthTries 3

# Disable empty passwords
PermitEmptyPasswords no

# Banner
Banner /etc/ssh/banner

# Disable unused authentication methods
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no

# Connection settings
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 30

# Allow specific users
AllowUsers admin deploy

# Use strong ciphers
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com

# Restart SSH
sudo systemctl restart sshd
```

### Two-Factor Authentication
```bash
# Install Google Authenticator
sudo apt install libpam-google-authenticator

# Configure PAM
# Add to /etc/pam.d/sshd:
# auth required pam_google_authenticator.so

# Enable in sshd_config
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
```

### Fail2Ban Configuration
```bash
# Install Fail2Ban
sudo apt install fail2ban

# Configure
sudo cat > /etc/fail2ban/jail.local << 'EOF'
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

sudo systemctl restart fail2ban
```

---

## 📁 Secure File Transfer

### SCP Commands
```bash
# Copy to remote
scp file.txt user@host:/tmp/
scp -r folder/ user@host:~/

# Copy from remote
scp user@host:/var/log/syslog ./

# Copy between remote servers
scp -3 user1@host1:/file user2@host2:/

# With compression
scp -Cr folder/ user@host:~/

# With progress
rsync -avz --progress folder/ user@host:~/
```

### SFTP
```bash
# Interactive SFTP
sftp user@hostname

# SFTP commands
sftp> ls
sftp> cd /remote/path
sftp> put local.txt
sftp> get remote.txt
sftp> bye
```

### Rsync over SSH
```bash
# Sync local to remote
rsync -avz --delete ./folder/ user@host:/remote/folder/

# Sync with exclude
rsync -avz --exclude '*.log' --exclude '.git' ./ user@host:/app/

# Sync with dry-run
rsync -avzn ./ user@host:/app/

# Sync with bandwidth limit
rsync -avz --bwlimit=1000 ./ user@host:/app/
```

---

## 🔌 SSH Tunnels

### Local Port Forwarding
```bash
# Forward local 8080 to remote localhost:80
ssh -L 8080:localhost:80 user@remote-host

# Forward local 3306 to remote MySQL
ssh -L 3306:localhost:3306 user@remote-host

# Forward to different remote
ssh -L 8080:remote-internal:80 user@bastion-host
```

### Remote Port Forwarding
```bash
# Forward remote 8080 to local localhost:80
ssh -R 8080:localhost:80 user@remote-host
```

### Dynamic SOCKS Proxy
```bash
# Create SOCKS proxy on local port 1080
ssh -D 1080 user@bastion-host

# Use with curl
curl --socks5 localhost:1080 https://example.com
```

### SSH Tunnel Script
```bash
#!/bin/bash
# create_tunnel.sh

LOCAL_PORT="${1:-8080}"
REMOTE_HOST="${2:-localhost}"
REMOTE_PORT="${3:-80}"
TUNNEL_HOST="${4:-user@bastion-host}"

echo "Creating tunnel: localhost:$LOCAL_PORT -> $TUNNEL_HOST -> $REMOTE_HOST:$REMOTE_PORT"

# Create tunnel in background
ssh -N -L "$LOCAL_PORT":"$REMOTE_HOST":"$REMOTE_PORT" "$TUNNEL_HOST" &

TUNNEL_PID=$!
echo "Tunnel PID: $TUNNEL_PID"
echo "Tunnel established on localhost:$LOCAL_PORT"

# Save PID for later
echo "$TUNNEL_PID" > /tmp/ssh_tunnel.pid

# Trap to cleanup
trap "kill $TUNNEL_PID; rm /tmp/ssh_tunnel.pid" EXIT
```

---

## 📊 SSH Troubleshooting

### Common Issues
```bash
# Connection refused
# Check SSH service: sudo systemctl status sshd
# Check firewall: sudo ufw status

# Permission denied (publickey)
# Check key: ssh -v user@host
# Verify authorized_keys: cat ~/.ssh/authorized_keys

# Host key verification failed
# Remove old key: ssh-keygen -R hostname

# Connection timeout
# Check network: ping hostname
# Check DNS: nslookup hostname
```

### Debug Connection
```bash
# Verbose mode
ssh -vvv user@hostname

# Check key agent
ssh-add -l
eval "$(ssh-agent -s)"
ssh-add

# Test key directly
ssh -i ~/.ssh/specific_key -v user@host
```

### SSH Keep Alive
```bash
# Client-side keep alive
# ~/.ssh/config
ServerAliveInterval 60
ServerAliveCountMax 3

# Server-side keep alive
# /etc/ssh/sshd_config
ClientAliveInterval 60
ClientAliveCountMax 3
```

---

## 🔐 SSH Best Practices Checklist

```bash
# Use key-based authentication (no passwords!)
# ✓ Use Ed25519 or RSA 4096-bit keys
# ✓ Use SSH agent for convenience
# ✓ Protect private keys with passphrases
# ✓ Use SSH config for aliases
# ✓ Disable password authentication
# ✓ Disable root login
# ✓ Use fail2ban
# ✓ Use jump hosts for internal networks
# ✓ Use specific ciphers
# ✓ Rotate keys regularly
# ✓ Use different keys for different purposes
# ✓ Never commit private keys to git
```

---

## 🎓 Final Project: SSH Manager

Now that you've mastered SSH basics, let's see how a professional system administrator might automate remote management. We'll examine the "SSH Manager" — a tool that simplifies connecting to servers, managing keys, and setting up secure tunnels.

### What the SSH Manager Does:
1. **Simplifies Connections** by using aliases and saved configurations.
2. **Executes Remote Commands** across one or multiple servers.
3. **Automates Key Management** (generating keys and copying them to servers).
4. **Manages SSH Config** programmatically (no manual editing needed).
5. **Sets up SSH Tunnels** for secure port forwarding with simple commands.
6. **Handles File Transfers** using simplified SCP and SFTP wrappers.

### Key Snippet: Programmatic Key Generation
A good manager script can handle the nuances of key generation, like setting the correct permissions automatically.

```bash
cmd_keygen() {
    local key_path="$HOME/.ssh/id_ed25519"
    
    # Generate modern Ed25519 key
    ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$key_path"
    
    # Set strict permissions (SSH requires this!)
    chmod 700 "$HOME/.ssh"
    chmod 600 "$key_path"
    chmod 644 "${key_path}.pub"
}
```

### Key Snippet: SSH Tunneling Made Simple
Instead of remembering complex `ssh -L` flags, the manager provides a clear command:

```bash
cmd_tunnel_local() {
    local host=$1
    local port=$2
    
    log "Forwarding local port $port to $host..."
    # -L: Local port forwarding
    ssh -L "$port:localhost:$port" "$host"
}
```

**Pro Tip:** By wrapping these commands in a script, you reduce the risk of typos that could lead to connection failures or security vulnerabilities.

---

## ✅ Stack 16 Complete!

Congratulations! You've unlocked the ability to control computers across the globe! You can now:
- ✅ **Securely connect** to remote servers using SSH
- ✅ **Master SSH Keys** for passwordless, secure logins
- ✅ **Execute commands** on remote machines from your local terminal
- ✅ **Automate file transfers** using SCP and SFTP
- ✅ **Create SSH Configs** for easy, one-word connections
- ✅ **Build secure tunnels** to bypass firewalls and access private services

### What's Next?
In the next stack, we'll dive into **Network Scripting**. You'll learn how to diagnose network issues, scan ports, and automate network-related tasks like a pro!

**Next: Stack 17 - Network Scripting →**

---

*End of Stack 16*
- **Previous:** [Stack 15 → Docker & Bash](15_docker_bash.md)
- **Next:** [Stack 17 - Network Scripting](17_network_scripting.md) 