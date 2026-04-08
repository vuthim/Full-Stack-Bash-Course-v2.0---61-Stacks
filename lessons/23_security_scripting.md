# 🔒 STACK 23: SECURITY SCRIPTING
## Secure Scripting Best Practices

**What is Security Scripting?** Think of security scripts as automated guards watching your systems. They check for weaknesses, enforce rules, and alert you to problems - 24/7, without getting tired.

**⚠️ SECURITY WARNING:** Security scripts are one piece of the puzzle. They don't replace proper system hardening, firewalls, or good practices. Security is layered - like an onion (or a castle with multiple walls)!

---

## 🔰 Why Security Scripting?

Every script you write is a potential vulnerability if not secured properly. This lesson covers:
- ✅ **Preventing command injection** - Stop attackers from running commands through your inputs
- ✅ **Protecting sensitive data** - Keep passwords, keys, and tokens safe
- ✅ **Secure file handling** - Proper permissions and ownership
- ✅ **Input validation** - Never trust user input!
- ✅ **Proper permissions** - Least privilege principle

### The Golden Rule of Script Security
```
"NEVER trust input. ALWAYS validate. QUOTE everything."
```

---

## 🎯 Input Sanitization

### Never Trust User Input!
```bash
# Always validate and sanitize ALL input
user_input="; rm -rf /"
safe_input=$(echo "$user_input" | sed 's/[^a-zA-Z0-9._-]//g')

# Use quotes ALWAYS
command --path="$user_input"  # Safe
command --path=$user_input    # DANGEROUS - word splitting!
```

### Input Validation Functions
```bash
#!/bin/bash
# input_validation.sh

set -euo pipefail

# Validate alphanumeric input
validate_alphanumeric() {
    local input="$1"
    local max_length="${2:-255}"
    
    if [ -z "$input" ]; then
        return 1
    fi
    
    if [ ${#input} -gt $max_length ]; then
        return 1
    fi
    
    if [[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 0
    fi
    
    return 1
}

# Validate email
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Validate IP address
validate_ip() {
    local ip="$1"
    [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
}

# Validate number
validate_number() {
    local num="$1"
    [[ "$num" =~ ^[0-9]+$ ]]
}

# Usage examples
if ! validate_alphanumeric "$username" 32; then
    echo "Invalid username" >&2
    exit 1
fi

if ! validate_email "$user_email"; then
    echo "Invalid email" >&2
    exit 1
fi
```

### Sanitization Functions
```bash
#!/bin/bash
# sanitization.sh

# Remove all non-alphanumeric characters
sanitize_alphanumeric() {
    echo "$1" | tr -cd 'a-zA-Z0-9'
}

# Remove potentially dangerous characters
sanitize_path() {
    echo "$1" | sed 's/[^a-zA-Z0-9._\/-]//g'
}

# Remove shell metacharacters
sanitize_shell() {
    echo "$1" | sed 's/[;&|`$(){}[\]<>!#*?"'"'"']//g'
}

# Sanitize for SQL (basic - use parameterized queries!)
sanitize_sql() {
    echo "$1" | sed "s/['\";]//g"
}

# Usage
user_input="; rm -rf /"
safe=$(sanitize_shell "$user_input")
echo "$safe"  # Output: rm -rf /
```

---

## 🛡️ Secure Script Template

### Production-Ready Template
```bash
#!/bin/bash
# secure_script.sh - Production-ready secure script

set -euo pipefail
IFS=$'\n\t'

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_AUTHOR="Your Name"

# Logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
error() { echo "[ERROR] $*" >&2; }
die() { error "$*"; exit 1; }

# Validate required arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <username>" >&2
    exit 1
fi

# Sanitize input
username=$(echo "$1" | sed 's/[^a-zA-Z0-9_-]//g')

# Validate sanitized input not empty
[ -z "$username" ] && die "Invalid username after sanitization"

# Use full paths for commands
/bin/mkdir -p "/tmp/$username"
/usr/bin/whoami

# NEVER log sensitive data
# BAD: echo "Password: $password"
# GOOD: echo "Password: ********"

# Cleanup function
cleanup() {
    # Remove temp files, reset permissions, etc.
    [ -f "$tmpfile" ] && rm -f "$tmpfile"
}
trap cleanup EXIT
```

---

## 🔑 Managing Secrets

### Environment Variables
```bash
# Set for current session
export API_KEY="secret_value"

# Set for script only (recommended)
#!/bin/bash
API_KEY="secret_value" ./script.sh

# Or pass as argument (not recommended for sensitive data)
script.sh --api-key "$API_KEY"
```

### Hashing Passwords
```bash
# SHA-256 (recommended)
echo -n "password" | sha256sum
# Output: 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8  -

# SHA-512
echo -n "password" | sha512sum

# bcrypt (more secure for passwords)
hashpass() {
    echo -n "$1" | sha256sum | base64
}

# Verify password
verify_password() {
    local input="$1"
    local stored_hash="$2"
    local input_hash=$(echo -n "$input" | sha256sum | cut -d' ' -f1)
    [ "$input_hash" = "$stored_hash" ]
}
```

### .env Files
```bash
# .env file (add to .gitignore!)
# API_KEY=your-secret-key
# DB_PASSWORD=your-db-password
# JWT_SECRET=your-jwt-secret

# Load .env in script
load_env() {
    local env_file="${1:-.env}"
    
    if [ -f "$env_file" ]; then
        set -a  # Auto-export
        source "$env_file"
        set +a
    fi
}

# Usage
load_env "/path/to/.env"
```

### Secret Management Tools
```bash
# HashiCorp Vault
vault write secret/myapp DB_PASSWORD="password123"

# AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id myapp/db-password

# Kubernetes Secrets
kubectl create secret generic db-credentials \
    --from-literal=username=admin \
    --from-literal=password=secret
```

---

## 🚫 Common Security Mistakes

### Never Do These
```bash
# ❌ DON'T: Use eval with user input
eval "$user_input"  # Command injection!

# ❌ DON'T: Use backticks (deprecated)
result=`command $user_input`

# ❌ DON'T: Global write permissions
chmod 777 script.sh  # Anyone can modify!

# ❌ DON'T: Store passwords in scripts
DB_PASS="secret"  # Visible to anyone who reads the file!

# ❌ DON'T: Use HTTP for sensitive data
curl -d "pass=secret" http://api.example.com  # Unencrypted!

# ❌ DON'T: Leave debug code in production
set -x  # Remove in production!
```

### Always Do These
```bash
# ✅ DO: Use set -euo pipefail
set -euo pipefail

# ✅ DO: Check return codes
command || { echo "Failed"; exit 1; }

# ✅ DO: Use local variables
my_function() {
    local var="value"
}

# ✅ DO: Use quotes
echo "$variable"

# ✅ DO: Use full paths
/bin/ls /path

# ✅ DO: Validate input
[[ "$input" =~ ^[a-zA-Z0-9_]+$ ]] || die "Invalid input"
```

---

## 🔒 File Permissions

### Permission Basics
```bash
# Scripts - readable but not writable
chmod 644 script.sh

# Scripts with secrets - executable only by owner
chmod 700 secrets_script.sh

# Sensitive files
chmod 600 .env
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/config

# Directories (trailing / is important!)
chmod 700 ~/.ssh

# Logs (readable by admin only)
chmod 640 /var/log/myapp.log
```

### Permission Check Script
```bash
#!/bin/bash
# check_permissions.sh

set -euo pipefail

check_file_permissions() {
    local file="$1"
    local expected_perms="$2"
    
    local actual_perms=$(stat -c %a "$file" 2>/dev/null)
    
    if [ "$actual_perms" != "$expected_perms" ]; then
        echo "WARNING: $file has permissions $actual_perms, expected $expected_perms"
        return 1
    fi
    
    echo "OK: $file has correct permissions ($actual_perms)"
    return 0
}

# Check SSH key
if [ -f ~/.ssh/id_rsa ]; then
    check_file_permissions ~/.ssh/id_rsa "600"
fi

# Check .env file
if [ -f .env ]; then
    check_file_permissions .env "600"
fi

# Check script directory
check_file_permissions /usr/local/bin "755"
```

---

## 🛡️ Secure File Operations

### Safe File Handling
```bash
#!/bin/bash
# safe_file_ops.sh

set -euo pipefail

# Use temp files safely
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

# Create file securely
create_secure_file() {
    local file="$1"
    local content="$2"
    
    # Create with restrictive permissions
    printf '%s' "$content" > "$file"
    chmod 600 "$file"
}

# Safe file reading
read_file_safe() {
    local file="$1"
    
    # Check file exists and is readable
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        echo "Error: Cannot read file" >&2
        return 1
    fi
    
    cat "$file"
}

# Atomic writes
atomic_write() {
    local file="$1"
    local content="$2"
    
    # Write to temp, then rename (atomic)
    local tmp=$(mktemp)
    printf '%s' "$content" > "$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$file"
}
```

### Path Traversal Prevention
```bash
#!/bin/bash
# prevent_path_traversal.sh

resolve_safe_path() {
    local base_dir="$1"
    local user_path="$2"
    
    # Resolve to absolute path
    local resolved=$(readlink -f "$user_path")
    
    # Check it's within base directory
    case "$resolved" in
        "$base_dir"/*)
            echo "$resolved"
            ;;
        *)
            return 1
            ;;
    esac
}

# Usage
BASE_DIR="/var/www/uploads"
USER_FILE="../etc/passwd"

SAFE_PATH=$(resolve_safe_path "$BASE_DIR" "$USER_FILE") || {
    echo "Path traversal attempt detected!" >&2
    exit 1
}
```

---

## 🔐 Network Security

### Secure curl Usage
```bash
# ❌ DON'T: Insecure HTTP
curl http://api.example.com/data

# ✅ DO: HTTPS with certificate validation
curl https://api.example.com/data

# ✅ DO: Check SSL certificate
curl --cacert /path/to/ca.pem https://api.example.com

# ✅ DO: Use API key securely
curl -H "Authorization: Bearer $API_KEY" https://api.example.com

# ✅ DO: Verify SSL
curl -v https://api.example.com 2>&1 | grep "SSL"
```

### SSH Security
```bash
# Generate secure SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# SSH config for security
# ~/.ssh/config
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3

# SCP securely
scp -P 2222 localfile.txt user@server:/remote/path
```

---

## 📝 Security Check Script

### Comprehensive Security Audit
```bash
#!/bin/bash
# security_audit.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $*"; }

echo "=== Security Audit ==="

# Check for weak permissions on scripts
log_info "Checking script permissions..."
find /home -name "*.sh" -perm -777 2>/dev/null | while read -r f; do
    log_fail "Weak permissions: $f"
done

# Check for dangerous commands
log_info "Checking for dangerous patterns..."
grep -r "eval " /home/*/scripts/ 2>/dev/null | while read -r line; do
    log_warn "Uses eval: $line"
done

# Check SSH keys
log_info "Checking SSH keys..."
if [ -f ~/.ssh/id_rsa ]; then
    perms=$(stat -c %a ~/.ssh/id_rsa)
    if [ "$perms" != "600" ]; then
        log_fail "SSH key has weak permissions: $perms"
    else
        log_info "SSH key permissions OK"
    fi
fi

# Check for exposed secrets
log_info "Checking for exposed secrets..."
grep -r "password\s*=" /home/*/*.sh 2>/dev/null | grep -v "^#" | while read -r line; do
    log_warn "Possible password in: $line"
done

# Check .env files
log_info "Checking .env files..."
find /home -name ".env" -perm +644 2>/dev/null | while read -r f; do
    log_warn ".env may be world-readable: $f"
done

# Check for outdated SSL
log_info "Checking SSL certificates..."
for cert in /etc/ssl/certs/*.pem; do
    if ! openssl x509 -in "$cert" -checkend 86400 >/dev/null 2>&1; then
        log_warn "Certificate expiring soon: $cert"
    fi
done

echo "=== Audit Complete ==="
```

---

## 🏆 Security Best Practices Checklist

```bash
#!/bin/bash
# security_checklist.sh

# Use strict mode
set -euo pipefail

# Validate ALL input
# [[ "$input" =~ ^[pattern$ ]] || die

# Sanitize ALL input  
# sed 's/[^a-zA-Z0-9]//g'

# Use full paths
# /bin/ls /path

# Check return codes
# command || die "Failed"

# Quote variables
# "$variable"

# Use local variables in functions
# local var="value"

# Protect sensitive files
# chmod 600 file

# Use HTTPS
# curl https://

# Don't log secrets
# echo "Token: *****"

# Use secret management
# vault, AWS secrets, etc.

# Keep scripts updated
# Regular security audits
```

---

## 🔍 Troubleshooting

### Debugging Security Issues
```bash
# Check what's being executed
bash -x script.sh

# See expanded commands
set -x
command "$variable"

# Check file permissions
ls -la script.sh
stat script.sh

# Check for shellshock vulnerability
env X="() { :; }" bash -c "echo vulnerable"

# Check for privilege escalation
sudo -l
```

---

## ✅ Stack 23 Complete!

You learned:
- ✅ Input sanitization and validation
- ✅ Secure script templates
- ✅ Secret management (hashes, env, vault)
- ✅ Common security mistakes to avoid
- ✅ File permission best practices
- ✅ Safe file operations
- ✅ Path traversal prevention
- ✅ Network security (curl, SSH)
- ✅ Comprehensive security audit scripts
- ✅ Security checklist

### Next: Stack 24 - Advanced Scheduling →

---

*End of Stack 23*
