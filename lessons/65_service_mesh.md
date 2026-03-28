# 🔗 STACK 65: SERVICE MESH BASICS
## Istio & Linkerd for Microservices

---

## 🔰 What is a Service Mesh?

A service mesh provides **infrastructure layer** for service-to-service communication:

- **Traffic Management**: Routing, load balancing
- **Observability**: Metrics, tracing, logging
- **Security**: mTLS, authorization
- **Reliability**: retries, timeouts, circuit breakers

### Popular Solutions
| Mesh | Complexity | Features |
|------|------------|----------|
| **Istio** | High | Full-featured |
| **Linkerd** | Lower | Simpler, Kubernetes-first |
| **Consul Connect** | Medium | HashiCorp ecosystem |
| **Cilium** | Medium | eBPF-based |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────┐
│                 Service Mesh                  │
│                                               │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │ Service │───▶│  Sidecar│───▶│ Service │  │
│  │   A     │    │  Proxy  │    │   B     │  │
│  └─────────┘    └─────────┘    └─────────┘  │
│                      │                        │
│              ┌──────▼──────┐                  │
│              │   Control   │                  │
│              │   Plane    │                  │
│              └─────────────┘                  │
└──────────────────────────────────────────────┘
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

## ✅ Stack 65 Complete!

You learned:
- ✅ Service mesh concepts and architecture
- ✅ Linkerd installation and basics
- ✅ Istio installation and basics
- ✅ Traffic management (canary, routing)
- ✅ mTLS security
- ✅ Observability (metrics, tracing)
- ✅ Retry and timeout policies
- ✅ Circuit breaker pattern

---

*End of Stack 65*
