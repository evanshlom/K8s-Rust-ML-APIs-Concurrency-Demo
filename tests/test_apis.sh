# tests/test_apis.sh
#!/bin/bash
# API performance and load testing using wrk

set -e

REGRESSION_URL="http://localhost:30001"
CLASSIFICATION_URL="http://localhost:30002"

# Check if wrk is installed
if ! command -v wrk &> /dev/null; then
    echo "wrk is not installed. Please install wrk first:"
    echo "  macOS: brew install wrk"
    echo "  Linux: sudo apt-get install wrk (or build from source)"
    echo "  Windows: Use WSL or build from source"
    exit 1
fi

echo "API Load Testing with wrk"
echo "========================="

# Health check first
echo "Checking API health..."
curl -s "$REGRESSION_URL/health" > /dev/null && echo "Regression API: healthy" || echo "Regression API: failed"
curl -s "$CLASSIFICATION_URL/health" > /dev/null && echo "Classification API: healthy" || echo "Classification API: failed"
echo ""

# Create temp files for POST data
cat > /tmp/regression_payload.json << EOF
{"features": [1.5, -0.5, 2.0]}
EOF

cat > /tmp/classification_payload.json << EOF
{"features": [0.5, 1.2, -0.8, 1.5]}
EOF

# Regression API load test
echo "Testing Regression API (3 pods, 0.1 CPU each)"
echo "----------------------------------------------"
wrk -t4 -c10 -d30s -s tests/wrk_scripts/regression.lua "$REGRESSION_URL/predict"
echo ""

# Classification API load test  
echo "Testing Classification API (1 pod, 0.1 CPU)"
echo "-------------------------------------------"
wrk -t4 -c10 -d30s -s tests/wrk_scripts/classification.lua "$CLASSIFICATION_URL/predict"
echo ""

# Concurrent mixed load test
echo "Mixed Load Test (alternating requests)"
echo "-------------------------------------"
echo "Starting background regression load..."
wrk -t2 -c5 -d60s -s tests/wrk_scripts/regression.lua "$REGRESSION_URL/predict" &
REG_PID=$!

echo "Starting background classification load..."
wrk -t2 -c5 -d60s -s tests/wrk_scripts/classification.lua "$CLASSIFICATION_URL/predict" &
CLF_PID=$!

echo "Running mixed load for 60 seconds..."
wait $REG_PID
wait $CLF_PID

echo "Load testing complete!"

# Cleanup
rm -f /tmp/regression_payload.json /tmp/classification_payload.json