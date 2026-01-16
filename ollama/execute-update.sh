#!/bin/bash

# Create volumes
mkdir -p /data/ollama_data
chown -R 1000:1000 /data/ollama_data
chown -R 0:0 /data/ollama_data
mkdir -p /data/ollama_models
chown -R 1000:1000 /data/ollama_models
chown -R 0:0 /data/ollama_models

# Update and deploy container
docker compose pull
docker compose down
docker compose up -d