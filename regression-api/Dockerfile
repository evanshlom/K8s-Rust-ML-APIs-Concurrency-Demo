FROM rust:1.87 AS builder

WORKDIR /app
COPY regression-api/Cargo.toml ./
COPY regression-api/src ./src
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/regression-api /app/
RUN mkdir -p model
COPY models/trained/regression_model.onnx ./model/regression_model.onnx

EXPOSE 3000
CMD ["./regression-api"]