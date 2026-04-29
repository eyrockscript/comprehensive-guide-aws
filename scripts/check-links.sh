#!/bin/bash

# Script para verificar enlaces en archivos markdown
# Uso: ./scripts/check-links.sh [archivo_opcional]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================="
echo "Link Checker Script"
echo "=================================="

# Verificar si existe markdown-link-check
if ! command -v markdown-link-check &> /dev/null; then
    echo "Instalando markdown-link-check..."
    npm install -g markdown-link-check@3.12.2
fi

# Ejecutar verificación de enlaces
if [ -n "$1" ]; then
    echo "Verificando enlaces en: $1"
    markdown-link-check "$1" --config "$ROOT_DIR/.markdown-link-check.json" 2>&1
else
    echo "Verificando enlaces en todos los archivos markdown..."
    find "$ROOT_DIR" -name "*.md" -not -path "*/node_modules/*" -print0 | while IFS= read -r -d '' file; do
        echo "Checking: $file"
        markdown-link-check "$file" --config "$ROOT_DIR/.markdown-link-check.json" 2>&1 || true
    done
fi

echo ""
echo "Verificación de enlaces completada!"
