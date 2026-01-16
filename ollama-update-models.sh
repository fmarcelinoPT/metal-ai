#!/bin/bash

updated=0
skipped=0
failed=0

echo "🔄 Checking for Ollama model updates..."
echo ""

ollama list | awk 'NR>1 {print $1}' | while read model; do
    # Skip models that appear to be local (no "/" in name and not known official models)
    base_model=$(echo "$model" | cut -d: -f1)

    output=$(ollama pull "$model" 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        if echo "$output" | grep -q "up to date"; then
            echo "○ $model (already up to date)"
            ((skipped++))
        else
            echo "✓ $model (updated)"
            ((updated++))
        fi
    else
        echo "⚠ $model (skipped - probably local)"
        ((failed++))
    fi
done

echo ""
echo "📊 Summary: $updated updated, $skipped already current, $failed skipped"