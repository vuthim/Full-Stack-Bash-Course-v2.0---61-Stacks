# ☸️ STACK 31: KUBERNETES BASICS
## Container Orchestration with kubectl

**What is Kubernetes?** Think of Kubernetes (K8s) as an automated system for managing containerized applications. Just like a traffic controller directs cars to prevent congestion and accidents, Kubernetes manages your containers to ensure they run smoothly, scale when needed, and recover automatically from failures.

Instead of manually starting, stopping, and monitoring each container (which becomes impossible at scale), Kubernetes handles:
- **Scheduling** - Decides which servers (nodes) should run your containers
- **Scaling** - Automatically increases or decreases the number of container copies based on demand
- **Self-healing** - Automatically restarts failed containers and replaces unresponsive ones

**Why Should Bash Scripters Care?** Modern infrastructure runs on Kubernetes. Your bash scripts will interact with K8s clusters to deploy, monitor, and manage containerized applications. Understanding Kubernetes fundamentals allows you to write scripts that work with modern cloud-native environments.

---

## 🔰 What is Kubernetes?

Kubernetes (K8s) is an open-source container orchestration platform that automates:
- ✅ **Container deployment** - Automatically place containers on healthy servers
- ✅ **Scaling** - Add/remove copies based on traffic
- ✅ **Management** - Self-healing, rolling updates, rollbacks

### Kubernetes Analogy for Beginners
```
Without K8s:  You manually assign each container to a server (tedious!)
With K8s:     You say "I need 3 web servers" and K8s handles the rest
```

### Key Concepts (Beginner-Friendly)
| Concept | What It Is | Why It Matters | Real-World Analogy |
|---------|------------|----------------|---------------------|
| **Pod** | Smallest deployable unit in K8s | Contains one or more containers that work together | Like a single apartment unit in a building |
| **Service** | Network endpoint that exposes your app | Provides a stable IP address and DNS name for accessing your application | Like a building's main address that never changes, even if apartments inside are renovated |
| **Deployment** | Manages the lifecycle of pods | Ensures you have the right number of pod copies running, handles updates and rollbacks | Like a property manager who makes sure you always have the right number of tenants and handles lease renewals |
| **Namespace** | Logical partition for resources | Helps organize and isolate different projects or environments within the same cluster | Like different floors in a building, each dedicated to a specific company or department |

---

## ⚡ Installing kubectl

kubectl is the command-line tool you'll use to interact with Kubernetes clusters. Think of it as your remote control for managing containerized applications running in K8s.

### Linux
```bash
# Download kubectl (gets the latest stable version)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make the downloaded file executable
chmod +x kubectl

# Move kubectl to a directory in your PATH so you can run it from anywhere
sudo mv kubectl /usr/local/bin/

# Verify the installation worked correctly
kubectl version --client
```
> 💡 **Pro Tip:** The `$(curl -L -s https://dl.k8s.io/release/stable.txt)` part automatically fetches the latest stable version number, so you always get the most recent release without having to look it up manually.

### macOS
```bash
# Via Homebrew
brew install kubernetes-cli

# Or via curl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
```

---

## 🔧 Basic kubectl Commands

### Cluster Information
```bash
# Get cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# List namespaces
kubectl get namespaces

# Switch namespace
kubectl config set-context --current --namespace=default
```

### Working with Pods
```bash
# List pods
kubectl get pods

# List pods in all namespaces
kubectl get pods -A

# Describe pod
kubectl describe pod mypod

# Get pod details (JSON)
kubectl get pod mypod -o json

# Delete pod
kubectl delete pod mypod
```

---

## 📦 Deployments

### Create Deployment
```bash
# From file
kubectl apply -f deployment.yaml

# From command line
kubectl create deployment nginx --image=nginx

# Scale deployment
kubectl scale deployment nginx --replicas=3

# Update image
kubectl set image deployment/nginx nginx=nginx:1.21
```

### Deployment Commands
```bash
# List deployments
kubectl get deployments

# Describe deployment
kubectl describe deployment nginx

# View rollout status
kubectl rollout status deployment/nginx

# Rollback
kubectl rollout undo deployment/nginx

# History
kubectl rollout history deployment/nginx
```

---

## 🌐 Services

### Service Types
```bash
# ClusterIP (internal)
kubectl expose deployment nginx --port=80 --target-port=8080

# NodePort (external)
kubectl expose deployment nginx --type=NodePort --port=80

# LoadBalancer (cloud)
kubectl expose deployment nginx --type=LoadBalancer --port=80
```

### Service Commands
```bash
# List services
kubectl get services
kubectl get svc

# Describe service
kubectl describe svc nginx
```

---

## 📝 Kubernetes Manifest

### Basic YAML
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### Apply and Manage
```bash
# Apply manifest
kubectl apply -f deployment.yaml

# View all resources
kubectl get all

# Delete all
kubectl delete -f deployment.yaml
```

---

## 🔍 Debugging

### Pod Debugging
```bash
# Check pod logs
kubectl logs mypod

# Follow logs
kubectl logs -f mypod

# Previous container logs
kubectl logs mypod --previous

# Execute in pod
kubectl exec -it mypod -- /bin/bash

# Port forward to pod
kubectl port-forward mypod 8080:8080

# Copy from pod
kubectl cp mypod:/app/logs ./logs
```

### Troubleshooting
```bash
# Pod status
kubectl get pods -o wide

# Events
kubectl get events --sort-by='.lastTimestamp'

# Node resources
kubectl top nodes

# Pod resources
kubectl top pods
```

---

## 🔄 ConfigMaps and Secrets

### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  DATABASE_URL: "postgres://db:5432/app"
  CACHE_ENABLED: "true"
---
# Use in pod
env:
  - name: DATABASE_URL
    valueFrom:
      configMapKeyRef:
        name: myapp-config
        key: DATABASE_URL
```

### Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
type: Opaque
data:
  # echo -n "password" | base64
  password: cGFzc3dvcmQ=
---
# Use in pod
env:
  - name: PASSWORD
    valueFrom:
      secretKeyRef:
        name: myapp-secret
        key: password
```

---

## 📊 Ingress

### Basic Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 80
```

### Commands
```bash
# Apply ingress
kubectl apply -f ingress.yaml

# List ingress
kubectl get ingress
```

---

## 🏆 Practice Exercises

### Exercise 1: Deploy Application
```bash
# Create deployment
kubectl create deployment demo --image=nginx

# Scale it
kubectl scale deployment demo --replicas=2

# Expose it
kubectl expose deployment demo --port=80

# Check status
kubectl get all
```

### Exercise 2: Create Full Manifest
```yaml
# Save as app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
EOF

kubectl apply -f app.yaml
```

---

## 📋 kubectl Cheat Sheet

| Command | Purpose |
|---------|---------|
| `kubectl get` | List resources |
| `kubectl describe` | Show details |
| `kubectl apply` | Apply config |
| `kubectl delete` | Remove resources |
| `kubectl logs` | View logs |
| `kubectl exec` | Run command in pod |
| `kubectl port-forward` | Access pod |

---

## 🎓 Final Project: Kubernetes Cluster Manager

Now that you've mastered the basics of Kubernetes, let's see how a professional DevOps engineer might automate cluster operations. We'll examine the "K8s Manager" — a tool that simplifies common `kubectl` tasks like scaling applications, checking logs, and monitoring cluster health.

### What the Kubernetes Cluster Manager Does:
1. **Audits Cluster Health** by listing nodes, namespaces, and system info.
2. **Manages Workloads** (pods, deployments, services) with simplified commands.
3. **Automates Scaling** of deployments to handle increased traffic.
4. **Handles Application Restarts** using zero-downtime rolling updates.
5. **Streams Pod Logs** directly from the deployment without needing to find pod IDs.
6. **Validates kubectl Installation** to ensure your environment is ready for action.

### Key Snippet: Deployment-Aware Logging
One of the most annoying parts of `kubectl` is having to find the specific Pod name just to see logs. The manager automates this by targeting the *deployment* directly.

```bash
cmd_logs() {
    local name=$1
    # --tail=50: Show only the last 50 lines
    # Targeting 'deployment/name' instead of 'pod/name'
    kubectl logs deployment/"$name" --tail=50
}
```

### Key Snippet: Simple Scaling
Scaling an application should be a one-word command. The manager wraps the `kubectl scale` command to make it more intuitive.

```bash
cmd_scale() {
    local name=$1
    local replicas=$2
    
    # Scale the specific deployment to the requested number of copies
    kubectl scale deployment "$name" --replicas="$replicas"
    log "Scaled '$name' to $replicas copies successfully!"
}
```

**Pro Tip:** Automation tools like this are how SREs (Site Reliability Engineers) manage thousands of containers across global clusters without getting overwhelmed!

---

## ✅ Stack 31 Complete!

Congratulations! You've successfully entered the world of Cloud Orchestration! You can now:
- ✅ **Understand core K8s concepts** (Pods, Deployments, Services)
- ✅ **Control clusters** using the `kubectl` command-line tool
- ✅ **Deploy and scale applications** across multiple nodes
- ✅ **Manage networking** to expose your services to the world
- ✅ **Troubleshoot container issues** using logs and describe commands
- ✅ **Perform rolling updates** to keep your apps running during changes

### What's Next?
In the next stack, we'll dive into **User Management**. You'll learn how to securely manage accounts, groups, and permissions on your Linux systems!

**Next: Stack 32 - User Management →**

---

*End of Stack 31*