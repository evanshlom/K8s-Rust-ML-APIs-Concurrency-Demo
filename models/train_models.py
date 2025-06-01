#!/usr/bin/env python3
"""
Train decision tree models and export to ONNX format.
"""

import os
import numpy as np
from sklearn.datasets import make_regression, make_classification
from sklearn.tree import DecisionTreeRegressor, DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, accuracy_score
import skl2onnx
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType
import onnx
import onnxruntime as ort

def create_output_dir():
    """Create output directory for trained models."""
    os.makedirs("trained", exist_ok=True)

def train_regression_model():
    """Train and export regression model."""
    print("Training regression model...")
    
    # Generate synthetic regression data
    X, y = make_regression(
        n_samples=1000,
        n_features=3,
        noise=0.1,
        random_state=42
    )
    
    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Train decision tree regressor
    model = DecisionTreeRegressor(
        max_depth=10,
        min_samples_split=5,
        min_samples_leaf=2,
        random_state=42
    )
    model.fit(X_train, y_train)
    
    # Evaluate model
    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    print(f"Regression MSE: {mse:.4f}")
    
    # Convert to ONNX
    initial_type = [("float_input", FloatTensorType([None, 3]))]
    onnx_model = convert_sklearn(
        model, 
        initial_types=initial_type,
        target_opset=11
    )
    
    # Save ONNX model
    output_path = "trained/regression_model.onnx"
    with open(output_path, "wb") as f:
        f.write(onnx_model.SerializeToString())
    
    print(f"Regression model saved to {output_path}")
    
    # Verify ONNX model
    verify_onnx_model(output_path, X_test[:5], y_pred[:5], "regression")
    
    return model, X_test, y_test

def train_classification_model():
    """Train and export classification model."""
    print("\nTraining classification model...")
    
    # Generate synthetic classification data
    X, y = make_classification(
        n_samples=1000,
        n_features=4,
        n_informative=3,
        n_redundant=1,
        n_classes=2,
        random_state=42
    )
    
    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Train decision tree classifier
    model = DecisionTreeClassifier(
        max_depth=8,
        min_samples_split=5,
        min_samples_leaf=2,
        random_state=42
    )
    model.fit(X_train, y_train)
    
    # Evaluate model
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Classification Accuracy: {accuracy:.4f}")
    
    # Convert to ONNX
    initial_type = [("float_input", FloatTensorType([None, 4]))]
    onnx_model = convert_sklearn(
        model, 
        initial_types=initial_type,
        target_opset=11
    )
    
    # Save ONNX model
    output_path = "trained/classification_model.onnx"
    with open(output_path, "wb") as f:
        f.write(onnx_model.SerializeToString())
    
    print(f"Classification model saved to {output_path}")
    
    # Verify ONNX model
    verify_onnx_model(output_path, X_test[:5], y_pred[:5], "classification")
    
    return model, X_test, y_test

def verify_onnx_model(model_path, X_sample, y_sample, model_type):
    """Verify ONNX model works correctly."""
    try:
        # Load ONNX model
        session = ort.InferenceSession(model_path)
        
        # Get input name
        input_name = session.get_inputs()[0].name
        
        # Make predictions
        onnx_pred = session.run(None, {input_name: X_sample.astype(np.float32)})
        
        if model_type == "regression":
            onnx_output = onnx_pred[0].flatten()
            print(f"ONNX {model_type} verification successful")
            print(f"Sample predictions: {onnx_output[:3]}")
        else:  # classification
            # ONNX classifier returns both label and probabilities
            onnx_labels = onnx_pred[0].flatten()
            print(f"ONNX {model_type} verification successful")
            print(f"Sample predictions: {onnx_labels[:3]}")
            
    except Exception as e:
        print(f"ONNX {model_type} verification failed: {e}")

def generate_sample_data():
    """Generate and save sample data for testing."""
    print("\nGenerating sample test data...")
    
    # Regression sample
    reg_sample = {
        "features": [1.5, -0.5, 2.0]
    }
    
    # Classification sample
    clf_sample = {
        "features": [0.5, 1.2, -0.8, 1.5]
    }
    
    print("Sample regression input:", reg_sample)
    print("Sample classification input:", clf_sample)
    
    # Test with actual models if they exist
    try:
        # Test regression
        session = ort.InferenceSession("trained/regression_model.onnx")
        input_name = session.get_inputs()[0].name
        reg_pred = session.run(None, {
            input_name: np.array([reg_sample["features"]], dtype=np.float32)
        })
        print(f"Sample regression prediction: {reg_pred[0][0]}")
        
        # Test classification
        session = ort.InferenceSession("trained/classification_model.onnx")
        input_name = session.get_inputs()[0].name
        clf_pred = session.run(None, {
            input_name: np.array([clf_sample["features"]], dtype=np.float32)
        })
        print(f"Sample classification prediction: {clf_pred[0][0]}")
        
    except Exception as e:
        print(f"Could not test samples: {e}")

def main():
    """Main training pipeline."""
    print("Starting model training pipeline...")
    
    # Create output directory
    create_output_dir()
    
    # Train models
    reg_model, reg_X_test, reg_y_test = train_regression_model()
    clf_model, clf_X_test, clf_y_test = train_classification_model()
    
    # Generate sample data
    generate_sample_data()
    
    print("\nModel training complete!")
    print("Models saved in trained/ directory:")
    print("  - regression_model.onnx")
    print("  - classification_model.onnx")

if __name__ == "__main__":
    main()