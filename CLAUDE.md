# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Metal-AI is a Docker-based AI server infrastructure built around Ollama (inference engine) and OpenWebUI (frontend). It provides a self-hosted platform for deploying and managing multiple LLMs with dual RTX 3090 GPU acceleration.

## Deployment Commands

All services are managed via Docker Compose. Each service has its own directory with deployment scripts.

```bash
# Deploy/update Ollama (backend inference engine)
sh ./ollama/execute-update.sh

# Deploy/update OpenWebUI (frontend interface)
sh ./open-webui/execute-update.sh

# Deploy/update Portainer (container management)
sh ./portainer/execute-update.sh

# Update all installed Ollama models to latest versions
./ollama-update-models.sh
```

### Model Management

```bash
# Enter Ollama container to manage models
docker exec -it ollama bash

# Inside container:
ollama pull mistral:7b          # Pull a model
ollama list                     # List installed models
ollama create <name> -f <file>  # Create custom model from Modelfile

# Unload a model from GPU memory (from host)
curl http://localhost:11434/api/generate -d '{"model": "<model-name>", "keep_alive": 0}'
```

## Architecture

```
┌──────────────────────────────────────────────────┐
│              OpenWebUI (Port 8080)               │
│              React frontend                      │
└─────────────────────┬────────────────────────────┘
                      │ REST API
┌─────────────────────▼────────────────────────────┐
│              Ollama (Port 11434)                 │
│   GPU-accelerated inference (2x RTX 3090)       │
│   Config: 4 parallel requests, 2 models loaded  │
└─────────────────────┬────────────────────────────┘
                      │
              ┌───────┴───────┐
              │ Model Storage │
              │/data/ollama_* │
              └───────────────┘
```

**Key Services:**
- **ollama/** - Inference engine with multi-GPU support and Flash Attention
- **open-webui/** - Web interface for interacting with models
- **portainer/** - Container management dashboard (Port 9000)

## Custom Models (modelos/)

Custom model definitions using Ollama Modelfiles with embedded system prompts:

- **dis-assistant-coder** - QWen3-Coder:30b optimized for agentic coding tools (Goose, Aider)
- **dis-assistant-granite** - IBM Granite 3.3-8b as executive assistant (Portuguese)
- **dis-assistant-mistral** - Mistral Small for brainstorming/ideation (Portuguese)

Each model directory contains:
- `Modelfile-dis-assistant-*` - Model definition with parameters and system prompt
- `create-model.sh` - Script to build the custom model

## Configuration

Key environment variables in ollama/docker-compose.yml:
- `OLLAMA_NUM_PARALLEL=4` - Parallel request limit
- `OLLAMA_MAX_LOADED_MODELS=2` - Models kept in VRAM
- `OLLAMA_FLASH_ATTENTION=1` - Performance optimization
- `CUDA_VISIBLE_DEVICES=0,1` - Both GPUs enabled
- `OLLAMA_KEEP_ALIVE=24h` - Model unload timeout

## Prerequisites

This infrastructure requires:
- Proxmox VM with GPU passthrough (2x RTX 3090)
- NVIDIA drivers (570-server tested)
- CUDA toolkit and NVIDIA Container Toolkit
- Docker with nvidia runtime
