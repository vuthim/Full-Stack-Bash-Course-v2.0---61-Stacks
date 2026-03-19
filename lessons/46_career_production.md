# 💼 STACK 46: CAREER & PRODUCTION
## Bash Skills for Your Career

---

## 🔰 Career Paths

### Common Roles for Bash Experts
| Role | Skills Needed |
|------|---------------|
| DevOps Engineer | CI/CD, containerization |
| Site Reliability | Monitoring, automation |
| Systems Admin | Scripting, automation |
| Backend Developer | Database, API, scripting |

---

## 💼 Building Your Portfolio

### Project Ideas
1. **Server bootstrap script** - Automated server setup
2. **Backup solution** - Automated backups with rotation
3. **Monitoring dashboard** - System monitoring with alerts
4. **Deployment scripts** - CI/CD pipeline automation
5. **Configuration management** - Ansible/Terraform configs

### GitHub Portfolio
```bash
# Create proper README
# Structure: project-name/
#   ├── README.md
#   ├── install.sh
#   ├── script.sh
#   └── tests/
```

---

## 📝 Writing Scripts for Production

### Essential Features
```bash
#!/bin/bash
# production_ready.sh

set -euo pipefail  # Strict mode

# Configuration
readonly SCRIPT_NAME="myscript"
readonly SCRIPT_VERSION="1.0.0"

# Logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# Error handling
error() { log "ERROR: $*" >&2; exit 1; }

# Help
show_help() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION

Usage: $0 [OPTIONS]

Options:
  -h, --help     Show this help
  -v, --verbose  Verbose output
  -c, --config   Config file
  
Examples:
  $0 --config prod.yml
  $0 -v
EOF
}

# Main
main() {
    local config=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) show_help; exit 0 ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -c|--config) config=$2; shift 2 ;;
            *) error "Unknown option: $1" ;;
        esac
    done
    
    log "Starting $SCRIPT_NAME"
}

main "$@"
```

---

## 📋 Professional Practices

### Testing
```bash
# Use bats-core for testing
# test_script.bats
@test "function returns correct value" {
    result="$(my_function "test")"
    [ "$result" = "expected" ]
}
```

### Documentation
```bash
# Document every function
# Check exit codes
# Handle errors gracefully
# Add examples in comments
```

---

## 🔐 Security Best Practices

### Never Do This
```bash
# ❌ Don't expose secrets
echo "Password: $password"

# ❌ Don't use eval
eval "$user_input"

# ❌ Don't make world-writable
chmod 777 script.sh
```

### Always Do This
```bash
# ✅ Use quotes
command --path="$variable"

# ✅ Validate input
[[ "$input" =~ ^[a-z]+$ ]] || error "Invalid input"

# ✅ Use readonly for constants
readonly API_KEY="secret"

# ✅ Check return codes
command || error "Command failed"
```

---

## 📊 DevOps Automation

### Common DevOps Tasks
```bash
# Deploy application
# Database migrations
# Health checks
# Rollback scripts
# Log rotation
# Backup automation
```

---

## 🏆 Getting Certified

### Useful Certifications
- **RHCSA/RHCE** - Red Hat
- **AWS Certified** - Amazon
- **CKA** - Kubernetes
- **CompTIA Linux+**

---

## ✅ Stack 46 Complete!

You learned:
- ✅ Career paths for Bash experts
- ✅ Building your portfolio
- ✅ Writing production-ready scripts
- ✅ Professional practices
- ✅ Security best practices
- ✅ DevOps automation

### Congratulations! Course Complete! 🎓

---

## 📝 Final Challenge

Build a complete project that includes:
1. Installation script
2. Main application script
3. Tests
4. Documentation
5. CI/CD pipeline

Share on GitHub!

---

*End of Stack 46*