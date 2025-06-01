#!/bin/bash
set -e

echo "Deploying to Kubernetes..."

# Apply Kubernetes manifests
echo "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

echo "Deploying regression API..."
kubectl apply -f k8s/regression-deployment.yaml
kubectl apply -f k8s/regression-service.yaml

echo "Deploying classification API..."
kubectl apply -f k8s/classification-deployment.yaml
kubectl apply -f k8s/classification-service.yaml

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/regression-api -n ml-apis
kubectl wait --for=condition=available --timeout=300s deployment/classification-api -n ml-apis

echo "Deployment complete!"
echo ""
echo "Service endpoints:"
echo "   Regression API:     http://localhost:30001"
echo "   Classification API: http://localhost:30002"
echo ""
echo "Check status with:"
echo "   kubectl get all -n ml-apis"