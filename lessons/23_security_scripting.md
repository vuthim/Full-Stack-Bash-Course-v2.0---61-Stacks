# 🔒 STACK 23: SECURITY SCRIPTING
## Secure Scripting Best Practices

---

## 🔐 Input Sanitization

```bash
# Never trust user input!
# Always validate and sanitize

# Prevent command injection
user_input="; rm -rf /"
safe_input=$(echo "$user_input" | sed 's/[^a-zA-Z0-9._-]//g')

# Use quotes always
command --path="$user_input"  # Safe
command --path=$user_input    # DANGEROUS
```

---

## 🛡️ Secure Script Template

```bash
#!/bin/bash
# secure_script.sh

set -euo pipefail  # Strict mode

# Validate input
if [ $# -lt 1 ]; then
    echo "Usage: $0 <username>" >&2
    exit 1
fi

# Sanitize
username=$(echo "$1" | sed 's/[^a-zA-Z0-9_-]//g')

# Use full paths
/bin/mkdir -p "/tmp/$username"
/usr/bin/whoami

# Don't log sensitive data
# BAD: echo "Password: $password"
# GOOD: echo "Password: ***"
```

---

## 🔑 Managing Secrets

```bash
# Use environment variables
export API_KEY="secret"
echo "$API_KEY"  # In script

# Hash passwords
echo "password" | sha256sum
echo "password" | md5sum

# Use .env files (add to .gitignore)
# .env
# API_KEY=secret
# DB_PASSWORD=secret
```

---

## 🚫 Common Security Mistakes

```bash
# ❌ DON'T: Use eval with user input
eval "$user_input"

# ❌ DON'T: Use backticks
result=`command $user_input`

# ❌ DON'T: Global write permissions
chmod 777 script.sh  # BAD!

# ✅ DO: Check return codes
command || { echo "Failed"; exit 1; }

# ✅ DO: Use local variables
local var="value"
```

---

## 🔒 File Permissions

```bash
# Scripts should be readable but not writable
chmod 644 script.sh

# Scripts with secrets should be executable only by owner
chmod 700 secrets_script.sh

# Never make sensitive files world-readable
chmod 600 .env
chmod 600 ~/.ssh/id_rsa
```

---

## 📝 Security Check Script

```bash
#!/bin/bash
# security_check.sh

echo "=== Security Check ==="

# Check for weak permissions
echo "Checking file permissions..."
find /home -name "*.sh" -perm -777 2>/dev/null | while read f; do
    echo "⚠️ Weak permissions: $f"
done

# Check for vulnerable scripts
grep -r "eval " /home/*/scripts/ 2>/dev/null | while read line; do
    echo "⚠️ Uses eval: $line"
done

# Check SSH keys
if [ -f ~/.ssh/id_rsa ]; then
    perms=$(stat -c %a ~/.ssh/id_rsa)
    if [ "$perms" != "600" ]; then
        echo "⚠️ SSH key has weak permissions: $perms"
    fi
fi

echo "Security check complete."
```

---

## ✅ Stack 23 Complete!