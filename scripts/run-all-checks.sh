#!/bin/bash

# Script para ejecutar todas las validaciones localmente
# Uso: ./scripts/run-all-checks.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================="
echo "Running All Validation Checks"
echo "=================================="

ERRORS=0

# 1. Verificar estructura
echo ""
echo "[1/5] Checking repository structure..."
if ./scripts/check-structure.sh; then
    echo "✅ Structure check passed"
else
    echo "⚠️  Structure check found issues"
    ERRORS=$((ERRORS + 1))
fi

# 2. Validar markdown
echo ""
echo "[2/5] Running markdown lint..."
if ./scripts/validate-markdown.sh; then
    echo "✅ Markdown lint passed"
else
    echo "⚠️  Markdown lint found issues"
    ERRORS=$((ERRORS + 1))
fi

# 3. Verificar enlaces
echo ""
echo "[3/5] Running link checker..."
if ./scripts/check-links.sh; then
    echo "✅ Link check passed"
else
    echo "⚠️  Link check found issues (non-blocking)"
fi

# 4. Verificar ortografía
echo ""
echo "[4/5] Running spell check..."
if ./scripts/spell-check.sh; then
    echo "✅ Spell check passed"
else
    echo "⚠️  Spell check found issues"
    ERRORS=$((ERRORS + 1))
fi

# 5. Estadísticas finales
echo ""
echo "[5/5] Generating statistics..."
md_count=$(find "$ROOT_DIR" -name "*.md" -not -path "*/node_modules/*" | wc -l)
echo "Total markdown files: $md_count"

# Resumen
echo ""
echo "=================================="
echo "Validation Summary"
echo "=================================="
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed!"
    exit 0
else
    echo "⚠️  $ERRORS check(s) found issues"
    echo "Review the output above for details."
    exit 1
fi
