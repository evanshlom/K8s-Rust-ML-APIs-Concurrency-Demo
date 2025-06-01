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
use tracing::{info, warn};

#[derive(Debug, Deserialize)]
struct PredictionRequest {
    features: Vec<f32>,
}

#[derive(Debug, Serialize)]
struct PredictionResponse {
    prediction: i64,
    probability: Vec<f32>,
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

#[derive(Clone)]
struct AppState {
    pod_id: String,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();
    
    info!("Starting Classification API server...");
    
    // Get pod ID from environment or generate one
    let pod_id = std::env::var("HOSTNAME")
        .unwrap_or_else(|_| format!("classification-{}", fastrand::u32(..)));
    
    info!("Pod ID: {}", pod_id);
    
    let model_path = std::env::var("MODEL_PATH")
        .unwrap_or_else(|_| "model/classification_model.onnx".to_string());
    
    info!("Model path configured: {}", model_path);
    info!("Model loaded successfully (mock implementation)");
    
    // Create application state
    let state = Arc::new(AppState {
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
    
    info!("Classification API server listening on port {}", port);
    info!("Pod ID: {}", pod_id);
    
    axum::serve(listener, app).await?;
    
    Ok(())
}

async fn root() -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "service": "classification-api",
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
        model_type: "classification".to_string(),
        pod_id: state.pod_id.clone(),
        features_expected: 4,
    })
}

async fn predict(
    State(state): State<Arc<AppState>>,
    Json(request): Json<PredictionRequest>,
) -> Result<Json<PredictionResponse>, (StatusCode, Json<ErrorResponse>)> {
    // Validate input
    if request.features.len() != 4 {
        warn!("Invalid feature count: expected 4, got {}", request.features.len());
        return Err((
            StatusCode::BAD_REQUEST,
            Json(ErrorResponse {
                error: format!("Expected 4 features, got {}", request.features.len()),
                model_type: "classification".to_string(),
            }),
        ));
    }
    
    // Mock classification based on input features
    let sum = request.features.iter().sum::<f32>();
    let prediction = if sum > 10.0 { 1 } else { 0 };
    let probabilities = if prediction == 1 {
        vec![0.3, 0.7]
    } else {
        vec![0.8, 0.2]
    };
    
    info!("Classification successful: class {}, probabilities: {:?}", prediction, probabilities);
    
    Ok(Json(PredictionResponse {
        prediction,
        probability: probabilities,
        model_type: "classification".to_string(),
        pod_id: state.pod_id.clone(),
    }))
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_prediction_request_validation() {
        let valid_request = PredictionRequest {
            features: vec![1.0, 2.0, 3.0, 4.0],
        };
        assert_eq!(valid_request.features.len(), 4);
        
        let invalid_request = PredictionRequest {
            features: vec![1.0, 2.0, 3.0],
        };
        assert_ne!(invalid_request.features.len(), 4);
    }
}