#!/bin/bash

# Script para validar archivos markdown localmente
# Uso: ./scripts/validate-markdown.sh [archivo_opcional]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================="
echo "Markdown Validation Script"
echo "=================================="

# Verificar si existe markdownlint
if ! command -v markdownlint &> /dev/null; then
    echo "Instalando markdownlint-cli..."
    npm install -g markdownlint-cli@0.41.0
fi

# Ejecutar linting
if [ -n "$1" ]; then
    echo "Validando archivo: $1"
    markdownlint "$1" --config "$ROOT_DIR/.markdownlint.json"
else
    echo "Validando todos los archivos markdown..."
    markdownlint "**/*.md" \
        --ignore "node_modules/**" \
        --config "$ROOT_DIR/.markdownlint.json"
fi

echo ""
echo "Validación completada exitosamente!"
