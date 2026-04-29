#!/bin/bash

# Script para verificar ortografía en archivos markdown
# Uso: ./scripts/spell-check.sh [archivo_opcional]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================="
echo "Spell Check Script"
echo "=================================="

# Verificar si existe cspell
if ! command -v cspell &> /dev/null; then
    echo "Instalando cspell..."
    npm install -g cspell@8.14.0
fi

# Ejecutar verificación ortográfica
if [ -n "$1" ]; then
    echo "Verificando ortografía en: $1"
    cspell "$1" --config "$ROOT_DIR/.cspell.json" --show-suggestions
else
    echo "Verificando ortografía en todos los archivos markdown..."
    cspell "**/*.md" \
        --config "$ROOT_DIR/.cspell.json" \
        --no-progress \
        --show-suggestions
fi

echo ""
echo "Verificación de ortografía completada!"
