#!/bin/bash

# Script para verificar la estructura del repositorio
# Uso: ./scripts/check-structure.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================="
echo "Repository Structure Check"
echo "=================================="

ERRORS=0

# Verificar directorios requeridos
echo ""
echo "Verificando directorios..."

required_dirs=(
    "es"
    "en"
    "es/whitepapers"
    "en/whitepapers"
    "es/labs"
    "en/labs"
    "es/cheatsheets"
    "en/cheatsheets"
    "assets"
    ".github/workflows"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$ROOT_DIR/$dir" ]; then
        echo "  [OK] $dir/"
    else
        echo "  [MISSING] $dir/"
        ERRORS=$((ERRORS + 1))
    fi
done

# Verificar archivos requeridos
echo ""
echo "Verificando archivos principales..."

required_files=(
    "README.md"
    "LICENSE"
    ".markdownlint.json"
    ".cspell.json"
)

for file in "${required_files[@]}"; do
    if [ -f "$ROOT_DIR/$file" ]; then
        echo "  [OK] $file"
    else
        echo "  [MISSING] $file"
        ERRORS=$((ERRORS + 1))
    fi
done

# Verificar workflows de GitHub Actions
echo ""
echo "Verificando workflows de GitHub Actions..."

workflows=(
    "markdown-lint.yml"
    "link-checker.yml"
    "spell-check.yml"
    "mermaid-render.yml"
)

for workflow in "${workflows[@]}"; do
    if [ -f "$ROOT_DIR/.github/workflows/$workflow" ]; then
        echo "  [OK] .github/workflows/$workflow"
    else
        echo "  [MISSING] .github/workflows/$workflow"
        ERRORS=$((ERRORS + 1))
    fi
done

# Verificar scripts
echo ""
echo "Verificando scripts de utilidad..."

scripts=(
    "validate-markdown.sh"
    "check-links.sh"
    "spell-check.sh"
    "render-mermaid.sh"
    "setup-hooks.sh"
    "check-structure.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$ROOT_DIR/scripts/$script" ]; then
        if [ -x "$ROOT_DIR/scripts/$script" ]; then
            echo "  [OK] scripts/$script"
        else
            echo "  [NOT EXECUTABLE] scripts/$script"
        fi
    else
        echo "  [MISSING] scripts/$script"
        ERRORS=$((ERRORS + 1))
    fi
done

# Estadísticas
echo ""
echo "=================================="
echo "Estadísticas del Repositorio"
echo "=================================="

md_count=$(find "$ROOT_DIR" -name "*.md" -not -path "*/node_modules/*" | wc -l)
echo "Archivos markdown: $md_count"

es_count=$(find "$ROOT_DIR/es" -name "*.md" 2>/dev/null | wc -l)
en_count=$(find "$ROOT_DIR/en" -name "*.md" 2>/dev/null | wc -l)
echo "  - Español: $es_count"
echo "  - Inglés: $en_count"

img_count=$(find "$ROOT_DIR/assets" -type f \( -name "*.png" -o -name "*.svg" -o -name "*.jpg" \) 2>/dev/null | wc -l)
echo "Imágenes: $img_count"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ Verificación completada: Todos los elementos requeridos están presentes"
    exit 0
else
    echo "⚠️  Verificación completada: Se encontraron $ERRORS elementos faltantes"
    exit 1
fi
