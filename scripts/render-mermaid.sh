#!/bin/bash

# Script para renderizar diagramas Mermaid localmente
# Uso: ./scripts/render-mermaid.sh [archivo.mmd]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================="
echo "Mermaid Diagram Render Script"
echo "=================================="

# Verificar si existe mmdc
if ! command -v mmdc &> /dev/null; then
    echo "Instalando @mermaid-js/mermaid-cli..."
    npm install -g @mermaid-js/mermaid-cli@10.9.1
fi

# Crear directorio de salida
mkdir -p "$ROOT_DIR/assets/diagrams"

# Renderizar diagramas
if [ -n "$1" ]; then
    if [ -f "$1" ]; then
        echo "Renderizando: $1"
        output_name=$(basename "$1" .mmd)
        mmdc -i "$1" -o "$ROOT_DIR/assets/diagrams/${output_name}.svg" -b transparent
        echo "Diagrama guardado en: assets/diagrams/${output_name}.svg"
    else
        echo "Error: Archivo $1 no encontrado"
        exit 1
    fi
else
    echo "Buscando archivos .mmd para renderizar..."
    find "$ROOT_DIR" -name "*.mmd" -not -path "*/node_modules/*" | while read -r file; do
        echo "Renderizando: $file"
        output_name=$(basename "$file" .mmd)
        mmdc -i "$file" -o "$ROOT_DIR/assets/diagrams/${output_name}.svg" -b transparent || true
    done
fi

echo ""
echo "Renderizado completado!"
echo "Los diagramas SVG se encuentran en: assets/diagrams/"
