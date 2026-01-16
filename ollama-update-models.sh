#!/bin/bash

updated=0
skipped=0
failed=0

echo "🔄 A verificar actualizações de modelos Ollama..."
echo ""

ollama list | awk 'NR>1 {print $1}' | while read model; do
    # Ignora modelos que parecem ser locais (sem "/" no nome e não são modelos oficiais conhecidos)
    base_model=$(echo "$model" | cut -d: -f1)
    
    output=$(ollama pull "$model" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        if echo "$output" | grep -q "up to date"; then
            echo "○ $model (já actualizado)"
            ((skipped++))
        else
            echo "✓ $model (actualizado)"
            ((updated++))
        fi
    else
        echo "⚠ $model (ignorado - provavelmente local)"
        ((failed++))
    fi
done

echo ""
echo "📊 Resumo: $updated actualizados, $skipped já actuais, $failed ignorados"