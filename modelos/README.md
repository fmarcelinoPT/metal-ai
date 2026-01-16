# DiS Custom Ollama Models

Custom Ollama models for the Digital Solutions business unit.

## Installation

```bash
# Navigate to model directory and create models
cd dis-assistant-magistral && ./create-model.sh && cd ..
cd dis-assistant-granite && ./create-model.sh && cd ..
cd dis-assistant-coder && ./create-model.sh && cd ..

# Or manually:
ollama create dis-assistant-magistral -f dis-assistant-magistral/Modelfile-dis-assistant-magistral
ollama create dis-assistant-granite -f dis-assistant-granite/Modelfile-dis-assistant-granite
ollama create dis-assistant-coder -f dis-assistant-coder/Modelfile-dis-assistant-coder
```

## Testing

```bash
ollama run dis-assistant-magistral "Hello, briefly introduce yourself."
ollama run dis-assistant-granite "Hello, briefly introduce yourself."
ollama run dis-assistant-coder "Write a Python function to calculate fibonacci."
```

## Models

| Model | Base | Purpose | VRAM |
|-------|------|---------|------|
| dis-assistant-magistral | Magistral Small 2509 (24B) | Reasoning and analysis tasks | ~16GB |
| dis-assistant-granite | IBM Granite 3.3 8B | Quick day-to-day tasks | ~8GB |
| dis-assistant-coder | Qwen3-Coder 30B | Agentic coding assistant | ~18GB |
