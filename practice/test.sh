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
