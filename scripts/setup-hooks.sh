#!/bin/bash

# Script para configurar git hooks localmente
# Uso: ./scripts/setup-hooks.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================="
echo "Git Hooks Setup Script"
echo "=================================="

# Crear directorio de hooks si no existe
mkdir -p "$ROOT_DIR/.git/hooks"

# Crear pre-commit hook
cat > "$ROOT_DIR/.git/hooks/pre-commit" << 'HOOK_EOF'
#!/bin/bash
# Pre-commit hook para validar markdown

echo "Ejecutando validaciones pre-commit..."

# Verificar archivos markdown modificados
md_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' || true)

if [ -n "$md_files" ]; then
    echo "Validando archivos markdown modificados..."

    # Verificar markdownlint
    if command -v markdownlint &> /dev/null; then
        echo "Ejecutando markdownlint..."
        echo "$md_files" | while read -r file; do
            if [ -f "$file" ]; then
                markdownlint "$file" --config .markdownlint.json || true
            fi
        done
    fi

    echo "Validaciones completadas."
fi

exit 0
HOOK_EOF

# Hacer ejecutables los hooks
chmod +x "$ROOT_DIR/.git/hooks/pre-commit"

echo "Git hooks configurados exitosamente!"
echo "Pre-commit hook instalado."
