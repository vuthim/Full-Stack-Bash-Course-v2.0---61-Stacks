# ☸️ STACK 59: MULTI-CLUSTER ORCHESTRATION [ELECTIVE]
## Managing Distributed Systems at Scale

**What is Multi-Cluster?** Think of a single Kubernetes cluster like one data center. Multi-cluster means managing MULTIPLE data centers across regions, clouds, or environments. It's like being a conductor of an orchestra where each section is in a different building!

**Why This Matters?** Large organizations run workloads across multiple clusters for redundancy, compliance, and scale. If you're going to manage infrastructure at enterprise level, multi-cluster is essential knowledge.

---

## 🔰 What You'll Learn

| Topic | What It Covers | Why It Matters |
|-------|---------------|----------------|
| **Multi-cluster Kubernetes** | Manage multiple K8s clusters together | High availability, geographic distribution |
| **Configuration management** | Keep environments consistent | No more "works in dev, breaks in prod" |
| **Deployment orchestration** | Roll out changes across clusters safely | Zero-downtime updates at scale |
| **Service mesh basics** | Connect services across clusters | Services communicate securely and reliably |
| **Infrastructure automation** | Script the management of everything | One script, many clusters |

---

## 🐳 Container Orchestration Basics

### Docker Swarm Management
```bash
#!/bin/bash
# docker_swarm.sh

# Initialize swarm
init_swarm() {
    docker swarm init --advertise-addr "$ADVERTISE_IP"
}

# Join worker
join_worker() {
    local token="$1"
    docker swarm join --token "$token" "$MANAGER_IP:2377"
}

# List nodes
list_nodes() {
    docker node ls
}

# Deploy stack
deploy_stack() {
    docker stack deploy -c docker-compose.yml "$STACK_NAME"
}

# Service management
scale_service() {
    docker service scale "${STACK_NAME}_$SERVICE=$REPLICAS"
}

# Rolling update
update_service() {
    docker service update \
        --image "$NEW_IMAGE" \
        --update-delay 10s \
        --update-parallelism 2 \
        "${STACK_NAME}_$SERVICE"
}
```

---

## ☸ Kubernetes Management

### kubectl Basics
```bash
#!/bin/bash
# kubectl_basics.sh

# Context management
list_contexts() {
    kubectl config get-contexts
}

switch_context() {
    kubectl config use-context "$CONTEXT"
}

create_context() {
    kubectl config set-cluster "$CLUSTER" \
        --server="$KUBE_SERVER" \
        --certificate-authority="$CA_PATH"
}

# Get resources
get_pods() {
    kubectl get pods -n "$NAMESPACE" -o wide
}

get_services() {
    kubectl get svc -n "$NAMESPACE"
}

get_deployments() {
    kubectl get deployments -n "$NAMESPACE"
}

# Describe resources
describe_pod() {
    kubectl describe pod "$POD" -n "$NAMESPACE"
}

# Logs
pod_logs() {
    kubectl logs "$POD" -n "$NAMESPACE" --tail=100
}

follow_logs() {
    kubectl logs -f "$POD" -n "$NAMESPACE"
}

# Execute in pod
exec_pod() {
    kubectl exec -it "$POD" -n "$NAMESPACE" -- /bin/sh
}
```

### Multi-Cluster kubectl
```bash
#!/bin/bash
# multi_kubectl.sh

# Define clusters
declare -A CLUSTERS
CLUSTERS[prod]="production.example.com:6443"
CLUSTERS[staging]="staging.example.com:6443"
CLUSTERS[dev]="dev.example.com:6443"

# Run command on specific cluster
k8s_exec() {
    local cluster="$1"
    shift
    local context="cluster-${cluster}"
    
    kubectl --context="$context" "$@"
}

# Run on all clusters
k8s_all() {
    for cluster in "${!CLUSTERS[@]}"; do
        echo "=== $cluster ==="
        k8s_exec "$cluster" "$@"
    done
}

# Usage
k8s_all get pods -n kube-system
k8s_exec prod get nodes
```

---

## 📦 Helm Chart Management

### Helm Basics
```bash
#!/bin/bash
# helm_basics.sh

# Add repository
add_repo() {
    helm repo add "$REPO_NAME" "$REPO_URL"
    helm repo update
}

# Install chart
install_chart() {
    helm install "$RELEASE_NAME" "$CHART" \
        --namespace "$NAMESPACE" \
        --set "image.tag=$VERSION" \
        -f values.yaml
}

# Upgrade
upgrade_chart() {
    helm upgrade "$RELEASE_NAME" "$CHART" \
        --namespace "$NAMESPACE" \
        --set "image.tag=$VERSION" \
        -f values-prod.yaml
}

# Rollback
rollback() {
    helm rollback "$RELEASE_NAME" "$REVISION" \
        --namespace "$NAMESPACE"
}

# Template rendering
render_template() {
    helm template "$RELEASE_NAME" "$CHART" \
        --namespace "$NAMESPACE" \
        --set "image.tag=latest"
}

# List releases
list_releases() {
    helm list -n "$NAMESPACE" -a
}
```

### Multi-Environment Helm
```bash
#!/bin/bash
# multi_helm.sh

# Deploy to multiple environments
deploy_all() {
    local chart="myapp"
    
    # Dev
    helm upgrade --install dev "$chart" \
        --namespace dev \
        --set "replicas=1" \
        --set "resources.requests.memory=256Mi"
    
    # Staging
    helm upgrade --install staging "$chart" \
        --namespace staging \
        --set "replicas=2" \
        --set "resources.requests.memory=512Mi"
    
    # Production
    helm upgrade --install prod "$chart" \
        --namespace production \
        --set "replicas=5" \
        --set "resources.requests.memory=1Gi"
}

# Check status across environments
status_all() {
    for env in dev staging production; do
        echo "=== $env ==="
        helm status "$env" -n "$env" | head -10
    done
}
```

---

## 🔄 Deployment Automation

### Blue-Green Deployment
```bash
#!/bin/bash
# blue_green.sh

NAMESPACE="production"
SERVICE="myapp"

# Deploy blue version
deploy_blue() {
    helm upgrade blue ./chart \
        --namespace "$NAMESPACE" \
        --set "image.tag=blue" \
        --create-namespace
    
    # Wait for rollout
    kubectl rollout status deployment/blue -n "$NAMESPACE"
}

# Deploy green version
deploy_green() {
    helm upgrade green ./chart \
        --namespace "$NAMESPACE" \
        --set "image.tag=green" \
        --create-namespace
    
    kubectl rollout status deployment/green -n "$NAMESPACE"
}

# Switch traffic to new version
switch_traffic() {
    local version="$1"  # blue or green
    
    # Update service to point to new version
    kubectl patch svc "$SERVICE" -n "$NAMESPACE" \
        -p "{\"spec\":{\"selector\":{\"app\":\"$SERVICE\",\"version\":\"$version\"}}}"
}

# Quick rollback
rollback() {
    local current=$(kubectl get svc "$SERVICE" -n "$NAMESPACE" -o jsonpath='{.spec.selector.version}')
    [ "$current" = "blue" ] && switch_traffic "green" || switch_traffic "blue"
}
```

### Canary Deployment
```bash
#!/bin/bash
# canary.sh

NAMESPACE="production"

# Deploy canary
deploy_canary() {
    local version="$1"
    local replicas="$2"  # e.g., 10%
    
    # Create canary deployment
    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-canary
  namespace: $NAMESPACE
spec:
  replicas: $replicas
  selector:
    matchLabels:
      app: myapp
      version: canary
  template:
    metadata:
      labels:
        app: myapp
        version: canary
    spec:
      containers:
      - name: app
        image: myapp:$version
EOF
}

# Adjust canary weight
adjust_weight() {
    local percent="$1"
    
    # Update canary replica count
    kubectl scale deployment/myapp-canary \
        -n "$NAMESPACE" \
        --replicas="$percent"
    
    # Update main replicas
    kubectl scale deployment/myapp \
        -n "$NAMESPACE" \
        --replicas=$((100 - percent))
}

# Promote canary
promote_canary() {
    # Update main deployment image
    canary_image=$(kubectl get deployment myapp-canary \
        -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}')
    
    kubectl set image deployment/myapp \
        app="$canary_image" -n "$NAMESPACE"
    
    # Scale down canary
    kubectl scale deployment/myapp-canary -n "$NAMESPACE" --replicas=0
}
```

---

## 🔗 Service Mesh Basics

### Istio Management
```bash
#!/bin/bash
# istio.sh

# Deploy with Istio
deploy_with_istio() {
    kubectl label namespace default istio-injection=enabled
    
    # Deploy application
    kubectl apply -f app.yaml
    
    # Deploy virtual service
    kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
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
        subset: v1
      weight: 90
    - destination:
        host: myapp
        subset: v2
      weight: 10
EOF
}

# Traffic mirroring
enable_mirroring() {
    kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
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
        subset: v1
    mirror:
      host: myapp
      subset: v2
EOF
}

# Circuit breaker
set_circuit_breaker() {
    kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
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
        http1MaxPendingRequests: 100
        http2MaxRequests: 1000
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
EOF
}
```

---

## 🌐 Cross-Cluster Management

### ArgoCD for GitOps
```bash
#!/bin/bash
# argocd.sh

# Install ArgoCD
install_argocd() {
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
}

# Login
argocd_login() {
    argocd login "$ARGOCD_SERVER" --username admin --password "$PASSWORD"
}

# Add cluster
add_cluster() {
    argocd cluster add "$K8S_CONTEXT" --name "$CLUSTER_NAME"
}

# Create application
create_app() {
    argocd app create "$APP_NAME" \
        --repo "$REPO_URL" \
        --path "$PATH" \
        --dest-server "$DEST_SERVER" \
        --dest-namespace "$NAMESPACE" \
        --sync-policy auto
}

# Sync all
sync_all() {
    argocd app list -o json | \
        jq -r '.[].metadata.name' | \
        xargs -I {} argocd app sync {}
}
```

### Kustomize for Multi-Environment
```bash
#!/bin/bash
# kustomize.sh

# base/kustomization.yaml
# overlays/dev/kustomization.yaml
# overlays/prod/kustomization.yaml

# Build environment
build_env() {
    local env="$1"  # dev, staging, prod
    
    kustomize build "overlays/$env"
}

# Apply dev
apply_dev() {
    kustomize build "overlays/dev" | kubectl apply -f -
}

# Apply prod
apply_prod() {
    kustomize build "overlays/prod" | kubectl apply -f -
}

# Diff
diff_env() {
    local env="$1"
    kustomize build "overlays/$env" | kubectl diff -f -
}
```

---

## 📊 Monitoring Across Clusters

### Multi-Cluster Monitoring
```bash
#!/bin/bash
# monitoring.sh

CLUSTERS=("prod" "staging" "dev")

# Get pod count per cluster
pod_counts() {
    for cluster in "${CLUSTERS[@]}"; do
        echo "=== $cluster ==="
        kubectl --context="cluster-$cluster" get pods -A --no-headers | wc -l
    done
}

# Resource usage
resource_usage() {
    for cluster in "${CLUSTERS[@]}"; do
        echo "=== $cluster ==="
        kubectl --context="cluster-$cluster" top nodes 2>/dev/null || \
            kubectl --context="cluster-$cluster" top pods -A 2>/dev/null | tail -5
    done
}

# Health check
cluster_health() {
    for cluster in "${CLUSTERS[@]}"; do
        status=$(kubectl --context="cluster-$cluster" get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}')
        if echo "$status" | grep -q "False"; then
            echo "WARNING: $cluster has unhealthy nodes"
        else
            echo "OK: $cluster"
        fi
    done
}
```

---

## 🏆 Practice Exercises

### Exercise 1: Multi-Cluster Deploy
Deploy an app to 3 clusters using kubectl

### Exercise 2: Helm Chart
Create a production-ready Helm chart

### Exercise 3: GitOps Pipeline
Set up ArgoCD for your clusters

---

## ✅ Stack 59 Complete!

You learned:
- ✅ Docker Swarm management
- ✅ kubectl basics
- ✅ Multi-cluster kubectl
- ✅ Helm chart management
- ✅ Multi-environment deployments
- ✅ Blue-Green and Canary deployments
- ✅ Service mesh basics
- ✅ ArgoCD and GitOps
- ✅ Kustomize
- ✅ Multi-cluster monitoring

---

## 🎓 EXPERT CERTIFIED!

Congratulations! You have completed **59 Stacks** of the Full Stack Bash Course!

### What you've mastered:
1. ✅ **Bash Fundamentals** - From basics to advanced
2. ✅ **System Administration** - Users, networking, security
3. ✅ **DevOps & Cloud** - AWS, Docker, Kubernetes, Terraform
4. ✅ **Automation** - CI/CD, scripting, orchestration
5. ✅ **Expert Skills** - Debugging, security, data structures
6. ✅ **Production Ready** - Multi-cluster, service meshes

### Next Steps:
- Build real-world projects
- Contribute to open source
- Pursue certifications (RHCSA, CKA, AWS)
- Share your knowledge!

---

*End of Stack 59 - Course Complete!* 🎉

---

*End of Stack 59*