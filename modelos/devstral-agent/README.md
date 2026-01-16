# Devstral Agent para OpenCode

Setup optimizado para comportamento tipo Claude Code usando Devstral Small 2 em infraestrutura local.

## Requisitos

- Ollama a correr (local ou remoto)
- 2x GPU com ~24GB VRAM total (ideal: RTX 3090, 4090, etc.)
- OpenCode instalado (`npm install -g opencode` ou via binário)
- `curl` e `jq` instalados

## Instalação Rápida

```bash
# Clona ou copia os ficheiros para uma pasta
cd devstral-agent

# Torna o script executável
chmod +x setup.sh

# Executa o setup
./setup.sh
```

## Instalação Manual

Se preferires fazer manualmente:

```bash
# 1. Descarrega o modelo base
ollama pull devstral-small-2

# 2. Cria o modelo customizado
ollama create devstral-agent -f Modelfile

# 3. Copia a config do OpenCode
mkdir -p ~/.config/opencode
cp opencode.json ~/.config/opencode/opencode.json

# 4. Ajusta o URL do Ollama se necessário
# Edita ~/.config/opencode/opencode.json e altera "metalai.onemarc.io" para o teu host
```

## Uso

```bash
# Iniciar OpenCode (seleciona o modelo no menu)
opencode

# Ou directamente com o modelo
opencode --model ollama/devstral-agent
```

## Ficheiros

| Ficheiro | Descrição |
|----------|-----------|
| `Modelfile` | Configuração do modelo com system prompt agentic |
| `opencode.json` | Configuração do OpenCode para usar o modelo |
| `setup.sh` | Script de instalação automatizada |

## Parâmetros do Modelo

| Parâmetro | Valor | Descrição |
|-----------|-------|-----------|
| `num_ctx` | 65536 | Janela de contexto (64K tokens) |
| `temperature` | 0.15 | Baixa para respostas determinísticas |
| `top_p` | 0.9 | Diversidade controlada |
| `repeat_penalty` | 1.1 | Evita loops e repetições |

## Troubleshooting

### Tools não funcionam

O problema mais comum é contexto insuficiente. Verifica:

```bash
# Dentro do ollama
ollama run devstral-agent
>>> /show parameters
```

Deve mostrar `num_ctx: 65536` ou superior.

### Modelo lento na primeira execução

Normal — o modelo precisa de ser carregado nas GPUs. Execuções seguintes são rápidas.

### Erros de conexão

Verifica se o Ollama está acessível:

```bash
curl http://metalai.onemarc.io:11434/api/tags
```

### Modelo "esquece" de usar tools

Alguns prompts podem precisar de ser mais explícitos:
- ❌ "Mostra-me o ficheiro"
- ✅ "Lê o ficheiro X e mostra o conteúdo"

## Comparação com Claude Code

| Capacidade | Claude Code | Devstral Agent |
|------------|-------------|----------------|
| Tool calling | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Multi-file edits | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Raciocínio complexo | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Contexto longo | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Custo | $$$ | Gratuito |
| Privacidade | Cloud | 100% Local |

## Modelos Alternativos

Se quiseres experimentar outros modelos, edita o `opencode.json`:

```json
{
  "models": {
    "qwen3-coder:30b": {
      "name": "Qwen3 Coder 30B",
      "tools": true,
      "reasoning": true
    }
  }
}
```

## Licença

MIT - usa e adapta como quiseres.
