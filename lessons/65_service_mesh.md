# 🔗 STACK 65: SERVICE MESH BASICS
## Istio & Linkerd for Microservices

**What is a Service Mesh?** Think of a service mesh as a "traffic control system for microservices." When you have dozens of services talking to each other, the service mesh handles all the communication plumbing - routing, encryption, retries, monitoring - so your services can focus on their actual job.

**Why This Matters?** In microservice architectures, service-to-service communication is complex. A service mesh solves this at the infrastructure level, not requiring every developer to implement retry logic, encryption, and monitoring in their code.

---

## 🔰 What is a Service Mesh?

A service mesh provides an **infrastructure layer** for service-to-service communication:

| Feature | What It Does | Analogy |
|---------|--------------|---------|
| **Traffic Management** | Routing, load balancing, traffic splitting | A traffic cop directing cars |
| **Observability** | Metrics, tracing, logging for all service calls | CCTV cameras monitoring every road |
| **Security** | mTLS (mutual encryption), authorization | Encrypted phone lines between services |
| **Reliability** | Retries, timeouts, circuit breakers | Automatic detour when a road is blocked |

### Popular Solutions
| Mesh | Complexity | Best For | Analogy |
|------|------------|----------|---------|
| **Istio** | High (powerful but complex) | Large enterprises, full feature set | A fully-loaded Swiss Army knife |
| **Linkerd** | Lower (simple, fast) | Teams wanting simplicity | A reliable pocket knife |
| **Consul Connect** | Medium | HashiCorp ecosystem users | A modular toolkit |
| **Cilium** | Medium | eBPF-based, high performance | A modern power tool |

### Service Mesh Analogy for Beginners
```
Without service mesh:
  Service A → writes retry logic → writes encryption → writes monitoring
  Service B → writes retry logic → writes encryption → writes monitoring
  Service C → writes retry logic → writes encryption → writes monitoring
  (Everyone duplicates the same plumbing!)

With service mesh:
  Service A → does its job (mesh handles communication)
  Service B → does its job (mesh handles communication)
  Service C → does its job (mesh handles communication)
  (Infrastructure is handled for you!)
```

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│                 Service Mesh                     │
│                                                  │
│  │ Service │───▶│  Sidecar│───▶│ Service │      │   
│  ┌─────────┐     ┌─────────┐    ┌─────────┐      │
│  │   A     │     │  Proxy  │    │   B     │      │
│  └─────────┘     └─────────┘    └─────────┘      │
│                      │                           │
│              ┌──────▼──────┐                     │
│              │   Control   │                     │
│              │   Plane     │                     │   
│              └─────────────┘                     │
└─────────────────────────────────────────────    ─┘
```

---

## 🔧 Linkerd (Simpler Option)

### Installation
```bash
# Install Linkerd CLI
curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin

# Verify
linkerd version

# Install control plane
linkerd install | kubectl apply -f -

# Check status
linkerd check
```

### Deploy Sample App
```bash
# Deploy emojivoto
kubectl apply -f https://run.linkerd.io/emojivoto.yml

# Inject sidecars
kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -

# View dashboard
linkerd dashboard
```

### Traffic Management
```bash
# Create ServiceProfile for canary routing
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: linkerd-config
data:
  config: |
    apiVersion: linkerd.io/v1alpha2
    kind: ServiceProfile
    metadata:
      name: webapp.default.svc.cluster.local
    spec:
      routes:
      - condition:
          pathPrefix: /api/v1
        name: /api/v1
        isRetryable: true
        timeout: 500ms
EOF
```

---

## 🌀 Istio (Full-Featured)

### Installation
```bash
# Install istioctl
curl -sL https://istio.io/downloadIstio | sh -
export PATH=$PATH:$HOME/istio-*/bin

# Install Istio
istioctl install --set profile=demo -y

# Enable injection
kubectl label namespace default istio-injection=enabled

# Check status
istioctl version
```

### Deploy App
```bash
# Deploy sample
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/bookinfo/platform/kube/bookinfo.yaml

# Inject sidecar
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/bookinfo/platform/kube/bookinfo.yaml

# Check pods have sidecar
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
```

---

## 🌐 Traffic Management

### Virtual Services
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - name: v1
    match:
    - headers:
        version:
          exact: v1
    route:
    - destination:
        host: myapp
        subset: v1
  - name: canary
    route:
    - destination:
        host: myapp
        subset: v2
      weight: 10
    - destination:
        host: myapp
        subset: v1
      weight: 90
```

### Apply with Bash
```bash
#!/bin/bash
# apply_canary.sh

kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-canary
spec:
  hosts:
  - myapp.default.svc.cluster.local
  http:
  - route:
    - destination:
        host: myapp.default.svc.cluster.local
        subset: v2
      weight: 20
    - destination:
        host: myapp.default.svc.cluster.local
        subset: v1
      weight: 80
EOF

echo "Canary routing applied: 20% to v2"
```

---

## 🔒 mTLS (Mutual TLS)

### Enable mTLS
```yaml
# PeerAuthentication
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

### Apply
```bash
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF
```

### Check mTLS Status
```bash
# Linkerd
linkerd mtlc check

# Istio
istioctl x authz check deployment.myapp
```

---

## 📊 Observability

### Linkerd Viz
```bash
# Install metrics
linkerd viz install | kubectl apply -f -

# View dashboard
linkerd viz dashboard

# Get metrics
linkerd viz stat deployments
linkerd viz routes deploy/webapp
```

### Istio Telemetry
```bash
# Install addons
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml

# Access Kiali
istioctl dashboard kiali
```

### Get Metrics via CLI
```bash
# Linkerd
linkerd viz metrics deployment/webapp

# Istio
istioctl dashboard prometheus
```

---

## ⚙️ Retry & Timeout

### Istio Retry Policy
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - route:
    - destination:
        host: myapp
    retries:
      attempts: 3
      perTryTimeout: 2s
      retryOn: gateway-error,connect-failure,refused-stream
    timeout: 10s
```

### Apply
```bash
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp
  http:
  - route:
    - destination:
        host: myapp
    retries:
      attempts: 3
      perTryTimeout: 2s
    timeout: 10s
EOF
```

---

## 🔄 Circuit Breaker

### Istio DestinationRule
```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: myapp
spec:
  host: myapp
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        h2UpgradePolicy: UPGRADE
        http2MaxRequests: 1000
        maxRequestsPerConnection: 10
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
```

### Apply
```bash
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: myapp
spec:
  host: myapp
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http2MaxRequests: 1000
        maxRequestsPerConnection: 10
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
EOF
```

---

## 🧹 Uninstall

### Linkerd
```bash
# Remove data plane
linkerd install --ignore-cluster | kubectl delete -f -

# Remove control plane
linkerd install | kubectl delete -f -
```

### Istio
```bash
istioctl uninstall --purge -y
kubectl delete namespace istio-system
```

---

## 📝 Bash Scripts

### Quick Install Linkerd + App
```bash
#!/bin/bash
# setup_linkerd_app.sh

NAMESPACE="${1:-myapp}"

# Install Linkerd
linkerd install | kubectl apply -f -

# Label namespace
kubectl create namespace "$NAMESPACE"
kubectl label namespace "$NAMESPACE" linkerd.io/inject=enabled

# Deploy app
kubectl create deployment "$NAMESPACE" --image=nginx -n "$NAMESPACE"
kubectl expose deployment "$NAMESPACE" --port=80 -n "$NAMESPACE"

# Check
linkerd -n "$NAMESPACE" check --proxy

echo "App deployed in $NAMESPACE with Linkerd"
```

### Monitor Service Mesh
```bash
#!/bin/bash
# mesh_status.sh

echo "=== Linkerd Status ==="
linkerd check

echo ""
echo "=== Traffic ==="
linkerd viz stat deployments

echo ""
echo "=== Routes ==="
linkerd viz routes deploy
```

---

## 🎓 Final Project: The Service Mesh Operations Manager

Now that you've mastered the concepts of sidecars, control planes, and mTLS, let's see how a professional Cloud Architect might automate the management of a service mesh. We'll examine the "Service Mesh Manager" — a tool that automates the injection of proxies, monitors traffic health, and manages security policies across your microservices.

### What the Service Mesh Operations Manager Does:
1. **Automates Sidecar Injection** by labeling Kubernetes namespaces for Istio or Linkerd.
2. **Performs mTLS Audits** to ensure all communication between services is fully encrypted.
3. **Manages Traffic Splitting** by generating VirtualService and ServiceProfile objects for canary deployments.
4. **Monitors Real-Time Metrics** (Success Rate, Latency, Throughput) using mesh-specific CLI tools.
5. **Configures Resilience Policies** (Retries, Timeouts, Circuit Breakers) with one-word commands.
6. **Validates Mesh Health** using `istioctl analyze` or `linkerd check` to catch configuration errors.

### Key Snippet: Automated Canary Deployment
The manager simplifies complex YAML by using Bash to generate a traffic-splitting rule.

```bash
apply_canary_rule() {
    local service=$1
    local v2_weight=$2 # e.g., 10 for 10% traffic
    local v1_weight=$((100 - v2_weight))
    
    echo "Routing ${v2_weight}% of traffic to $service v2..."
    
    kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: $service
spec:
  hosts: [ "$service" ]
  http:
  - route:
    - destination: { host: "$service", subset: "v2" }
      weight: $v2_weight
    - destination: { host: "$service", subset: "v1" }
      weight: $v1_weight
EOF
}
```

### Key Snippet: Security Audit (mTLS)
Ensuring that encryption is actually ON is critical. The manager checks the status of every pod in the mesh.

```bash
check_mesh_security() {
    echo "=== Service Mesh Encryption Audit ==="
    
    if command -v istioctl &>/dev/null; then
        # Istio: check authentication policies
        istioctl x authz check
    elif command -v linkerd &>/dev/null; then
        # Linkerd: check mTLS status
        linkerd viz -n default tap deploy
    fi
}
```

**Pro Tip:** Service Meshes are powerful but complex. Building a Bash manager allows your team to use advanced features like "Canary Releases" safely without needing to become Kubernetes experts!

---

## ✅ Stack 65 Complete!

Congratulations! You have reached the ultimate peak of the Full-Stack Bash Course! You can now:
- ✅ **Architect Microservice Communication** using professional Service Meshes
- ✅ **Implement Zero-Trust Security** with automatic mTLS encryption
- ✅ **Perform Advanced Traffic Steering** (Canary, Blue-Green, Shadow)
- ✅ **Monitor Global Observability** with tracing and telemetry
- ✅ **Build Resilient Systems** using circuit breakers and retries
- ✅ **Automate Mesh Operations** using expert-level Bash scripts

---

## 🏆 GRADUATION: BASH MASTER CERTIFIED!

You have successfully completed **all 65 Stacks** of the Full-Stack Bash Course! 🎓

From your first `hello_bash.sh` to managing global service meshes and kernel optimizations, you have built a foundation that places you in the top 1% of shell scripters.

### Your Journey at a Glance:
1.  🐚 **Fundamentals** (1-12): The Core Power of the Shell.
2.  🛠️ **Automation** (13-25): Managing Git, Docker, and Servers.
3.  🚀 **DevOps & Cloud** (26-41): Kubernetes, Terraform, and CI/CD.
4.  🏗️ **Infrastructure** (42-49): High Availability and Hardware.
5.  🔐 **Expert Topics** (50-59): Security, APIs, and Clusters.
6.  🌌 **Specializations** (60-65): AWK, Kernel Tuning, and Service Mesh.

**The terminal is no longer a tool; it is your playground. Keep building, keep automating, and keep exploring!**

---

*End of Stack 65 - COURSE COMPLETE!* 🎉
-- **Previous:** [Stack 64 → Log Aggregation](64_log_aggregation.md)
-- **Next:** [Stack 66 - Final Project: The Ultimate Bash Toolkit](66_final_project.md)