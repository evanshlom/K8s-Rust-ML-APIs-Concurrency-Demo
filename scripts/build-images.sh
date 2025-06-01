#!/bin/bash
set -e

echo "Building Docker images..."

# Build regression API
echo "Building regression-api..."
docker build -f regression-api/Dockerfile -t regression-api:latest .

# Build classification API
echo "Building classification-api..."
docker build -f classification-api/Dockerfile -t classification-api:latest .

# Load images into KIND cluster
echo "Loading images into KIND cluster..."
kind load docker-image regression-api:latest --name ml-cluster
kind load docker-image classification-api:latest --name ml-cluster

echo "Docker images built and loaded!"