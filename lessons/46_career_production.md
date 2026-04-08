# 💼 STACK 46: CAREER & PRODUCTION
## Bash Skills for Your Career

**Why This Stack?** Everything you've learned so far is great, but how does it translate to a career? This stack bridges the gap between "I know bash" and "I'm hired for my automation skills."

**The Reality:** Bash skills are in HIGH demand. Every company with servers needs people who can automate, troubleshoot, and manage systems. This stack shows you how to prove your skills and get paid for them.

---

## 🔰 Career Paths

### Common Roles for Bash Experts
| Role | What You'd Do | Bash Skills Needed | Avg. Salary Range |
|------|--------------|-------------------|-------------------|
| **DevOps Engineer** | Automate deployments, manage CI/CD | CI/CD, containerization, scripting | $90K-$150K+ |
| **Site Reliability Engineer (SRE)** | Keep systems running 24/7 | Monitoring, automation, debugging | $100K-$160K+ |
| **Systems Administrator** | Manage servers and infrastructure | Scripting, user management, backups | $60K-$100K+ |
| **Backend Developer** | Build and maintain server-side code | Database ops, API scripting, automation | $80K-$140K+ |

**Pro Tip:** Bash is rarely the ONLY skill needed. Combine it with cloud (AWS/GCP), containers (Docker/K8s), and infrastructure-as-code (Terraform) for maximum market value!

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

## 🎓 Final Project: The Production DevOps Toolkit

Now that you've mastered the skills to write professional Bash, let's see how they all come together in a production-ready tool. We'll examine the "DevOps Toolkit" — a comprehensive script that handles deployments, rollbacks, health checks, and system maintenance for a real-world application.

### What the Production DevOps Toolkit Does:
1. **Handles Multi-Environment Deployments** (Development, Staging, Production).
2. **Performs Instant Rollbacks** to previous versions if a deployment fails.
3. **Conducts Service Health Checks** across databases, caches, and web services.
4. **Collects Critical Metrics** (CPU, RAM, Disk) in a professional summary.
5. **Manages Automated Backups** with dated archives for disaster recovery.
6. **Automates Log Cleanup** to ensure your servers never run out of disk space.

### Key Snippet: Smart Health Monitoring
A production script doesn't just run commands; it audits the system to ensure everything is working perfectly.

```bash
cmd_health_check() {
    log "Initiating full system health check..."
    
    # 1. Check if the web server is responding
    # 2. Check if the database is reachable
    # 3. Verify available disk space
    
    # Example logic:
    echo "Services: OK"
    echo "Database: OK"
    echo "Cache: OK"
    
    log "Health check passed. System is stable."
}
```

### Key Snippet: Resource Metric Parsing
The toolkit uses a combination of standard Linux commands and `awk` to extract clean, percentage-based performance data.

```bash
cmd_metrics() {
    echo "=== Current System Metrics ==="
    
    # Extract CPU percentage from top
    local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    
    # Extract Memory percentage from free
    local mem=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')
    
    echo "CPU Load: ${cpu}%"
    echo "Memory Usage: ${mem}%"
}
```

**Pro Tip:** This toolkit is exactly the kind of project you should include in your portfolio. It shows employers that you understand the entire lifecycle of professional software!

---

## ✅ Stack 46 Complete!

Congratulations! You have reached the summit of Bash Scripting! You can now:
- ✅ **Write production-ready code** that is safe, fast, and reliable
- ✅ **Build automated DevOps tools** to manage entire infrastructures
- ✅ **Architect professional projects** using advanced design patterns
- ✅ **Audit systems for security** and performance like an expert
- ✅ **Deploy and manage software** across multiple environments
- ✅ **Navigate your career** as a professional Bash and DevOps engineer

### What's Next?
While this marks the end of the core curriculum, your journey is just beginning! In the next stack, we'll dive into **Advanced Git**. You'll learn the secret commands that Git masters use to fix complex repo issues and manage massive codebases!

**Next: Stack 47 - Advanced Git →**

---

*End of Stack 46*
-- **Previous:** [Stack 45 → Advanced Patterns](45_advanced_patterns.md)
-- **Next:** [Stack 47 - Advanced Git](47_advanced_git.md)