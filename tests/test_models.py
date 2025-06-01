'''
This file is just for testing the models themselves, not the APIs.
'''

import pytest
import numpy as np
import onnxruntime as ort
import os

class TestModels:
    
    def test_regression_model_exists(self):
        """Test that regression model file exists."""
        model_path = "models/trained/regression_model.onnx"
        assert os.path.exists(model_path), f"Regression model not found at {model_path}"
    
    def test_classification_model_exists(self):
        """Test that classification model file exists."""
        model_path = "models/trained/classification_model.onnx"
        assert os.path.exists(model_path), f"Classification model not found at {model_path}"
    
    def test_regression_model_inference(self):
        """Test regression model inference."""
        model_path = "models/trained/regression_model.onnx"
        if not os.path.exists(model_path):
            pytest.skip("Regression model not found")
        
        session = ort.InferenceSession(model_path)
        
        # Test input
        test_input = np.array([[1.0, 2.0, 3.0]], dtype=np.float32)
        input_name = session.get_inputs()[0].name
        
        # Run inference
        result = session.run(None, {input_name: test_input})
        
        # Validate output
        assert len(result) == 1, "Expected one output"
        assert result[0].shape == (1,), f"Expected shape (1,), got {result[0].shape}"
        assert isinstance(result[0][0], np.float32), "Expected float32 output"
    
    def test_classification_model_inference(self):
        """Test classification model inference."""
        model_path = "models/trained/classification_model.onnx"
        if not os.path.exists(model_path):
            pytest.skip("Classification model not found")
        
        session = ort.InferenceSession(model_path)
        
        # Test input
        test_input = np.array([[1.0, 2.0, 3.0, 4.0]], dtype=np.float32)
        input_name = session.get_inputs()[0].name
        
        # Run inference
        result = session.run(None, {input_name: test_input})
        
        # Validate outputs (label and probabilities)
        assert len(result) == 2, "Expected two outputs (label and probabilities)"
        
        # Check label output
        label = result[0][0]
        assert label in [0, 1], f"Expected binary classification (0 or 1), got {label}"
        
        # Check probability output
        probabilities = result[1][0]
        assert len(probabilities) == 2, "Expected 2 class probabilities"
        assert abs(sum(probabilities) - 1.0) < 0.01, "Probabilities should sum to ~1.0"