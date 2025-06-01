#!/bin/bash
# scripts/build-images.sh
set -e

echo "Building Docker images..."

# Build regression API
echo "Building regression-api..."
cd regression-api
docker build -t regression-api:latest .
cd ..

# Build classification API
echo "Building classification-api..."
cd classification-api
docker build -t classification-api:latest .
cd ..

# Load images into KIND cluster
echo "Loading images into KIND cluster..."
kind load docker-image regression-api:latest --name ml-cluster
kind load docker-image classification-api:latest --name ml-cluster

echo "Docker images built and loaded!"