.PHONY: help train-models build-images setup-cluster deploy test cleanup

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

train-models: ## Train ML models and export to ONNX
	@echo "Training models..."
	cd models && pip install -r requirements.txt && python train_models.py
	@echo "Creating symlinks..."
	ln -sf ../models/trained/regression_model.onnx regression-api/model/regression_model.onnx
	ln -sf ../models/trained/classification_model.onnx classification-api/model/classification_model.onnx

build-images: ## Build Docker images for APIs
	@echo "Building Docker images..."
	./scripts/build-images.sh

setup-cluster: ## Setup KIND cluster
	@echo "Setting up KIND cluster..."
	./scripts/setup.sh

deploy: ## Deploy to Kubernetes
	@echo "Deploying to Kubernetes..."
	./scripts/deploy.sh

test: ## Run concurrent inference tests
	@echo "Running tests..."
	cd scripts && python test-concurrent.py

test-wrk: ## Run wrk load tests on APIs
	@echo "Running wrk load tests..."
	./tests/test_apis.sh

test-unit: ## Run unit tests
	@echo "Running unit tests..."
	cd tests && python -m pytest test_models.py -v
	cd regression-api && cargo test
	cd classification-api && cargo test

logs-regression: ## Show regression API logs
	kubectl logs -n ml-apis -l app=regression-api --tail=50

logs-classification: ## Show classification API logs
	kubectl logs -n ml-apis -l app=classification-api --tail=50

status: ## Check deployment status
	@echo "Namespace status:"
	kubectl get all -n ml-apis
	@echo "\nNode status:"
	kubectl get nodes
	@echo "\nCluster info:"
	kubectl cluster-info --context kind-ml-cluster

cleanup: ## Cleanup KIND cluster and images
	@echo "Cleaning up..."
	./scripts/cleanup.sh

dev-regression: ## Run regression API locally for development
	cd regression-api && cargo run

dev-classification: ## Run classification API locally for development
	cd classification-api && cargo run