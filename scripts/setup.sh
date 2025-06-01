#!/bin/bash
# scripts/setup.sh
set -e

echo "Setting up KIND cluster for ML deployment..."

# Check if KIND is installed
if ! command -v kind &> /dev/null; then
    echo "KIND is not installed. Please install KIND first."
    echo "   Visit: https://kind.sigs.k8s.io/docs/user/quick-start/"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Create KIND cluster
echo "Creating KIND cluster: ml-cluster"
cat <<EOF | kind create cluster --name ml-cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30001
    hostPort: 30001
    protocol: TCP
  - containerPort: 30002
    hostPort: 30002
    protocol: TCP
EOF

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "KIND cluster setup complete!"
echo "   Cluster name: ml-cluster"
echo "   Context: kind-ml-cluster"