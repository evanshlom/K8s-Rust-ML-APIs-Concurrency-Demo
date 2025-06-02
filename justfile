# ML Kubernetes Deployment - Just Commands

### This justfile uses Windows commands (Windows CMD)

# Show available commands
default:
    @just --list

# Train ML models and export to ONNX
train-models:
    @echo "Training models..."
    cd models && pip install -r requirements.txt && python train_models.py

# Build Docker images for APIs
build-images:
    @echo "Building Docker images..."
    ./scripts/build-images.sh

# Setup KIND cluster
setup-cluster:
    @echo "Setting up KIND cluster..."
    ./scripts/setup.sh

# Deploy to Kubernetes
deploy:
    @echo "Deploying to Kubernetes..."
    ./scripts/deploy.sh

# Run wrk load tests using Docker (cross-platform)
test:
    @echo "REGRESSION_MODEL | INFERENCE_ID: 001"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.5, -0.5, 2.0]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 002"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.5, 1.2, -0.8, 1.5]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 003"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [2.1, 0.3, -1.2]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 004"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.8, -1.1, 1.9]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 005"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.3, 1.7, 0.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 006"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.8, 2.1, 0.9, -1.3]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 007"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.3, -0.4, 0.7]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'

# Alternative: Run native wrk if available, fallback to Docker
test-native:
    #!/usr/bin/env sh
    if command -v wrk >/dev/null 2>&1; then
        echo "Using native wrk..."
        ./tests/test_apis.sh
    else
        echo "wrk not found, using Docker fallback..."
        just test
    fi

# Run unit tests
test-unit:
    @echo "Running unit tests..."
    cd tests && python -m pytest test_models.py -v
    cd regression-api && cargo test
    cd classification-api && cargo test

# Show regression API logs
logs-regression:
    kubectl logs -n ml-apis -l app=regression-api --tail=50

# Show classification API logs
logs-classification:
    kubectl logs -n ml-apis -l app=classification-api --tail=50

# Check deployment status
status:
    @echo "Namespace status:"
    kubectl get all -n ml-apis
    @echo "\nNode status:"
    kubectl get nodes
    @echo "\nCluster info:"
    kubectl cluster-info --context kind-ml-cluster

# Cleanup KIND cluster and images
cleanup:
    @echo "Cleaning up..."
    ./scripts/cleanup.sh

# Cleanup Python packages installed for model training
cleanup-python:
    @echo "Uninstalling Python packages..."
    pip uninstall -y numpy scikit-learn onnx onnxruntime skl2onnx

# Complete cleanup (K8s + Python packages)
cleanup-all: cleanup cleanup-python
    @echo "Complete cleanup finished!"

# Run regression API locally for development
dev-regression:
    cd regression-api && cargo run

# Run classification API locally for development
dev-classification:
    cd classification-api && cargo run

# Complete workflow: train, build, deploy, test
all: train-models build-images setup-cluster deploy test

# Quick demo setup (for YouTube video)
demo: train-models build-images setup-cluster deploy
    @echo "\nDemo setup complete!"
    @echo "APIs available at:"
    @echo "  Regression:     http://localhost:30001"
    @echo "  Classification: http://localhost:30002"
    @echo "\nRun 'just test' to start load testing"