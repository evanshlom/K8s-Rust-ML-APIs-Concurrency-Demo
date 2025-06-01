FROM rust:1.87 AS builder

WORKDIR /app
COPY classification-api/Cargo.toml ./
COPY classification-api/src ./src
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/classification-api /app/
RUN mkdir -p model
COPY models/trained/classification_model.onnx ./model/classification_model.onnx

EXPOSE 3000
CMD ["./classification-api"]