# 1. Train the models
make train-models

# 2. Build Docker images and setup KIND cluster
make build-images
make setup-cluster

# 3. Deploy to Kubernetes
make deploy

# 4. Test concurrency with wrk
make test-wrk