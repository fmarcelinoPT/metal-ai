# Metal-AI: Self-Hosted AI Server

A Docker-based AI server infrastructure built with Ollama and OpenWebUI, leveraging dual RTX 3090 GPUs for high-performance LLM inference.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Hardware Requirements](#hardware-requirements)
- [Prerequisites](#prerequisites)
  - [1. Proxmox GPU Passthrough](#1-proxmox-gpu-passthrough)
  - [2. VM Setup](#2-vm-setup)
  - [3. NVIDIA Drivers](#3-nvidia-drivers)
  - [4. CUDA Toolkit](#4-cuda-toolkit)
  - [5. NVIDIA Container Toolkit](#5-nvidia-container-toolkit)
  - [6. Docker Engine](#6-docker-engine)
  - [7. Storage Setup](#7-storage-setup)
- [Deployment](#deployment)
  - [Clone Repository](#clone-repository)
  - [Deploy Services](#deploy-services)
  - [Install Models](#install-models)
- [Configuration](#configuration)
  - [Ollama Settings](#ollama-settings)
  - [OpenWebUI Settings](#openwebui-settings)
- [Custom Models](#custom-models)
  - [dis-assistant-cos](#dis-assistant-cos)
  - [dis-assistant-coder](#dis-assistant-coder)
  - [dis-assistant-granite](#dis-assistant-granite)
  - [dis-assistant-magistral](#dis-assistant-magistral)
  - [Creating Custom Models](#creating-custom-models)
- [Model Management](#model-management)
  - [Installing Models](#installing-models)
  - [Updating Models](#updating-models)
  - [Unloading Models from Memory](#unloading-models-from-memory)
  - [Pulling from Hugging Face](#pulling-from-hugging-face)
- [Services Reference](#services-reference)
- [OpenCode CLI](#opencode-cli)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Agents](#agents)
  - [Agent Prompts](#agent-prompts)
  - [Usage](#usage)
  - [Server Configuration](#server-configuration)
- [Cheat Sheet](#cheat-sheet)
- [Troubleshooting](#troubleshooting)

---

## Overview

Metal-AI provides a self-hosted platform for deploying and managing multiple Large Language Models (LLMs) with GPU acceleration. The stack consists of:

- **Ollama**: Backend inference engine with multi-GPU support
- **OpenWebUI**: Feature-rich web interface for interacting with models
- **Portainer**: Container management dashboard

## Architecture

```plain
┌─────────────────────────────────────────────────────────────┐
│                    OpenWebUI (Port 8080)                    │
│                    React-based Frontend                     │
│        File uploads: txt, md, pdf, csv, json, xlsx, docx    │
└──────────────────────────┬──────────────────────────────────┘
                           │ REST API (localhost:11434)
┌──────────────────────────▼──────────────────────────────────┐
│                    Ollama (Port 11434)                      │
│              GPU-Accelerated Inference Engine               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Configuration:                                     │    │
│  │  • 4 parallel requests (OLLAMA_NUM_PARALLEL)        │    │
│  │  • 2 models loaded in VRAM (OLLAMA_MAX_LOADED)      │    │
│  │  • Flash Attention enabled                          │    │
│  │  • 12h keep-alive timeout                           │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌───────────────┐              ┌───────────────┐           │
│  │   RTX 3090    │              │   RTX 3090    │           │
│  │    (24GB)     │              │    (24GB)     │           │
│  │   GPU 0       │              │   GPU 1       │           │
│  └───────────────┘              └───────────────┘           │
└──────────────────────────┬──────────────────────────────────┘
                           │
              ┌────────────┴────────────┐
              │     Model Storage       │
              │   /data/ollama_data     │
              │   /data/ollama_models   │
              └─────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│               Portainer (Ports 9000, 9443)                  │
│               Container Management Dashboard                │
└─────────────────────────────────────────────────────────────┘
```

## Hardware Requirements

| Component | Minimum                   | Recommended                        |
|-----------|---------------------------|------------------------------------|
| GPU       | 1x NVIDIA GPU (8GB+ VRAM) | 2x RTX 3090 (48GB total VRAM)      |
| RAM       | 32GB                      | 64GB+                              |
| Storage   | 100GB SSD                 | 500GB+ NVMe (dedicated for models) |
| CPU       | 8 cores                   | 16+ cores                          |

## Prerequisites

### 1. Proxmox GPU Passthrough

Configure GPU passthrough on your Proxmox host:

**Resources:**

- [GPU Passthrough Step-by-Step Tutorial (Video)](https://www.youtube.com/watch?v=IE0ew8WwxLM)
- [GPU Access from VM on Proxmox (Ubuntu)](https://medium.com/@cactusmccoy/gpu-access-from-a-virtual-machine-on-proxmox-server-ubuntu-vm-903bb9783cb3)

### 2. VM Setup

Create a new VM in Proxmox:

- **OS**: Ubuntu 22.04/24.04 LTS recommended
- **RAM**: 32GB minimum
- **Disk**: 50GB for OS, additional disk for models
- **CPU**: Assign adequate cores (8+)
- **PCI Passthrough**: Add GPU device(s)

### 3. NVIDIA Drivers

Install NVIDIA drivers on the VM:

```bash
# Install driver utilities
sudo apt update
sudo apt install ubuntu-drivers-common -y

# List available GPU drivers
sudo ubuntu-drivers list --gpgpu

# Install NVIDIA server driver (adjust version as needed)
sudo ubuntu-drivers install --gpgpu nvidia:570-server

# Install additional utilities
sudo apt install nvidia-utils-570-server
sudo apt install nvidia-fabricmanager-570 libnvidia-nscq-570

# Reboot to apply
sudo reboot
```

**Reference:** [Ubuntu NVIDIA Driver Installation Guide](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/index.html)

### 4. CUDA Toolkit

Install CUDA drivers:

```bash
# Add NVIDIA CUDA repository
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

# Install CUDA drivers
sudo apt update
sudo apt install cuda-drivers -y

# Reboot
sudo reboot
```

**Verify GPU access:**

```bash
nvidia-smi
# Or watch continuously:
watch -n1 nvidia-smi
```

**Reference:** [NVIDIA CUDA Driver Installation Guide](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html#ubuntu-installation)

### 5. NVIDIA Container Toolkit

Install the container toolkit to enable GPU access in Docker:

```bash
# Follow official installation guide
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
```

**Test GPU access in Docker:**

```bash
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

**Troubleshooting NVML errors:**

```bash
# If you see "Failed to initialize NVML: Unknown Error"
sudo nano /etc/nvidia-container-runtime/config.toml
# Set: no-cgroups = false
sudo systemctl restart docker
```

### 6. Docker Engine

Install Docker:

```bash
# Follow official guide:
# https://docs.docker.com/engine/install/ubuntu/
```

**Post-installation (run Docker without sudo):**

```bash
# https://docs.docker.com/engine/install/linux-postinstall/
sudo usermod -aG docker $USER
newgrp docker
```

### 7. Storage Setup

Create a dedicated storage location for models (recommended: separate disk):

```bash
# Mount a dedicated disk to /data (adjust device as needed)
sudo mkdir -p /data
sudo mount /dev/sdb1 /data

# Add to /etc/fstab for persistence
echo '/dev/sdb1 /data ext4 defaults 0 2' | sudo tee -a /etc/fstab
```

---

## Deployment

### Clone Repository

```bash
git clone https://github.com/fmarcelino/metal-ai.git
cd metal-ai
```

### Deploy Services

Deploy services in this order:

```bash
# 1. Deploy Portainer (container management)
sh ./portainer/execute-update.sh

# 2. Deploy Ollama (inference engine)
sh ./ollama/execute-update.sh

# 3. Deploy OpenWebUI (frontend)
sh ./open-webui/execute-update.sh
```

### Install Models

Enter the Ollama container and pull models:

```bash
docker exec -it ollama bash
```

**Recommended models:**

```bash
# General Purpose (Stable & Fast)
ollama pull mistral:7b
ollama pull llama3.1:8b
ollama pull phi:2.7b
ollama pull deepseek-r1:8b

# Personal/Business Management
ollama pull granite3.2:8b

# Coding
ollama pull granite-code:8b
ollama pull codegemma:7b
ollama pull starcoder2:7b
```

**Access the web interface:**

```plain
http://<server-ip>:8080
```

---

## Configuration

### Ollama Settings

Located in `ollama/docker-compose.yml`:

| Variable                   | Value | Description                               |
|----------------------------|-------|-------------------------------------------|
| `OLLAMA_NUM_PARALLEL`      | 4     | Number of parallel inference requests     |
| `OLLAMA_MAX_LOADED_MODELS` | 2     | Models kept loaded in VRAM                |
| `OLLAMA_FLASH_ATTENTION`   | 1     | Enable Flash Attention (faster inference) |
| `CUDA_VISIBLE_DEVICES`     | 0,1   | GPUs available for inference              |
| `OLLAMA_KEEP_ALIVE`        | 12h   | Time before unloading idle models         |

**Volume Mounts:**

- `/data/ollama_data` → Model configuration and state
- `/data/ollama_models` → Model weights storage

### OpenWebUI Settings

Located in `open-webui/docker-compose.yml`:

| Variable                    | Value                                            | Description          |
|-----------------------------|--------------------------------------------------|----------------------|
| `OLLAMA_BASE_URL`           | `http://127.0.0.1:11434`                         | Ollama API endpoint  |
| `UPLOAD_ALLOWED_EXTENSIONS` | `txt,md,pdf,csv,json,xls,xlsx,doc,docx,ppt,pptx` | Allowed file uploads |

---

## Custom Models

Custom models are defined in the `models/` directory using Ollama Modelfiles.

### dis-assistant-cos

**Base:** `qwen3:8b` (~5GB)

Lightweight orchestrator agent (Chief of Staff) optimized for routing, file operations, and task delegation.

**Features:**

- 40K context window
- Excellent tool calling support
- Routes complex tasks to specialized subagents
- File manipulation (read/write/edit)
- Portuguese (Portugal) language optimization

**Create:**

```bash
cd models/dis-assistant-cos
ollama create dis-assistant-cos -f Modelfile-dis-assistant-cos
```

### dis-assistant-coder

**Base:** `qwen3-coder:30b` (18GB)

An agentic coding assistant optimized for tools like Goose, Aider, and similar coding agents.

**Features:**

- 32K context window for large codebases
- Low temperature (0.2) for deterministic code generation
- Tool-calling optimized system prompt
- Action-oriented workflow (plan → execute → verify)

**Create:**

```bash
cd models/dis-assistant-coder
ollama create dis-assistant-coder -f Modelfile-dis-assistant-coder
```

### dis-assistant-granite

**Base:** `ibm-granite/granite-3.3-8b-instruct`

Executive assistant optimized for business management tasks.

**Features:**

- 32K context window
- Thinking mode enabled
- Portuguese (Portugal) language optimization
- Three operational perspectives: Executive, Architect, Product Manager

**Create:**

```bash
cd models/dis-assistant-granite
ollama create dis-assistant-granite -f Modelfile-dis-assistant-granite
```

### dis-assistant-magistral

**Base:** `Magistral-Small-2509` (Mistral reasoning model)

Strategic assistant for brainstorming and ideation.

**Features:**

- 40K context window
- Low temperature (0.3) for consistent responses
- Frequency/presence penalties for diverse outputs
- Multi-perspective business analysis

**Create:**

```bash
cd models/dis-assistant-magistral
ollama create dis-assistant-magistral -f Modelfile-dis-assistant-magistral
```

### Creating Custom Models

1. Create a directory under `models/`
2. Create a `Modelfile-<name>` with your configuration
3. Create a `create-model.sh` script:

```bash
#!/bin/bash
ollama create <model-name> -f Modelfile-<model-name>
```

1. Run inside the Ollama container:

```bash
docker exec -it ollama bash
cd /path/to/modelfile
./create-model.sh
```

---

## Model Management

### Installing Models

```bash
# Enter container
docker exec -it ollama bash

# Pull official models
ollama pull <model-name>

# List installed models
ollama list

# Show model details
ollama show <model-name>

# Remove a model
ollama rm <model-name>
```

### Updating Models

Update all installed models to their latest versions:

```bash
# From host (using the helper script)
./ollama-update-models.sh

# Or manually inside container
docker exec -it ollama bash
ollama list | awk 'NR>1 {print $1}' | xargs -I {} ollama pull {}
```

### Unloading Models from Memory

Free GPU memory by unloading specific models:

```bash
# Replace <model-name> with the actual model name
curl http://localhost:11434/api/generate -d '{"model": "<model-name>", "keep_alive": 0}'

# Examples:
curl http://localhost:11434/api/generate -d '{"model": "mistral:7b", "keep_alive": 0}'
curl http://localhost:11434/api/generate -d '{"model": "llama3.1:8b", "keep_alive": 0}'
```

### Pulling from Hugging Face

Ollama can pull GGUF models directly from Hugging Face:

```bash
# Syntax: ollama pull hf.co/<organization>/<model>
ollama pull hf.co/microsoft/phi-4
ollama pull hf.co/ibm-granite/granite-3.3-8b-instruct-GGUF
ollama pull hf.co/unsloth/Llama-3.3-70B-Instruct-GGUF
```

**Reference:** [Hugging Face Ollama Integration](https://huggingface.co/docs/hub/en/ollama)

---

## Services Reference

| Service           | Port  | URL                     | Purpose                     |
|-------------------|-------|-------------------------|-----------------------------|
| OpenWebUI         | 8080  | `http://<server>:8080`  | Web interface for chat      |
| Ollama API        | 11434 | `http://<server>:11434` | REST API for inference      |
| Portainer         | 9000  | `http://<server>:9000`  | Container management        |
| Portainer (HTTPS) | 9443  | `https://<server>:9443` | Secure container management |

**Service Management:**

```bash
# Update/restart a service
cd <service-directory>
sh ./execute-update.sh

# View logs
docker logs -f ollama
docker logs -f open-webui

# Check status
docker ps
```

---

## OpenCode CLI

[OpenCode](https://opencode.ai) is an agentic coding CLI that can connect to your local Ollama server for AI-assisted development.

### Installation

```bash
# Install via npm (requires Node.js 18+)
npm install -g opencode

# Or install via Homebrew (macOS/Linux)
brew install opencode

# Verify installation
opencode --version
```

### Configuration

Copy the default configuration file to set up OpenCode with your Metal-AI server:

```bash
# Copy the default configuration
cp opencode.json.default opencode.json

# Edit to customize (optional)
nano opencode.json
```

The configuration file (`opencode.json`) defines:

- **Provider settings**: Connection to your Ollama server
- **Model definitions**: Available models with their capabilities
- **Agent configurations**: Specialized agents for different tasks

### Agents

Four pre-configured agents are available with a hierarchical architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                   PRIMARY AGENT: cos                        │
│                                                             │
│  Model: dis-assistant-cos (Qwen3:8b, ~5GB)                 │
│  Role: Lightweight orchestrator with tool calling          │
│  Tools: read, write, edit, glob, grep, bash                │
└─────────────────────┬───────────────────────────────────────┘
                      │ delegates via @mention
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│   @magistral  │ │    @coder     │ │   @granite    │
│   (Subagent)  │ │   (Subagent)  │ │  (Subagent)   │
│               │ │               │ │               │
│ Deep reasoning│ │ Code tasks    │ │ Long context  │
│ No tools      │ │ Full tools    │ │ Read-only     │
└───────────────┘ └───────────────┘ └───────────────┘
```

| Agent        | Model                   | Mode     | Purpose                                    | Tools     |
|--------------|-------------------------|----------|--------------------------------------------|-----------|
| `cos`        | dis-assistant-cos       | Primary  | Orchestrator, routing, file operations     | All tools |
| `magistral`  | dis-assistant-magistral | Subagent | Deep reasoning, analysis, brainstorming    | None      |
| `coder`      | dis-assistant-coder     | Subagent | Agentic coding for development tasks       | All tools |
| `granite`    | dis-assistant-granite   | Subagent | Document review, long context analysis     | Read-only |

#### cos (Default Agent)

Primary orchestrator agent (Chief of Staff):

- Routes tasks to specialized subagents via `@mention`
- File manipulation (read, write, edit)
- Lightweight (~5GB VRAM) for always-on operation
- Portuguese (Portugal) language optimization

**Delegation examples:**

```
@magistral analisa esta proposta e dá-me feedback estratégico
@coder implementa uma função de autenticação JWT
@granite resume este documento de 50 páginas
```

**Configuration:** `.opencode/agent/cos.md`

#### magistral (Subagent)

Strategic analysis agent for deep reasoning:

- Complex analysis and brainstorming
- Email drafting and communication
- Technical proposals and summaries
- Multi-perspective analysis (Executive, Architect, Product Manager)

**Note:** No tool access - focuses purely on reasoning quality.

**Configuration:** `.opencode/agent/magistral.md`

#### coder (Subagent)

Development-focused agent for coding tasks:

- Code generation and refactoring
- Debugging and code review
- Technical documentation
- Git operations and project setup

#### granite (Subagent)

Read-only agent for document analysis:

- Document summarization
- Code review (read-only)
- Quick Q&A about codebase
- Long context analysis (32K tokens)

### Agent Prompts

Custom agent prompts are stored in `.opencode/agent/`:

```plain
.opencode/
└── agent/
    ├── cos.md          # Primary orchestrator (Chief of Staff)
    └── magistral.md    # Strategic analysis subagent
```

To create a new agent prompt:

1. Create a markdown file in `.opencode/agent/`
2. Add YAML frontmatter with agent metadata
3. Define the system prompt and templates
4. Reference it in `opencode.json`

Example frontmatter:

```yaml
---
description: Your agent description
mode: primary  # or subagent
model: ollama/your-model
temperature: 0.3
tools:
  read: true
  glob: true
  grep: true
  bash: true
  write: true
  edit: true
---
```

### Usage

```bash
# Start OpenCode in current directory
opencode

# Use a specific agent
opencode --agent coder

# Run a single command
opencode "explain this codebase"
```

### Server Configuration

The default configuration connects to:

```plain
http://metalai.onemarc.io:11434/v1
```

To use a different server, edit `opencode.json`:

```json
{
  "provider": {
    "ollama": {
      "options": {
        "baseURL": "http://your-server:11434/v1"
      }
    }
  }
}
```

---

## Cheat Sheet

Quick copy-paste commands for common operations.

### Update All Containers

```bash
# Update all services (run from repo root)
cd ollama && sh execute-update.sh && cd ..
cd open-webui && sh execute-update.sh && cd ..
cd portainer && sh execute-update.sh && cd ..
```

### Setup OpenCode Configuration

```bash
# Copy default config and agent prompts to local configuration
cp opencode.json.default ~/.config/opencode/opencode.json && \
mkdir -p ~/.config/opencode/agent && \
cp .opencode/agent/*.md ~/.config/opencode/agent/
```

### Update All Models

```bash
# Update all installed Ollama models to latest versions
./ollama-update-models.sh
```

### Rebuild Custom Models

```bash
# Remove old models
docker exec -it ollama ollama rm dis-assistant-cos
docker exec -it ollama ollama rm dis-assistant-magistral
docker exec -it ollama ollama rm dis-assistant-granite
docker exec -it ollama ollama rm dis-assistant-coder

# Rebuild all custom models after changes
docker exec -it ollama ollama create dis-assistant-cos -f ./dis-assistant-cos/Modelfile-dis-assistant-cos
docker exec -it ollama ollama create dis-assistant-magistral -f ./dis-assistant-magistral/Modelfile-dis-assistant-magistral
docker exec -it ollama ollama create dis-assistant-granite -f ./dis-assistant-granite/Modelfile-dis-assistant-granite
docker exec -it ollama ollama create dis-assistant-coder -f ./dis-assistant-coder/Modelfile-dis-assistant-coder
```

### Unload All Models from GPU

```bash
# Free GPU memory by unloading all loaded models
curl -s http://localhost:11434/api/tags | jq -r '.models[].name' | xargs -I {} curl -s http://localhost:11434/api/generate -d '{"model": "{}", "keep_alive": 0}'
```

### View Service Logs

```bash
# Ollama logs
docker logs -f ollama

# OpenWebUI logs
docker logs -f open-webui

# All container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### GPU Monitoring

```bash
# Real-time GPU monitoring
watch -n1 nvidia-smi

# GPU memory usage only
nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv
```

### Enter Ollama Container

```bash
# Interactive shell in Ollama container
docker exec -it ollama bash

# Run single command in container
docker exec ollama ollama list
```

### Restart Services

```bash
# Restart single service
docker restart ollama
docker restart open-webui

# Restart all Metal-AI services
docker restart ollama open-webui portainer
```

### Check Service Health

```bash
# Verify Ollama API is responding
curl -s http://localhost:11434/api/tags | jq '.models[].name'

# Check OpenWebUI connectivity to Ollama
docker exec open-webui curl -s http://127.0.0.1:11434/api/tags | jq '.models | length'
```

### Disk Usage

```bash
# Check model storage usage
du -sh /data/ollama_*

# List models with sizes
docker exec ollama ollama list
```

---

## Troubleshooting

### GPU Not Detected

```bash
# Check NVIDIA driver
nvidia-smi

# Check Docker GPU access
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi

# Verify container runtime
docker info | grep -i runtime
```

### NVML Initialization Error

```bash
# Edit container runtime config
sudo nano /etc/nvidia-container-runtime/config.toml
# Set: no-cgroups = false

# Restart Docker
sudo systemctl restart docker
```

### Model Loading Issues

```bash
# Check Ollama logs
docker logs ollama

# Check available VRAM
nvidia-smi

# Unload models to free memory
curl http://localhost:11434/api/generate -d '{"model": "model-name", "keep_alive": 0}'
```

### OpenWebUI Connection Issues

```bash
# Verify Ollama is running
curl http://localhost:11434/api/tags

# Check OpenWebUI logs
docker logs open-webui

# Ensure network connectivity
docker exec open-webui curl http://127.0.0.1:11434/api/tags
```

---

## Additional Resources

- [Ollama Documentation](https://ollama.ai/)
- [OpenWebUI Documentation](https://docs.openwebui.com/getting-started/quick-start)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html)
- [Hugging Face Model Hub](https://huggingface.co/models)
