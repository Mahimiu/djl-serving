# syntax=docker/dockerfile:1.6

# ============================================================
# Stage 1: Model Preparation
# Kleines Alpine-Image nur zum Entpacken - unzip-Tool bleibt
# in dieser Stage, finales Image bleibt sauber
# ============================================================
FROM alpine:3 AS model-prep

WORKDIR /model-prep

RUN apk add --no-cache unzip

COPY traced_resnet18.zip .
RUN unzip traced_resnet18.zip -d traced_resnet18 && \
    rm traced_resnet18.zip

# ============================================================
# Stage 2: Runtime - offizielles DJL-Serving mit Modell drin
# ============================================================
FROM deepjavalibrary/djl-serving:0.36.0

# OCI Image-Metadaten
LABEL org.opencontainers.image.title="DJL Serving - Footwear Classification"
LABEL org.opencontainers.image.description="DJL Serving with pre-built ResNet18 footwear classifier"
LABEL org.opencontainers.image.source="https://github.com/Mahimiu/djl-serving"

# Nur das entpackte Modell aus Prep-Stage - keine ZIPs, kein unzip-Tool
COPY --from=model-prep /model-prep/traced_resnet18 /opt/ml/model/traced_resnet18