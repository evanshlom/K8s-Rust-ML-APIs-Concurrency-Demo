# ML Kubernetes Deployment Project Structure

ml-k8s-deployment/
├── README.md
├── Makefile
├── docker-compose.yml
├── .gitignore
├── models/
│   ├── train_models.py
│   ├── requirements.txt
│   └── trained/
│       ├── regression_model.onnx
│       └── classification_model.onnx
├── regression-api/
│   ├── Cargo.toml
│   ├── src/
│   │   └── main.rs
│   ├── Dockerfile
│   └── model/
│       └── regression_model.onnx (symlink)
├── classification-api/
│   ├── Cargo.toml
│   ├── src/
│   │   └── main.rs
│   ├── Dockerfile
│   └── model/
│       └── classification_model.onnx (symlink)
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── regression-deployment.yaml
│   ├── regression-service.yaml
│   ├── classification-deployment.yaml
│   └── classification-service.yaml
├── scripts/
│   ├── setup.sh
│   ├── build-images.sh
│   ├── deploy.sh
│   ├── test-concurrent.py
│   └── cleanup.sh
└── tests/
    ├── test_models.py
    ├── test_apis.sh
    └── wrk_scripts/
        ├── regression.lua
        ├── classification.lua
        └── mixed_load.lua