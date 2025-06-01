#!/bin/bash
# scripts/cleanup.sh
set -e

echo "Cleaning up..."

# Delete KIND cluster
if kind get clusters | grep -q "ml-cluster"; then
    echo "Deleting KIND cluster..."
    kind delete cluster --name ml-cluster
    echo "KIND cluster deleted!"
else
    echo "No ml-cluster found"
fi

# Remove Docker images (optional)
read -p "Remove Docker images? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing Docker images..."
    docker rmi regression-api:latest 2>/dev/null || true
    docker rmi classification-api:latest 2>/dev/null || true
    echo "Docker images removed!"
fi

echo "Cleanup complete!"