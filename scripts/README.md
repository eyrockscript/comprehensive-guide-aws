# Scripts de Utilidad

Este directorio contiene scripts útiles para el mantenimiento y validación del repositorio.

## Scripts Disponibles

### `validate-markdown.sh`
Valida la sintaxis y formato de los archivos markdown usando markdownlint.

```bash
./scripts/validate-markdown.sh              # Valida todos los archivos
./scripts/validate-markdown.sh ruta/archivo.md # Valida un archivo específico
```

### `check-links.sh`
Verifica que los enlaces en los archivos markdown sean válidos.

```bash
./scripts/check-links.sh                    # Verifica todos los enlaces
./scripts/check-links.sh ruta/archivo.md     # Verifica enlaces en un archivo
```

### `spell-check.sh`
Ejecuta un verificador ortográfico en los archivos markdown.

```bash
./scripts/spell-check.sh                    # Verifica todos los archivos
./scripts/spell-check.sh ruta/archivo.md    # Verifica un archivo específico
```

### `render-mermaid.sh`
Renderiza diagramas Mermaid a SVG.

```bash
./scripts/render-mermaid.sh                 # Renderiza todos los diagramas
./scripts/render-mermaid.sh ruta/diagrama.mmd # Renderiza un diagrama específico
```

### `setup-hooks.sh`
Configura git hooks locales para validaciones pre-commit.

```bash
./scripts/setup-hooks.sh
```

### `check-structure.sh`
Verifica que la estructura del repositorio sea correcta.

```bash
./scripts/check-structure.sh
```

### `run-all-checks.sh`
Ejecuta todas las validaciones en secuencia.

```bash
./scripts/run-all-checks.sh
```

## Configuración

Los scripts utilizan archivos de configuración en la raíz del repositorio:

- `.markdownlint.json` - Reglas de linting para markdown
- `.cspell.json` - Configuración del verificador ortográfico
- `.markdown-link-check.json` - Configuración del verificador de enlaces

## Integración CI/CD

Estos scripts son utilizados por los workflows de GitHub Actions ubicados en `.github/workflows/`.
