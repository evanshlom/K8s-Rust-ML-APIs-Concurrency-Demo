# ML Kubernetes Deployment

This project demonstrates a **local Kubernetes setup using KIND** to deploy two ML model APIs simultaneously:

* A decision tree **regression model API** (Axum + ONNX), running across **3 pods**, each limited to **0.1 CPU core**.
* A decision tree binary **classification model API** (Axum + ONNX), running on **1 pod** with **0.1 CPU core**.

Both APIs are exposed using **NodePort** services, making them accessible via **localhost** for testing. A concurrent inference test script sends alternating requests (regression → classification → regression...) to simulate real-world multi-model inference behavior.

## Prerequisites

- Docker Desktop
- KIND (Kubernetes in Docker)
- Python 3.8+
- Rust 1.70+
- kubectl
- just (task runner)

## Quick Start

```bash
# Install just
winget install Casey.Just

# 1. Train the models
just train-models

# 2. Build Docker images
just build-images

# 3. Setup KIND cluster and deploy
just setup-cluster
just deploy

# 4. Test the deployment
just test

# 5. Cleanup
just cleanup
```

## Complete Demo Workflow

```bash
# All-in-one demo setup
just demo

# Then test
just test
```

## Manual Setup

### 1. Train Models

```bash
cd models
pip install -r requirements.txt
python train_models.py
```

### 2. Build Docker Images

```bash
./scripts/build-images.sh
```

### 3. Setup KIND Cluster

```bash
./scripts/setup.sh
```

### 4. Deploy to Kubernetes

```bash
./scripts/deploy.sh
```

### 5. Test the APIs

```bash
# Test concurrent inference
./tests/test_apis.sh

# Or test individually
curl -X POST http://localhost:30001/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [1.0, 2.0, 3.0]}'

curl -X POST http://localhost:30002/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [1.0, 2.0, 3.0, 4.0]}'
```

## Architecture

- **Regression API**: 3 replicas, 0.1 CPU each (Port 30001)
- **Classification API**: 1 replica, 0.1 CPU (Port 30002)
- **Resource Management**: CPU limits enforced by Kubernetes
- **Load Balancing**: Kubernetes service handles distribution across pods

## Development

### Adding New Models

1. Update `models/train_models.py` to train your model
2. Export to ONNX format
3. Create new Rust API service
4. Add Kubernetes manifests
5. Update build and deploy scripts

### Local Development

```bash
# Run regression API locally
just dev-regression

# Run classification API locally  
just dev-classification
```

## Troubleshooting

### Check pod status
```bash
kubectl get pods -n ml-apis
kubectl logs -n ml-apis <pod-name>

# Or use just commands
just logs-regression
just logs-classification
just status
```

### Check services
```bash
kubectl get services -n ml-apis
```

### Access KIND cluster
```bash
kubectl cluster-info --context kind-ml-cluster
```

## Project Structure

- `models/`: Python model training code
- `regression-api/`, `classification-api/`: Rust API services
- `k8s/`: Kubernetes manifests
- `scripts/`: Automation scripts
- `tests/`: Test suites