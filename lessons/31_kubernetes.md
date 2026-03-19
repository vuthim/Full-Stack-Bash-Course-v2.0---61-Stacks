# ☸️ STACK 31: KUBERNETES BASICS
## Container Orchestration with kubectl

---

## 🔰 What is Kubernetes?

Kubernetes (K8s) is an open-source container orchestration platform that automates:
- Container deployment
- Scaling
- Management

### Key Concepts
| Concept | Description |
|---------|-------------|
| Pod | Smallest deployable unit |
| Service | Network endpoint |
| Deployment | Manages pods |
| Namespace | Resource isolation |

---

## ⚡ Installing kubectl

### Linux
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify
kubectl version --client
```

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

## ✅ Stack 31 Complete!

You learned:
- ✅ Kubernetes basics and concepts
- ✅ Installing kubectl
- ✅ Working with pods
- ✅ Deployments and scaling
- ✅ Services and networking
- ✅ Debugging
- ✅ ConfigMaps and Secrets
- ✅ Ingress

### Next: Stack 32 - User Management →

---

*End of Stack 31*