# ⚖️ STACK 48: LOAD BALANCING & PROXY
## Distributing Traffic Across Servers

**What is Load Balancing?** Think of it like a restaurant host seating guests. Instead of sending everyone to one waiter (who'd be overwhelmed), the host distributes guests evenly across all available waiters. Load balancing does the same with web traffic across servers!

**Why This Matters:** Without load balancing, one server gets hammered while others sit idle. With it, traffic flows smoothly and your app stays fast even under heavy load.

---

## 🔰 What is Load Balancing?

Load balancing distributes incoming network traffic across multiple servers to ensure no single server gets overwhelmed.

### Why Use Load Balancing? (The Benefits)
- ✅ **High availability**: If one server crashes, others pick up the slack (no downtime!)
- ✅ **Scalability**: Add more servers as traffic grows (grow horizontally)
- ✅ **Performance**: Distribute load = faster response times for everyone
- ✅ **Security**: Hide backend server IPs from the public (attackers can't target specific servers)

### Load Balancing Analogy
```
Single server:    🚗🚗🚗🚗🚗 → 🏪 (one store, long line)
Load balanced:    🚗 → 🏪
                  🚗 → 🏪
                  🚗 → 🏪  (three stores, short lines!)
                  🚗 → 🏪
                  🚗 → 🏪
```

---

## 🏗️ Load Balancing Methods

### OSI Layer Classification
| Layer | Type | Examples |
|-------|------|----------|
| Layer 4 | Transport | TCP/UDP balancing |
| Layer 7 | Application | HTTP/HTTPS routing |

### Algorithms
| Algorithm | Description |
|-----------|-------------|
| Round Robin | Sequential distribution |
| Least Connections | Route to fewest active connections |
| IP Hash | Same IP to same server |
| Weighted | More traffic to powerful servers |
| Least Time | Fastest response time |

---

## ⚙️ HAProxy Setup

### Installation
```bash
# Install
sudo apt install haproxy

# Start and enable
sudo systemctl enable --now haproxy
```

### Basic Configuration
```ini
# /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    option  http-server-close
    option  forwardfor except 127.0.0.0/8
    option  redispatch
    retries 3
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend http_front
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/server.pem
    redirect scheme https if !{ ssl_fc }
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk
    http-check expect status 200
    server web1 192.168.1.10:80 check inter 2000 rise 2 fall 3
    server web2 192.168.1.11:80 check inter 2000 rise 2 fall 3
    server web3 192.168.1.12:80 check inter 2000 rise 2 fall 3

listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats auth admin:password
```

### More Options
```ini
# Weighted load balancing
server web1 192.168.1.10:80 weight 100
server web2 192.168.1.11:80 weight 200

# Least connections
backend app_servers
    balance leastconn
    server app1 192.168.1.20:8080
    server app2 192.168.1.21:8080
```

---

## 🌐 Nginx as Load Balancer

### Installation
```bash
# Install Nginx
sudo apt install nginx
```

### Basic Configuration
```nginx
# /etc/nginx/sites-available/loadbalancer
upstream backend {
    least_conn;
    server 192.168.1.10:80 weight=2;
    server 192.168.1.11:80;
    server 192.168.1.12:80 backup;
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### Health Checks
```nginx
upstream backend {
    least_conn;
    
    server 192.168.1.10:80 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:80 max_fails=3 fail_timeout=30s;
}
```

---

## 🌪️ DNS Load Balancing

### Round Robin DNS
```bash
# In zone file
example.com.  IN  A  192.168.1.10
example.com.  IN  A  192.168.1.11
example.com.  IN  A  192.168.1.12
```

### Tools
```bash
# Check DNS records
dig example.com

# Multiple records
host example.com
```

---

## 🖥️ Application Load Balancer (AWS-style)

### Concept
```bash
# ALB features:
# - Layer 7 (HTTP/HTTPS) routing
# - Path-based routing
# - Host-based routing
# - SSL termination
# - Health checks
```

---

## 🏆 Practice Exercises

### Exercise 1: Install HAProxy
```bash
# Install
sudo apt install haproxy

# Create basic config
sudo nano /etc/haproxy/haproxy.cfg

# Test config
sudo haproxy -c -f /etc/haproxy/haproxy.cfg

# Restart
sudo systemctl restart haproxy

# Test
curl localhost
```

### Exercise 2: Configure Nginx LB
```bash
# Create upstream config
sudo tee /etc/nginx/conf.d/upstream.conf << 'EOF'
upstream backend {
    server 192.168.1.10:80;
    server 192.168.1.11:80;
}
EOF

# Reload
sudo systemctl reload nginx
```

### Exercise 3: Health Check Script
```bash
#!/bin/bash
# health_check.sh

# Check each backend
for server in 192.168.1.10 192.168.1.11; do
    if curl -sf "http://$server/health" > /dev/null; then
        echo "✓ $server OK"
    else
        echo "✗ $server DOWN"
    fi
done
```

---

## 📋 Load Balancing Cheat Sheet

| Tool | Type | Best For |
|------|------|----------|
| HAProxy | L4/L7 | High performance |
| Nginx | L7 | Web applications |
| AWS ALB | Cloud | AWS environments |
| DNS round robin | DNS | Simple setups |

### HAProxy Commands
```bash
# Check config
haproxy -c -f /etc/haproxy/haproxy.cfg

# Stats
curl http://localhost:8404/stats

# Reload
systemctl reload haproxy
```

---

## 🎓 Final Project: Load Balancer Operations Manager

Now that you've mastered the theory of load balancing, let's see how a professional Site Reliability Engineer (SRE) might automate the management of their traffic controllers. We'll examine the "Load Balancer Manager" — a tool that provides a unified interface for managing both Nginx and HAProxy configurations.

### What the Load Balancer Operations Manager Does:
1. **Provides a Unified Status** showing whether your load balancers are currently running.
2. **Automates Configuration Testing** to ensure there are no syntax errors before reloading.
3. **Simplifies Service Reloading** with one-word commands that handle all the complex system calls.
4. **Audits Backend Servers** by parsing configuration files to show you where traffic is being sent.
5. **Monitors Performance Stats** by calling the internal metrics APIs of the load balancers.
6. **Validates Configuration Integrity** using the native test flags of each engine.

### Key Snippet: Safe Configuration Reloading
One of the most dangerous things you can do is reload a load balancer with a broken configuration. The manager prevents this by running a test first.

```bash
cmd_nginx_reload() {
    # 1. Run the native Nginx configuration test (-t)
    # 2. Only if the test passes (&&), reload the service
    if sudo nginx -t; then
        sudo systemctl reload nginx
        log "Nginx configuration reloaded successfully!"
    else
        error "Nginx test failed! Please fix your config before reloading."
    fi
}
```

### Key Snippet: Auditing Configured Backends
The manager can "peek" inside your complex config files to give you a quick list of your active backend servers.

```bash
cmd_backends() {
    echo "=== Configured Backend Servers ==="
    
    # Use grep to find 'server' lines in HAProxy or 'upstream' blocks in Nginx
    # This gives you a quick overview of your network traffic flow
    grep -E "server |upstream " /etc/haproxy/haproxy.cfg /etc/nginx/nginx.conf 2>/dev/null || \
        echo "No backend servers found."
}
```

**Pro Tip:** Automation tools like this allow you to scale your infrastructure from 2 servers to 200 without increasing the complexity of your daily operations!

---

## ✅ Stack 48 Complete!

Congratulations! You've successfully mastered the "Traffic Cops" of the internet! You can now:
- ✅ **Architect load balancing strategies** to distribute traffic evenly
- ✅ **Configure HAProxy and Nginx** as high-performance traffic controllers
- ✅ **Implement health checks** to automatically skip failed backend servers
- ✅ **Master different algorithms** like Round Robin and Least Connections
- ✅ **Automate configuration changes** and service reloads safely
- ✅ **Monitor traffic metrics** to identify system bottlenecks

### What's Next?
In the next stack, we'll dive into **High Availability**. You'll learn how to group multiple servers together so that if one fails, another takes over instantly without users ever noticing!

**Next: Stack 49 - High Availability →**

---

*End of Stack 48*
-- **Previous:** [Stack 47 → Advanced Git](47_advanced_git.md)
-- **Next:** [Stack 49 - High Availability](49_high_availability.md)
