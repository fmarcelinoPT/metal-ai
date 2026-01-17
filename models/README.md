# DiS Custom Ollama Models

Custom Ollama models for the Digital Solutions business unit.

## Prerequisites - Pull Base Models

Before creating the custom models, pull the base models:

```bash
# 1. Exec - Primary orchestrator (Qwen3 14B)
ollama pull qwen3:14b

# 2. Analyst - Strategic analysis (Magistral Small 24B)
ollama pull hf.co/unsloth/Magistral-Small-2509-GGUF:UD-Q5_K_XL

# 3. Coder - Agentic coding (Qwen3-Coder 30B)
ollama pull qwen3-coder:30b
```

**Total download:** ~40GB (modelos sao armazenados em `/data/ollama_*`)

## Installation

```bash
# Remove existing ones (if any)
ollama rm dis-assistant-exec && \
ollama rm dis-assistant-analyst && \
ollama rm dis-assistant-coder

# Navigate to model directory and create models
cd dis-assistant-exec && bash create-model.sh && cd ..
cd dis-assistant-analyst && bash create-model.sh && cd ..
cd dis-assistant-coder && bash create-model.sh && cd ..

# Or manually:
ollama create dis-assistant-exec -f dis-assistant-exec/Modelfile-dis-assistant-exec
ollama create dis-assistant-analyst -f dis-assistant-analyst/Modelfile-dis-assistant-analyst
ollama create dis-assistant-coder -f dis-assistant-coder/Modelfile-dis-assistant-coder
```

## Testing

```bash
ollama run dis-assistant-exec "Hello, briefly introduce yourself."
ollama run dis-assistant-analyst "Hello, briefly introduce yourself."
ollama run dis-assistant-coder "Write a Python function to calculate fibonacci."
```

## Models

| Model                   | Base                       | Purpose                           | VRAM  |
|-------------------------|----------------------------|-----------------------------------|-------|
| dis-assistant-exec      | Qwen3 14B                  | Primary orchestrator (tools)      | ~9GB  |
| dis-assistant-analyst   | Magistral Small 2509 (24B) | Strategic analysis (subagent)     | ~16GB |
| dis-assistant-coder     | Qwen3-Coder 30B            | Agentic coding assistant          | ~18GB |

## VRAM Combinations (48GB total)

| Combination         | VRAM Total    | Use Case             |
|---------------------|---------------|----------------------|
| exec + analyst      | 9 + 16 = 25GB | Strategic analysis   |
| exec + coder        | 9 + 18 = 27GB | Development tasks    |
| exec alone          | 9GB           | Simple daily tasks   |

All combinations fit within the 48GB VRAM limit (2x RTX 3090).

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              AGENTE PRIMARIO: exec                          │
│                                                             │
│  Modelo: Qwen3:14b (~9GB) - Primary Orchestrator           │
│  Prompt: Executive Assistant DiS                           │
│  Tools: read, write, edit, glob, grep, bash                │
│  Funcao: Tarefas diarias, routing, delega trabalho pesado  │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        ▼                           ▼
┌───────────────────┐     ┌───────────────────┐
│   SUBAGENT        │     │   SUBAGENT        │
│   analyst         │     │    coder          │
│                   │     │                   │
│ Magistral         │     │ Qwen3-Coder       │
│ Small 24B         │     │ 30B               │
│ ~16GB             │     │ ~18GB             │
│                   │     │                   │
│ @analyst          │     │ @coder            │
│ Analise           │     │ Codigo            │
│ estrategica       │     │ Implementacao     │
│ Brainstorming     │     │ Debugging         │
│ ❌ Tools          │     │ ✅ Tools          │
└───────────────────┘     └───────────────────┘
```
