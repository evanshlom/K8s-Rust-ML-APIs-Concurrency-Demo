use axum::{
    extract::State,
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing::{info, warn, error};
use ort::{Session, SessionBuilder, Value};
use ndarray::{Array2, Axis};

#[derive(Debug, Deserialize)]
struct PredictionRequest {
    features: Vec<f32>,
}

#[derive(Debug, Serialize)]
struct PredictionResponse {
    prediction: f32,
    model_type: String,
    pod_id: String,
}

#[derive(Debug, Serialize)]
struct HealthResponse {
    status: String,
    model_type: String,
    pod_id: String,
    features_expected: usize,
}

#[derive(Debug, Serialize)]
struct ErrorResponse {
    error: String,
    model_type: String,
}

struct AppState {
    model: Session,
    pod_id: String,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();
    
    info!("Starting Regression API server...");
    
    // Get pod ID from environment or generate one
    let pod_id = std::env::var("HOSTNAME")
        .unwrap_or_else(|_| format!("regression-{}", rand::random::<u32>()));
    
    info!("Pod ID: {}", pod_id);
    
    // Load ONNX model
    let model_path = std::env::var("MODEL_PATH")
        .unwrap_or_else(|_| "model/regression_model.onnx".to_string());
    
    info!("Loading model from: {}", model_path);
    
    let model = match SessionBuilder::new()?.commit_from_file(&model_path) {
        Ok(session) => {
            info!("Model loaded successfully");
            session
        }
        Err(e) => {
            error!("Failed to load model: {}", e);
            return Err(anyhow::anyhow!("Failed to load model: {}", e));
        }
    };
    
    // Create application state
    let state = Arc::new(AppState {
        model,
        pod_id: pod_id.clone(),
    });
    
    // Build router
    let app = Router::new()
        .route("/health", get(health_check))
        .route("/predict", post(predict))
        .route("/", get(root))
        .layer(CorsLayer::permissive())
        .with_state(state);
    
    // Start server
    let port = std::env::var("PORT")
        .unwrap_or_else(|_| "3000".to_string())
        .parse::<u16>()
        .unwrap_or(3000);
    
    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", port)).await?;
    
    info!("Regression API server listening on port {}", port);
    info!("Pod ID: {}", pod_id);
    
    axum::serve(listener, app).await?;
    
    Ok(())
}

async fn root() -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "service": "regression-api",
        "version": "0.1.0",
        "endpoints": {
            "health": "/health",
            "predict": "/predict"
        }
    }))
}

async fn health_check(State(state): State<Arc<AppState>>) -> Json<HealthResponse> {
    Json(HealthResponse {
        status: "healthy".to_string(),
        model_type: "regression".to_string(),
        pod_id: state.pod_id.clone(),
        features_expected: 3,
    })
}

async fn predict(
    State(state): State<Arc<AppState>>,
    Json(request): Json<PredictionRequest>,
) -> Result<Json<PredictionResponse>, (StatusCode, Json<ErrorResponse>)> {
    // Validate input
    if request.features.len() != 3 {
        warn!("Invalid feature count: expected 3, got {}", request.features.len());
        return Err((
            StatusCode::BAD_REQUEST,
            Json(ErrorResponse {
                error: format!("Expected 3 features, got {}", request.features.len()),
                model_type: "regression".to_string(),
            }),
        ));
    }
    
    // Prepare input for ONNX model
    let input_array = Array2::from_shape_vec((1, 3), request.features)
        .map_err(|e| {
            error!("Failed to create input array: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ErrorResponse {
                    error: format!("Failed to process input: {}", e),
                    model_type: "regression".to_string(),
                }),
            )
        })?;
    
    // Convert to ONNX Value
    let input_value = Value::from_array(input_array)
        .map_err(|e| {
            error!("Failed to create ONNX value: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ErrorResponse {
                    error: format!("Failed to prepare model input: {}", e),
                    model_type: "regression".to_string(),
                }),
            )
        })?;
    
    // Run inference
    let outputs = state.model.run(ort::inputs!["float_input" => input_value])
        .map_err(|e| {
            error!("Model inference failed: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ErrorResponse {
                    error: format!("Model inference failed: {}", e),
                    model_type: "regression".to_string(),
                }),
            )
        })?;
    
    // Extract prediction
    let prediction = outputs["variable"]
        .try_extract_tensor::<f32>()
        .map_err(|e| {
            error!("Failed to extract prediction: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ErrorResponse {
                    error: format!("Failed to extract prediction: {}", e),
                    model_type: "regression".to_string(),
                }),
            )
        })?
        .view()
        .index_axis(Axis(0), 0)[0];
    
    info!("Prediction successful: {}", prediction);
    
    Ok(Json(PredictionResponse {
        prediction,
        model_type: "regression".to_string(),
        pod_id: state.pod_id.clone(),
    }))
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_prediction_request_validation() {
        let valid_request = PredictionRequest {
            features: vec![1.0, 2.0, 3.0],
        };
        assert_eq!(valid_request.features.len(), 3);
        
        let invalid_request = PredictionRequest {
            features: vec![1.0, 2.0],
        };
        assert_ne!(invalid_request.features.len(), 3);
    }
}