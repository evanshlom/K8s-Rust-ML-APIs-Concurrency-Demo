#!/bin/bash
# API performance and load testing using wrk via Docker

set -e

# URLs for APIs (using host.docker.internal for Docker on Windows/Mac)
REGRESSION_URL="http://host.docker.internal:30001"
CLASSIFICATION_URL="http://host.docker.internal:30002"

# For Linux, use localhost instead
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    REGRESSION_URL="http://localhost:30001"
    CLASSIFICATION_URL="http://localhost:30002"
fi

echo "API Load Testing with wrk (via Docker)"
echo "======================================"

# Health check using curl in a container
echo "Checking API health..."
docker run --rm curlimages/curl:latest -s "$REGRESSION_URL/health" > /dev/null && echo "Regression API: healthy" || echo "Regression API: failed"
docker run --rm curlimages/curl:latest -s "$CLASSIFICATION_URL/health" > /dev/null && echo "Classification API: healthy" || echo "Classification API: failed"
echo ""

# Get the absolute path to the tests directory
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Regression API load test
echo "Testing Regression API (3 pods, 0.1 CPU each)"
echo "----------------------------------------------"
docker run --rm \
    --add-host=host.docker.internal:host-gateway \
    -v "$TESTS_DIR:/tests" \
    williamyeh/wrk \
    -t4 -c10 -d30s -s /tests/wrk_scripts/regression.lua \
    "$REGRESSION_URL/predict"
echo ""

# Classification API load test
echo "Testing Classification API (1 pod, 0.1 CPU)"
echo "-------------------------------------------"
docker run --rm \
    --add-host=host.docker.internal:host-gateway \
    -v "$TESTS_DIR:/tests" \
    williamyeh/wrk \
    -t4 -c10 -d30s -s /tests/wrk_scripts/classification.lua \
    "$CLASSIFICATION_URL/predict"
echo ""

# Concurrent mixed load test
echo "Mixed Load Test (alternating requests)"
echo "-------------------------------------"
echo "Starting background regression load..."
docker run --rm -d \
    --name wrk-regression \
    --add-host=host.docker.internal:host-gateway \
    -v "$TESTS_DIR:/tests" \
    williamyeh/wrk \
    -t2 -c5 -d60s -s /tests/wrk_scripts/regression.lua \
    "$REGRESSION_URL/predict" &

echo "Starting background classification load..."
docker run --rm -d \
    --name wrk-classification \
    --add-host=host.docker.internal:host-gateway \
    -v "$TESTS_DIR:/tests" \
    williamyeh/wrk \
    -t2 -c5 -d60s -s /tests/wrk_scripts/classification.lua \
    "$CLASSIFICATION_URL/predict" &

echo "Running mixed load for 60 seconds..."
# Wait for both containers to finish
docker wait wrk-regression
docker wait wrk-classification

echo "Load testing complete!"