# 🎬 Video Companion Guide
## Scripted Explanations for Complex Topics

This guide provides ready-to-use scripts for creating video tutorials covering the most complex topics in the Bash course.

---

## 📹 Video Production Tips

### Recording Setup
- Use OBS Studio for screen recording
- Terminal: Use a dark theme (Dracula, Monokai)
- Font: Use a readable monospace font (Fira Code, JetBrains Mono)
- Font size: 14-18pt for readability
- Terminal window: 80x24 minimum

### Recording Commands
```bash
# Record terminal session with asciinema
asciinema rec bash-course.cast

# Or use OBS with these settings:
# - Capture: Windowed mode
# - Resolution: 1920x1080
# - Frame rate: 30fps
# - Codec: H264, CRF 20
```

### Editing Tips
- Cut long pauses
- Add annotations for key points
- Use arrows/highlights for important commands
- Add chapter markers

---

## 🎬 VIDEO 1: Advanced Scripting Deep Dive
### Stack 12: Professional Bash Techniques

**Duration**: 15-20 minutes

### Script

```
[OPENING - 0:00-0:30]
🎬 Title: "Advanced Bash Scripting - Professional Techniques"
🎬 Welcome back! In this video, we'll dive deep into professional Bash scripting techniques that will make your scripts production-ready.

[SECTION 1: The Holy Grail - 0:30-3:00]
🎬 Let's start with the most important line in any production script: set -euo pipefail

[SCREEN: Show the line]
```bash
set -euo pipefail
```

🎬 This single line does THREE critical things:
- -e: Exit immediately if any command fails
- -u: Treat unset variables as errors
- -o pipefail: Pipeline fails if ANY command fails, not just the last

[SCREEN: Demo of each flag]
🎬 Watch what happens WITHOUT this...
[Show failing script example]

🎬 Now with the flags...
[Show the same script with set -euo pipefail]

[SECTION 2: trap - 3:00-7:00]
🎬 Next is trap - your safety net for scripts.

[SCREEN: Show trap examples]
```bash
# Error handling
trap 'echo "Error at line $LINENO"' ERR

# Cleanup on exit
trap 'rm -f /tmp/tempfile' EXIT

# Handle Ctrl+C
trap 'echo "Interrupted!"; exit 130' INT
```

🎬 trap lets you execute code when:
- Errors occur (ERR)
- Script exits (EXIT)
- User presses Ctrl+C (INT)
- And more signals...

[SCREEN: Live demo]
🎬 Let me show you a real example...

[SECTION 3: getopts - 7:00-12:00]
🎬 Now let's talk about parsing command-line arguments professionally.

[SCREEN: Show getopts example]
```bash
while getopts "n:a:vh" opt; do
    case $opt in
        n) name="$OPTARG" ;;
        a) age="$OPTARG" ;;
        v) verbose=true ;;
        h) help ;;
    esac
done
```

🎬 getopts is:
- POSIX compliant
- Handles spaces in arguments
- Built into Bash

[SCREEN: Full example]
🎬 Here's a complete professional script template...

[SECTION 4: Best Practices - 12:00-15:00]
🎬 Let's wrap up with the professional checklist:

[SCREEN: Show checklist]
- Always use set -euo pipefail
- Quote your variables
- Check return codes
- Validate input
- Use functions for reusable code
- Add logging
- Document your code

[CLOSING - 15:00-15:30]
🎬 That's it for Advanced Scripting! Next, we'll cover testing your Bash scripts.
🎬 Like and subscribe for more!
```

---

## 🎬 VIDEO 2: Systemd Mastery
### Stack 27: Managing Services

**Duration**: 12-15 minutes

### Script

```
[OPENING - 0:00-0:20]
🎬 Title: "Systemd Deep Dive - Linux Service Management"
🎬 If you're serious about Linux administration, you NEED to understand systemd. Let's master it.

[WHAT IS SYSTEMD - 0:20-2:00]
🎬 Systemd is the init system that starts your system and manages services.

[SCREEN: Show the boot process]
🎬 When your Linux system boots:
1. Kernel loads
2. Systemd starts (PID 1)
3. Services start in parallel (much faster than old SysVinit)

[UNIT FILES - 2:00-5:00]
🎬 Systemd uses "unit files" to define services.

[SCREEN: Show a service unit file]
```ini
[Unit]
Description=My Application
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/myapp
Restart=always

[Install]
WantedBy=multi-user.target
```

🎬 Key directives:
- Description: What this service does
- After: Start after these units
- ExecStart: Command to run
- Restart: auto-restart on failure
- WantedBy: Which target to enable for

[MANAGING SERVICES - 5:00-8:00]
🎬 Essential commands:

[SCREEN: Show commands]
```bash
# Start a service
sudo systemctl start nginx

# Enable at boot
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx

# View logs
journalctl -u nginx

# Restart on changes
sudo systemctl daemon-reload
```

🎬 These are commands you'll use EVERY day.

[TIMERS - 8:00-11:00]
🎬 Systemd timers are the modern alternative to cron.

[SCREEN: Show timer example]
```ini
[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=30min
```

🎬 Advantages over cron:
- Better dependency handling
- Built-in retry after reboot
- Random delay to prevent thundering herd
- Integrated with journal logging

[CLOSING - 11:00-12:00]
🎬 That's systemd basics! Practice these commands and you'll be a pro.
🎬 Subscribe for more Linux tutorials!
```

---

## 🎬 VIDEO 3: AWK Deep Dive
### Stack 60: Text Processing Power

**Duration**: 15-18 minutes

### Script

```
[OPENING - 0:00-0:20]
🎬 Title: "AWK Mastery - The Most Powerful Text Tool"
🎬 AWK is INCREDIBLE for text processing. Once you know it, you'll use it everywhere.

[WHAT IS AWK - 0:20-2:00]
🎬 AWK = Aho, Weinberger, Kernighan
🎬 It's a pattern-matching language designed for text processing.

[SCREEN: Basic syntax]
```bash
awk 'pattern { action }' file.txt
```

🎬 It automatically splits input into fields:
- $0 = entire line
- $1 = first field
- $2 = second field
- NF = Number of Fields
- NR = Number of Records

[BASIC EXAMPLES - 2:00-5:00]
🎬 Let's start with simple examples:

[SCREEN]
```bash
# Print first column
awk '{print $1}' data.txt

# Print specific columns
awk '{print $1, $3, $5}' data.txt

# Print lines matching a pattern
awk '/error/' log.txt
```

🎬 The key concept: pattern { action }

[CONDITIONS - 5:00-8:00]
🎬 Filter with conditions:

[SCREEN]
```bash
# Print where column 3 > 50
awk '$3 > 50 {print $0}' data.txt

# Multiple conditions
awk '$1 == "ERROR" && $2 > 5' log.txt
```

🎬 This is like WHERE in SQL!

[BUILT-IN VARIABLES - 8:00-11:00]
🎬 AWK has powerful built-in variables:

[SCREEN]
```bash
# Field separator (default is whitespace)
awk -F',' '{print $1}' csv.txt

# Change output separator
awk 'BEGIN {OFS=" - "} {print $1, $2}' data.txt

# Line numbers
awk '{print NR, $0}' data.txt
```

🎬 FS and OFS are GAME CHANGERS for CSV processing!

[ARRAYS - 11:00-14:00]
🎬 AWK arrays are associative (like dictionaries):

[SCREEN]
```bash
# Count occurrences
awk '{count[$1]++} END {for (word in count) print word, count[word]}' file.txt

# Sum by category
awk '{sum[$1] += $2} END {for (cat in sum) print cat, sum[cat]}' data.txt
```

🎬 This is like GROUP BY in SQL!

[REAL-WORLD EXAMPLE - 14:00-16:00]
🎬 Let's parse a real log file:

[SCREEN]
```bash
# Extract errors from Apache log
awk '/ERROR/ {errors[$NF]++} END {for (e in errors) print e, errors[e]}' access.log

# Sum response times
awk '/GET/ {sum += $NF; count++} END {print "Average:", sum/count}' access.log
```

🎬 This is how you analyze logs in production!

[CLOSING - 16:00-18:00]
🎬 AWK is essential for any DevOps engineer. Practice these examples!
🎬 Like and subscribe!
```

---

## 🎬 VIDEO 4: Kubernetes for Bash Scripts
### Stack 31: K8s Basics

**Duration**: 15-20 minutes

### Script

```
[OPENING - 0:00-0:20]
🎬 Title: "Kubernetes with Bash - Automation Guide"
🎬 Learn how to automate Kubernetes operations with Bash scripts!

[WHY KUBERNETES - 0:20-2:00]
🎬 Kubernetes is the standard for container orchestration.
🎬 As a Bash scripter, you'll need to manage K8s clusters.

[BASIC COMMANDS - 2:00-5:00]
🎬 Essential kubectl commands:

[SCREEN]
```bash
# Get pods
kubectl get pods

# Get all resources
kubectl get all

# Describe resource
kubectl describe pod mypod

# Logs
kubectl logs mypod

# Execute in container
kubectl exec -it mypod -- /bin/bash
```

🎬 These are your daily commands.

[NAMESPACES - 5:00-7:00]
🎬 Namespaces isolate resources:

[SCREEN]
```bash
# List namespaces
kubectl get ns

# Switch context
kubectl config use-context prod

# Get from specific namespace
kubectl get pods -n mynamespace
```

[SCRIPTING WITH KUBECTL - 7:00-12:00]
🎬 Let's automate common tasks:

[SCREEN: Script 1 - Check pod status]
```bash
#!/bin/bash
# check_pods.sh

NAMESPACE="${1:-default}"

pods=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')

for pod in $pods; do
    status=$(kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.phase}')
    echo "$pod: $status"
    
    if [ "$status" != "Running" ]; then
        echo "  ⚠️ Not running!"
    fi
done
```

[SCREEN: Script 2 - Deploy application]
```bash
#!/bin/bash
# deploy.sh

APP_NAME="$1"
IMAGE="$2"

kubectl create deployment "$APP_NAME" --image="$IMAGE"

# Wait for rollout
kubectl rollout status deployment/"$APP_NAME"

echo "Deployed $APP_NAME successfully!"
```

[SCREEN: Script 3 - Scale application]
```bash
#!/bin/bash
# scale.sh

APP_NAME="$1"
REPLICAS="$2"

kubectl scale deployment "$APP_NAME" --replicas="$REPLICAS"

echo "Scaled $APP_NAME to $REPLICAS replicas"
```

[HELM BASICS - 12:00-15:00]
🎬 Helm is the package manager for Kubernetes:

[SCREEN]
```bash
# Install chart
helm install myrelease bitnami/nginx

# Upgrade
helm upgrade myrelease bitnami/nginx

# List releases
helm list

# Rollback
helm rollback myrelease 1
```

[CLOSING - 15:00-20:00]
🎬 These scripts are the foundation for your K8s automation!
🎬 Practice deploying and managing applications.
🎬 Subscribe for more DevOps tutorials!
```

---

## 🎬 VIDEO 5: Network Troubleshooting
### Stack 17: Network Scripting

**Duration**: 12-15 minutes

### Script

```
[OPENING - 0:00-0:20]
🎬 Title: "Network Troubleshooting with Bash"
🎬 Learn essential network debugging commands and scripts!

[BASIC TOOLS - 0:20-3:00]
🎬 Every sysadmin needs these:

[SCREEN]
```bash
# Check connectivity
ping -c 4 8.8.8.8

# Trace route
traceroute google.com

# Check DNS
dig example.com
nslookup example.com

# Port scanning
nmap -p 80 example.com
```

🎬 These are your first steps when troubleshooting.

[CHECKING SERVICES - 3:00-6:00]
🎬 Is the service running?

[SCREEN]
```bash
# Check listening ports
ss -tulpn
netstat -tulpn

# Check connections
ss -tan
netstat -tan
```

🎬 ss is faster and more modern than netstat.

[DEBUGGING DNS - 6:00-9:00]
🎬 DNS issues are common:

[SCREEN: DNS debug script]
```bash
#!/bin/bash
# check_dns.sh

DOMAIN="${1:-example.com}"

echo "Checking DNS for $DOMAIN..."

# A records
echo "A records:"
dig +short A "$DOMAIN"

# AAAA records (IPv6)
echo "AAAA records:"
dig +short AAAA "$DOMAIN"

# CNAME records
echo "CNAME records:"
dig +short CNAME "$DOMAIN"

# Check resolver
echo "Using resolver:"
cat /etc/resolv.conf
```

[PORT TESTING - 9:00-12:00]
🎬 Test if a port is accessible:

[SCREEN]
```bash
# Simple port test
nc -zv example.com 80

# With timeout
timeout 5 bash -c 'cat < /dev/null > /dev/tcp/example.com/80'

# Full port scan
nmap -p- 192.168.1.1
```

[TROUBLESHOOTING SCRIPT - 12:00-14:00]
🎬 Here's a comprehensive network check:

[SCREEN]
```bash
#!/bin/bash
# network_check.sh

HOST="$1"

echo "=== Network Diagnostic ==="

echo -n "Ping: "
ping -c 1 "$HOST" > /dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "DNS: "
dig +short "$HOST" > /dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "Port 80: "
nc -zw 2 "$HOST" 80 > /dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "Port 443: "
nc -zw 2 "$HOST" 443 > /dev/null 2>&1 && echo "✓" || echo "✗"
```

[CLOSING - 14:00-15:00]
🎬 These tools will save you in production!
🎬 Like and subscribe for more!
```

---

## 🎬 VIDEO 6: Security Hardening
### Stack 39: System Hardening

**Duration**: 15-18 minutes

### Script

```
[OPENING - 0:00-0:20]
🎬 Title: "Linux Security Hardening - Protect Your Systems"
🎬 Learn how to secure your Linux systems with Bash!

[WHY HARDENING - 0:20-1:30]
🎬 Default Linux installations are NOT secure.
🎬 You MUST harden production systems.

[FIREWALL - 1:30-5:00]
🎬 Start with the firewall:

[SCREEN: UFW]
```bash
# UFW (Ubuntu)
sudo ufw enable
sudo ufw default deny incoming
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw status
```

[SCREEN: iptables]
```bash
# Basic iptables
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -P INPUT DROP
```

[SSH HARDENING - 5:00-8:00]
🎬 SSH is a common attack vector:

[SCREEN]
```bash
# Edit /etc/ssh/sshd_config

# Disable root login
PermitRootLogin no

# Use key authentication only
PasswordAuthentication no

# Change default port
Port 2222

# Limit login attempts
MaxAuthTries 3

# Restart SSH
sudo systemctl restart sshd
```

[FAIL2BAN - 8:00-10:00]
🎬 Install Fail2Ban to block attackers:

[SCREEN]
```bash
sudo apt install fail2ban

# Create config
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit settings
sudo nano /etc/fail2ban/jail.local

# Enable
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

[USER MANAGEMENT - 10:00-13:00]
🎬 Proper user management:

[SCREEN]
```bash
# Create admin user
sudo useradd -m -s /bin/bash -G sudo admin

# Set up SSH keys
mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Remove unused accounts
sudo userdel olduser
```

[MONITORING - 13:00-16:00]
🎬 Monitor for suspicious activity:

[SCREEN: Security script]
```bash
#!/bin/bash
# security_monitor.sh

echo "=== Security Check ==="

# Failed logins
echo "Failed logins:"
lastb | head -10

# Recent sudo commands
echo "Recent sudo:"
journalctl -u sudo | tail -10

# New files in /tmp
echo "Recent files in /tmp:"
find /tmp -type f -mtime -1 2>/dev/null

# Listening ports
echo "Listening ports:"
ss -tulpn | grep LISTEN
```

[CLOSING - 16:00-18:00]
🎬 Security is ongoing - monitor regularly!
🎬 Like and subscribe!
```

---

## 📺 Recording Checklist

### Before Recording
- [ ] Script reviewed and timed
- [ ] Terminal theme consistent
- [ ] Font size readable (14-18pt)
- [ ] Clean desktop background
- [ ] Microphone tested
- [ ] Lights positioned correctly

### During Recording
- [ ] Speak clearly and at moderate pace
- [ ] Pause after key points
- [ ] Show commands being typed
- [ ] Highlight important output

### After Recording
- [ ] Remove long pauses
- [ ] Add chapter markers
- [ ] Add captions (accessibility)
- [ ] Export at good quality (1080p minimum)

---

## 🎥 Equipment Recommendations

### Budget Setup ($100-200)
- Microphone: Audio-Technica ATR2100x ($80)
- Lighting: Basic LED panel ($30)
- Screen capture: OBS (free)

### Quality Setup ($500+)
- Microphone: Shure SM7B ($400)
- Audio interface: Focusrite Scarlett Solo ($100)
- Lighting: Elgato Key Light Air ($200)
- Capture: OBS Studio (free)

---

## 📝 Additional Video Ideas

| Topic | Duration | Difficulty |
|-------|----------|------------|
| Cron vs Systemd Timers | 10 min | Intermediate |
| SSL/TLS Certificates | 12 min | Intermediate |
| Docker Networking | 15 min | Advanced |
| ELK Stack Setup | 20 min | Advanced |
| tmux Productivity | 12 min | Beginner |
| Vim Essentials | 15 min | Beginner |
| Git Workflows | 15 min | Intermediate |
| Ansible Automation | 18 min | Advanced |

---

*End of Video Companion Guide*
