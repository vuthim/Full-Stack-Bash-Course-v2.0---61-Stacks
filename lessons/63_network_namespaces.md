# 🌐 STACK 63: NETWORK NAMESPACES
## Linux Network Virtualization

**What are Network Namespaces?** Think of them as "parallel network universes" on the same computer. Each namespace has its own separate network stack - interfaces, routes, firewall rules, and ports. It's like having multiple virtual routers inside one machine!

**Why This Matters?** Network namespaces are the foundation of container networking. Docker, Kubernetes, and VPNs all use them. Understanding them gives you superpowers for troubleshooting containerized environments!

---

## 🔰 What are Network Namespaces?

Network namespaces provide **network isolation** - each namespace has its own:
- ✅ **Network interfaces** - Separate virtual ethernet adapters
- ✅ **Routing tables** - Independent routing decisions
- ✅ **iptables rules** - Per-namespace firewalls
- ✅ **Port numbers** - Same port can be used in different namespaces (no conflict!)

### Network Namespace Analogy
```
Without namespaces:  One house, one phone line, everyone shares
With namespaces:    One house, multiple private phone lines, no cross-talk

Each namespace = its own isolated network world
```

### Used By (Real-World Applications)
| Technology | How It Uses Namespaces |
|-----------|----------------------|
| **Docker** | Each container gets its own network namespace |
| **Kubernetes** | Pod networking relies on namespaces |
| **VPNs** | Split tunneling (some traffic through VPN, some direct) |
| **Network testing** | Simulate complex topologies on one machine |

---

## 📋 Basic Commands

### List Namespaces
```bash
# List all namespaces
ip netns list

# Add namespace
ip netns add mynamespace

# Delete namespace
ip netns delete mynamespace

# Execute command in namespace
ip netns exec mynamespace ip addr
```

### Network Interface in Namespace
```bash
# Add interface to namespace
ip link add veth0 type veth peer name veth1
ip link set veth1 netns mynamespace

# Configure in namespace
ip netns exec mynamespace ip addr add 10.0.0.2/24 dev veth1
ip netns exec mynamespace ip link set veth1 up

# Configure in host
ip addr add 10.0.0.1/24 dev veth0
ip link set veth0 up
```

---

## 🏠 Create Isolated Network

### Script: Basic Network Namespace
```bash
#!/bin/bash
# create_isolated_network.sh

set -euo pipefail

NS_NAME="${1:-testns}"
VETH_HOST="veth-${NS_NAME}"
VETH_NS="veth0"
IP_HOST="10.0.1.1/24"
IP_NS="10.0.1.2/24"

# Create namespace
ip netns add "$NS_NAME" 2>/dev/null || true

# Create veth pair
ip link add "$VETH_HOST" type veth peer name "$VETH_NS"

# Move to namespace
ip link set "$VETH_NS" netns "$NS_NAME"

# Configure host side
ip addr add "$IP_HOST" dev "$VETH_HOST"
ip link set "$VETH_HOST" up

# Configure namespace side
ip netns exec "$NS_NAME" ip addr add "$IP_NS" dev "$VETH_NS"
ip netns exec "$NS_NAME" ip link set "$VETH_NS" up
ip netns exec "$NS_NAME" ip link set lo up

# Add default route in namespace
ip netns exec "$NS_NAME" ip route add default via "${IP_HOST%/*}"

echo "Network created: $NS_NAME"
echo "Host IP: $IP_HOST"
echo "Namespace IP: $IP_NS"

# Test connectivity
ip netns exec "$NS_NAME" ping -c 3 "${IP_HOST%/*}"
```

---

## 🔗 Connect Namespace to Internet

### Via NAT (NAT Gateway)
```bash
#!/bin/bash
# connect_namespace_to_internet.sh

NS_NAME="${1:-testns}"
VETH_HOST="veth-${NS_NAME}"

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# NAT rules
iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -j MASQUERADE
iptables -A FORWARD -i "$VETH_HOST" -j ACCEPT
iptables -A FORWARD -o "$VETH_HOST" -j ACCEPT

# Test from namespace
ip netns exec "$NS_NAME" ping -c 3 8.8.8.8
ip netns exec "$NS_NAME" curl -s https://example.com
```

---

## 📡 Multiple Namespaces

### Create Router Topology
```bash
#!/bin/bash
# create_router_topology.sh

# Create namespaces
ip netns add router
ip netns add host1
ip netns add host2

# Host1 <-> Router
ip link add veth-h1r type veth peer name veth-rh1
ip link set veth-h1r netns host1
ip link set veth-rh1 netns router

# Host2 <-> Router
ip link add veth-h2r type veth peer name veth-rh2
ip link set veth-h2r netns host2
ip link set veth-rh2 netns router

# Configure Host1
ip netns exec host1 ip addr add 10.0.1.2/24 dev veth-h1r
ip netns exec host1 ip link set veth-h1r up
ip netns exec host1 ip route add default via 10.0.1.1

# Configure Host2
ip netns exec host2 ip addr add 10.0.2.2/24 dev veth-h2r
ip netns exec host2 ip link set veth-h2r up
ip netns exec host2 ip route add default via 10.0.2.1

# Configure Router
ip netns exec router ip addr add 10.0.1.1/24 dev veth-rh1
ip netns exec router ip addr add 10.0.2.1/24 dev veth-rh2
ip netns exec router ip link set veth-rh1 up
ip netns exec router ip link set veth-rh2 up

# Enable forwarding in router
ip netns exec router sysctl -w net.ipv4.ip_forward=1

echo "Topology created!"
echo "Host1: 10.0.1.2, Gateway: 10.0.1.1"
echo "Host2: 10.0.2.2, Gateway: 10.0.2.1"
```

---

## 🐳 Docker-Style Isolation

### Simple Container Network
```bash
#!/bin/bash
# container_network.sh

CONTAINER="${1:-container1}"
IP="172.17.0.2/16"

# Create namespace
ip netns add "$CONTAINER"

# Create veth pair
ip link add veth0 type veth peer name veth1
ip link set veth1 netns "$CONTAINER"

# Create bridge (if not exists)
ip link add docker0 type bridge 2>/dev/null || true
ip link set docker0 up

# Connect to bridge
ip link set veth0 master docker0
ip link set veth0 up

# Configure container
ip netns exec "$CONTAINER" ip addr add "$IP" dev veth1
ip netns exec "$CONTAINER" ip link set veth1 up
ip netns exec "$CONTAINER" ip link set lo up

# NAT for internet
iptables -t nat -A POSTROUTING -s "$IP" -j MASQUERADE 2>/dev/null || true

echo "Container network ready: $CONTAINER at $IP"
```

---

## 🔍 Troubleshooting

### Check Namespace State
```bash
# List namespaces
ip netns list

# Show interfaces in namespace
ip netns exec $NS ip link show

# Show addresses
ip netns exec $NS ip addr show

# Show routes
ip netns exec $NS ip route show

# Show ARP table
ip netns exec $NS ip neigh show

# Test connectivity
ip netns exec $NS ping 8.8.8.8

# Show processes in namespace
ip netns exec $NS ps aux
```

### Common Issues
```bash
# Interface not found
# → Check interface is in correct namespace

# No route to host
# → Check routing table in namespace

# Can't reach internet
# → Check NAT/forwarding rules
# → Check /proc/sys/net/ipv4/ip_forward = 1

# Ping fails
# → Check both ends are UP
# → Check IP addresses are in same subnet
```

---

## 🧹 Cleanup

```bash
# Delete all namespaces
for ns in $(ip netns list | awk '{print $1}'); do
    ip netns delete "$ns" 2>/dev/null
done

# Delete all veth pairs
ip -all link delete

# Clear iptables rules
iptables -t nat -F
iptables -F FORWARD
```

---

## 📝 Use Cases

| Use Case | Benefit |
|----------|---------|
| Container networking | Docker/K8s use this |
| VPN isolation | Separate network stack |
| Testing | Safe network experiments |
| Network debugging | Isolate issues |
| Multi-tenant | Network isolation |

---

## 🎓 Final Project: The Network Virtualization Manager

Now that you've mastered the building blocks of network isolation, let's see how a professional Cloud Engineer might automate the creation of virtual environments. We'll examine the "Network Virtualizer" — a script that automates the creation of namespaces, virtual ethernet pairs (veth), and bridge networks to simulate a mini-datacenter on your machine.

### What the Network Virtualization Manager Does:
1. **Automates Namespace Creation** including the setup of the loopback interface (`lo`).
2. **Creates Virtual Ethernet Tunnels** (veth pairs) to connect the host to the guest namespace.
3. **Manages Bridge Networking** allowing multiple namespaces to talk to each other on a single subnet.
4. **Enables Internet Access (NAT)** by configuring IP forwarding and Iptables masquerading automatically.
5. **Performs Connectivity Audits** by pinging between environments to ensure the "pipes" are working.
6. **Cleans Up Virtual Resources** by removing namespaces and links when they are no longer needed.

### Key Snippet: Connecting the Worlds (veth)
The most important part of virtualization is the "tunnel" between the host and the namespace. The manager automates this multi-step process.

```bash
# Create the two ends of our virtual cable
ip link add veth-host type veth peer name veth-guest

# Hand one end of the cable to the guest namespace
ip link set veth-guest netns "my-virtual-env"

# Configure the host end of the cable
ip addr add 10.0.0.1/24 dev veth-host
ip link set veth-host up

# Configure the guest end inside its own universe
ip netns exec "my-virtual-env" ip addr add 10.0.0.2/24 dev veth-guest
ip netns exec "my-virtual-env" ip link set veth-guest up
```

### Key Snippet: Enabling Internet via NAT
To let your virtual universe talk to the real internet, the manager applies a "Masquerade" rule to your host's firewall.

```bash
# 1. Enable forwarding in the Linux kernel
echo 1 > /proc/sys/net/ipv4/ip_forward

# 2. Tell the firewall to hide the virtual IP behind your real IP
# -t nat: Use the Network Address Translation table
# -A POSTROUTING: Apply the rule AFTER routing happens
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
```

**Pro Tip:** Understanding this script is the "Aha!" moment for learning how Docker and Kubernetes work. It's not magic—it's just namespaces and veth pairs!

---

## ✅ Stack 63 Complete!

Congratulations! You've successfully learned how to build "networks within networks"! You can now:
- ✅ **Isolate network traffic** using Linux Network Namespaces
- ✅ **Connect environments** using Virtual Ethernet (veth) pairs
- ✅ **Build virtual routers** and complex network topologies
- ✅ **Enable internet access** for isolated environments using NAT
- ✅ **Troubleshoot container networking** like a professional DevOps engineer
- ✅ **Simulate datacenter architectures** on a single laptop

### What's Next?
In the next stack, we'll dive into **Log Aggregation**. You'll learn how to collect logs from thousands of sources and search them all from a single dashboard using tools like ELK and Loki!

**Next: Stack 64 - Log Aggregation →**

---

*End of Stack 63*
