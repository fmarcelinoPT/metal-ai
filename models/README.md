# DiS Custom Ollama Models

Custom Ollama models for the Digital Solutions business unit.

## Prerequisites - Pull Base Models

Before creating the custom models, pull the base models:

```bash
# 1. CoS - Lightweight orchestrator (Qwen3 8B)
ollama pull qwen3:8b

# 2. Magistral - Reasoning & analysis (Magistral Small 24B)
ollama pull hf.co/unsloth/Magistral-Small-2509-GGUF:UD-Q5_K_XL

# 3. Granite - Long context analysis (IBM Granite 8B)
ollama pull hf.co/ibm-granite/granite-3.3-8b-instruct-GGUF:Q6_K

# 4. Coder - Agentic coding (Qwen3-Coder 30B)
ollama pull qwen3-coder:30b
```

**Total download:** ~45GB (modelos são armazenados em `/data/ollama_*`)

## Installation

```bash
# Remove existing ones
ollama rm dis-assistant-cos && \
ollama rm dis-assistant-magistral && \
ollama rm dis-assistant-granite && \
ollama rm dis-assistant-coder

# Navigate to model directory and create models
cd dis-assistant-cos && bash create-model.sh && cd ..
cd dis-assistant-magistral && bash create-model.sh && cd ..
cd dis-assistant-granite && bash create-model.sh && cd ..
cd dis-assistant-coder && bash create-model.sh && cd ..

# Or manually:
ollama create dis-assistant-cos -f dis-assistant-cos/Modelfile-dis-assistant-cos
ollama create dis-assistant-magistral -f dis-assistant-magistral/Modelfile-dis-assistant-magistral
ollama create dis-assistant-granite -f dis-assistant-granite/Modelfile-dis-assistant-granite
ollama create dis-assistant-coder -f dis-assistant-coder/Modelfile-dis-assistant-coder
```

## Testing

```bash
ollama run dis-assistant-cos "Hello, briefly introduce yourself."
ollama run dis-assistant-magistral "Hello, briefly introduce yourself."
ollama run dis-assistant-granite "Hello, briefly introduce yourself."
ollama run dis-assistant-coder "Write a Python function to calculate fibonacci."
```

## Models

| Model                   | Base                       | Purpose                           | VRAM  |
|-------------------------|----------------------------|-----------------------------------|-------|
| dis-assistant-cos      | Qwen3 8B                   | Lightweight orchestrator (tools)  | ~5GB  |
| dis-assistant-magistral | Magistral Small 2509 (24B) | Reasoning and analysis (subagent) | ~16GB |
| dis-assistant-granite   | IBM Granite 3.3 8B         | Quick day-to-day tasks            | ~8GB  |
| dis-assistant-coder     | Qwen3-Coder 30B            | Agentic coding assistant          | ~18GB |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   AGENTE PRIMÁRIO: cos                      │
│                                                             │
│  Modelo: Qwen3:8b (~5GB) - Lightweight Orchestrator        │
│  Prompt: Chief of Staff (CoS) DiS                          │
│  Tools: read, write, edit, glob, grep, bash                │
│  Função: Routing, file ops, delega trabalho pesado         │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│   SUBAGENT    │ │   SUBAGENT    │ │   SUBAGENT    │
│   magistral   │ │    coder      │ │    granite    │
│               │ │               │ │               │
│ Magistral     │ │ Qwen3-Coder   │ │ Granite 8B    │
│ Small 24B     │ │ 30B           │ │               │
│               │ │               │ │               │
│ Análise       │ │ Código        │ │ Contexto      │
│ estratégica   │ │               │ │ extenso       │
│ Raciocínio    │ │               │ │               │
│ ❌ Tools      │ │ ✅ Tools      │ │ ❌ Tools      │
└───────────────┘ └───────────────┘ └───────────────┘
```
