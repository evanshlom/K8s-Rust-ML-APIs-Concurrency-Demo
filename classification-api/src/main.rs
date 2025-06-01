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

struct AppState {
    model: Session,
    pod_id: String,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();
    
    info!("Starting Classification API server...");
    
    // Get pod ID from environment or generate one
    let pod_id = std::env::var("HOSTNAME")
        .unwrap_or_else(|_| format!("classification-{}", rand::random::<u32>()));
    
    info!("Pod ID: {}", pod_id);
    
    // Load ONNX model
    let model_path = std::env::var("MODEL_PATH")
        .unwrap_or_else(|_| "model/classification_model.onnx".to_string());
    
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