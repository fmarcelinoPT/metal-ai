#!/bin/bash
# ============================================================================
# Setup Devstral Agent para OpenCode
# Comportamento tipo Claude Code em infraestrutura local
# ============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           Devstral Agent Setup para OpenCode                 ║"
echo "║              Comportamento tipo Claude Code                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================================
# Configuração - AJUSTA CONFORME A TUA INFRAESTRUTURA
# ============================================================================

OLLAMA_HOST="${OLLAMA_HOST:-metalai.onemarc.io}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"
OLLAMA_URL="http://${OLLAMA_HOST}:${OLLAMA_PORT}"
MODEL_NAME="devstral-agent"
BASE_MODEL="devstral-small-2"

# ============================================================================
# Verificações
# ============================================================================

echo -e "${YELLOW}[1/5]${NC} A verificar conectividade com Ollama..."

if ! curl -s "${OLLAMA_URL}/api/tags" > /dev/null 2>&1; then
    echo -e "${RED}✗ Não foi possível conectar a ${OLLAMA_URL}${NC}"
    echo "  Verifica se o Ollama está a correr e acessível."
    exit 1
fi
echo -e "${GREEN}✓ Ollama acessível em ${OLLAMA_URL}${NC}"

# ============================================================================
# Download do modelo base (se necessário)
# ============================================================================

echo -e "${YELLOW}[2/5]${NC} A verificar modelo base ${BASE_MODEL}..."

if curl -s "${OLLAMA_URL}/api/tags" | grep -q "\"${BASE_MODEL}\""; then
    echo -e "${GREEN}✓ Modelo ${BASE_MODEL} já existe${NC}"
else
    echo -e "${BLUE}↓ A descarregar ${BASE_MODEL}... (pode demorar alguns minutos)${NC}"
    curl -X POST "${OLLAMA_URL}/api/pull" -d "{\"name\": \"${BASE_MODEL}\"}" --no-buffer | while read line; do
        status=$(echo "$line" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$status" ]; then
            echo -ne "\r  ${status}                    "
        fi
    done
    echo ""
    echo -e "${GREEN}✓ Modelo ${BASE_MODEL} descarregado${NC}"
fi

# ============================================================================
# Criar modelo customizado
# ============================================================================

echo -e "${YELLOW}[3/5]${NC} A criar modelo customizado ${MODEL_NAME}..."

# Envia o Modelfile para o Ollama
MODELFILE_CONTENT=$(cat Modelfile)

# Criar o modelo via API
curl -s -X POST "${OLLAMA_URL}/api/create" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"${MODEL_NAME}\",
        \"modelfile\": $(echo "$MODELFILE_CONTENT" | jq -Rs .)
    }" | while read line; do
        status=$(echo "$line" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$status" ]; then
            echo -ne "\r  ${status}                    "
        fi
    done
echo ""
echo -e "${GREEN}✓ Modelo ${MODEL_NAME} criado${NC}"

# ============================================================================
# Configurar OpenCode
# ============================================================================

echo -e "${YELLOW}[4/5]${NC} A configurar OpenCode..."

OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
mkdir -p "${OPENCODE_CONFIG_DIR}"

# Backup da config existente
if [ -f "${OPENCODE_CONFIG_DIR}/opencode.json" ]; then
    cp "${OPENCODE_CONFIG_DIR}/opencode.json" "${OPENCODE_CONFIG_DIR}/opencode.json.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${BLUE}  Backup da configuração anterior criado${NC}"
fi

# Actualiza o URL no ficheiro de config e copia
sed "s|metalai.onemarc.io|${OLLAMA_HOST}|g" opencode.json > "${OPENCODE_CONFIG_DIR}/opencode.json"

echo -e "${GREEN}✓ OpenCode configurado em ${OPENCODE_CONFIG_DIR}/opencode.json${NC}"

# ============================================================================
# Teste rápido
# ============================================================================

echo -e "${YELLOW}[5/5]${NC} A testar o modelo..."

RESPONSE=$(curl -s -X POST "${OLLAMA_URL}/api/generate" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"${MODEL_NAME}\",
        \"prompt\": \"Say 'Agent ready!' in exactly 2 words.\",
        \"stream\": false,
        \"options\": {
            \"num_predict\": 10
        }
    }" | jq -r '.response // "Error"')

if [[ "$RESPONSE" == *"ready"* ]] || [[ "$RESPONSE" == *"Ready"* ]] || [[ "$RESPONSE" != "Error" ]]; then
    echo -e "${GREEN}✓ Modelo a responder correctamente${NC}"
else
    echo -e "${YELLOW}⚠ Resposta do modelo: ${RESPONSE}${NC}"
    echo "  O modelo pode precisar de alguns segundos para carregar na primeira vez."
fi

# ============================================================================
# Resumo
# ============================================================================

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗"
echo -e "║                    Setup Completo! 🚀                         ║"
echo -e "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Para usar:"
echo -e "  ${GREEN}opencode${NC}                           # Inicia o OpenCode"
echo -e "  ${GREEN}opencode --model ollama/${MODEL_NAME}${NC} # Usa o modelo directamente"
echo ""
echo -e "Modelo criado: ${GREEN}${MODEL_NAME}${NC}"
echo -e "Contexto: ${GREEN}65536 tokens${NC}"
echo -e "Servidor: ${GREEN}${OLLAMA_URL}${NC}"
echo ""
echo -e "${YELLOW}Dica:${NC} Na primeira execução, o modelo demora a carregar nas GPUs."
echo -e "      As execuções seguintes serão muito mais rápidas."
echo ""
