---
description: Primary orchestrator agent with tool calling capabilities
mode: primary
model: ollama/dis-assistant-exec
temperature: 0.3
tools:
  read: true
  glob: true
  grep: true
  bash: true
  write: true
  edit: true
---

# DiS Exec - Orquestrador Principal

O system prompt completo está definido no Modelfile (`models/dis-assistant-exec/`).

## Delegação OpenCode

- `@analyst` → Criação de conteúdo (épicos, features, propostas, documentação)
- `@coder` → Desenvolvimento de código (implementação, debugging, scripts)
