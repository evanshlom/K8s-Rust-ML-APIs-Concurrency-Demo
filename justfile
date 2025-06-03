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
    @echo "REGRESSION_MODEL | INFERENCE_ID: 00"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.5, -0.5, 2.0]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 01"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [2.1, 0.3, -1.2]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 02"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.5, 1.2, -0.8, 1.5]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 03"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.8, -1.1, 1.9]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 04"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.3, 1.7, 0.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 05"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.8, 2.1, 0.9, -1.3]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 06"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.3, -0.4, 0.7]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 07"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.9, 1.2, -0.8]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 08"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.3, -0.4, 0.7, -2.1]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 09"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-1.1, 0.6, 1.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 10"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.8, -0.9, 0.2]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 11"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.2, 1.8, -1.2, 0.9]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 12"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.5, -0.5, 2.0]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 13"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [2.1, 0.3, -1.2]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 14"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-1.5, 0.3, 2.1, -0.6]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 15"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.8, -1.1, 1.9]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 16"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.3, 1.7, 0.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 17"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.7, -1.9, 0.4, 1.2]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 18"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.3, -0.4, 0.7]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 19"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.9, 1.2, -0.8]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 20"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.5, 1.2, -0.8, 1.5]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 21"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-1.1, 0.6, 1.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 22"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.8, -0.9, 0.2]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 23"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.8, 2.1, 0.9, -1.3]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 24"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.5, -0.5, 2.0]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 25"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [2.1, 0.3, -1.2]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 26"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.3, -0.4, 0.7, -2.1]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 27"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.8, -1.1, 1.9]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 28"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.3, 1.7, 0.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 29"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.2, 1.8, -1.2, 0.9]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 30"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.3, -0.4, 0.7]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 31"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.9, 1.2, -0.8]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 32"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-1.5, 0.3, 2.1, -0.6]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 33"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-1.1, 0.6, 1.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 34"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.8, -0.9, 0.2]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 35"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.7, -1.9, 0.4, 1.2]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 36"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.5, -0.5, 2.0]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 37"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [2.1, 0.3, -1.2]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 38"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.5, 1.2, -0.8, 1.5]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 39"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.8, -1.1, 1.9]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 40"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.3, 1.7, 0.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 41"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-0.8, 2.1, 0.9, -1.3]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 42"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.3, -0.4, 0.7]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 43"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [0.9, 1.2, -0.8]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK_SCORE: \1 | POD: \U\2/'
    @echo ""
    @echo ""
    @echo "CLASSIFICATION_MODEL | INFERENCE_ID: 44"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [1.3, -0.4, 0.7, -2.1]}" http://host.docker.internal:30002/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"classification-api-[^-]*-\([a-z0-9]\).*/RESULT: \1 | POD: \U\2/' | sed 's/RESULT: 0/RESULT: FRAUD_DETECTED/' | sed 's/RESULT: 1/RESULT: TRANSACTION_SAFE/'
    @echo ""
    @echo ""
    @echo "REGRESSION_MODEL | INFERENCE_ID: 45"
    @docker run --rm --add-host=host.docker.internal:host-gateway curlimages/curl:latest -s -X POST -H "Content-Type: application/json" -d "{\"features\": [-1.1, 0.6, 1.4]}" http://host.docker.internal:30001/predict | sed 's/.*"prediction":\([^,]*\).*"pod_id":"regression-api-[^-]*-\([a-z0-9]\).*/RISK

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