# Cheatsheet: Comandos CLI de S3

## Operaciones Básicas

```bash
# Crear bucket
aws s3 mb s3://mi-bucket-ejemplo

# Crear bucket en región específica
aws s3 mb s3://mi-bucket-ejemplo --region eu-west-1

# Listar buckets
aws s3 ls

# Listar contenido de bucket
aws s3 ls s3://mi-bucket-ejemplo

# Listar con prefijo
aws s3 ls s3://mi-bucket-ejemplo/carpeta/

# Listar recursivamente
aws s3 ls s3://mi-bucket-ejemplo --recursive
```

## Subir Archivos

```bash
# Subir un archivo
aws s3 cp archivo.txt s3://mi-bucket-ejemplo/

# Subir con nombre diferente
aws s3 cp archivo.txt s3://mi-bucket-ejemplo/renombrado.txt

# Subir directorio recursivamente
aws s3 cp ./mi-carpeta s3://mi-bucket-ejemplo/ --recursive

# Subir con metadata
aws s3 cp archivo.txt s3://mi-bucket-ejemplo/ \
    --metadata "autor=Juan,proyecto=Demo"

# Sincronizar directorio (solo cambios)
aws s3 sync ./mi-carpeta s3://mi-bucket-ejemplo/

# Sincronizar excluyendo patrones
aws s3 sync ./mi-carpeta s3://mi-bucket-ejemplo/ \
    --exclude "*.tmp" --exclude "*.log"
```

## Descargar Archivos

```bash
# Descargar un archivo
aws s3 cp s3://mi-bucket-ejemplo/archivo.txt ./

# Descargar directorio completo
aws s3 cp s3://mi-bucket-ejemplo/mi-carpeta ./ --recursive

# Sincronizar descarga
aws s3 sync s3://mi-bucket-ejemplo/ ./backup-local/
```

## Copiar entre Buckets

```bash
# Copiar entre buckets
aws s3 cp s3://bucket-origen/archivo.txt s3://bucket-destino/

# Copiar con recursive
aws s3 cp s3://bucket-origen/carpeta/ s3://bucket-destino/carpeta/ --recursive
```

## Eliminar Archivos

```bash
# Eliminar un archivo
aws s3 rm s3://mi-bucket-ejemplo/archivo.txt

# Eliminar directorio recursivamente
aws s3 rm s3://mi-bucket-ejemplo/carpeta/ --recursive

# Eliminar bucket (debe estar vacío)
aws s3 rb s3://mi-bucket-ejemplo

# Forzar eliminación (vacía y elimina)
aws s3 rb s3://mi-bucket-ejemplo --force
```

## Presignar URLs

```bash
# Generar URL temporal (3600 segundos por defecto)
aws s3 presign s3://mi-bucket-ejemplo/archivo.txt

# URL con expiración personalizada
aws s3 presign s3://mi-bucket-ejemplo/archivo.txt \
    --expires-in 3600  # 1 hora en segundos

# Para PUT (subida)
aws s3 presign s3://mi-bucket-ejemplo/archivo.txt \
    --method put \
    --expires-in 600
```

## Website Hosting

```bash
# Configurar bucket para website
aws s3api put-bucket-website \
    --bucket mi-bucket-ejemplo \
    --website-configuration file://website-config.json

# website-config.json:
{
  "IndexDocument": {"Suffix": "index.html"},
  "ErrorDocument": {"Key": "error.html"}
}

# Establecer política pública
aws s3api put-bucket-policy \
    --bucket mi-bucket-ejemplo \
    --policy file://policy.json
```

## Versionamiento

```bash
# Habilitar versionamiento
aws s3api put-bucket-versioning \
    --bucket mi-bucket-ejemplo \
    --versioning-configuration Status=Enabled

# Suspender versionamiento
aws s3api put-bucket-versioning \
    --bucket mi-bucket-ejemplo \
    --versioning-configuration Status=Suspended

# Listar versiones
aws s3api list-object-versions \
    --bucket mi-bucket-ejemplo \
    --prefix archivo.txt

# Descargar versión específica
aws s3api get-object \
    --bucket mi-bucket-ejemplo \
    --key archivo.txt \
    --version-id abc123def456 \
    archivo-version.txt
```

## Ciclo de Vida

```bash
# Configurar reglas de ciclo de vida
aws s3api put-bucket-lifecycle-configuration \
    --bucket mi-bucket-ejemplo \
    --lifecycle-configuration file://lifecycle.json

# lifecycle.json:
{
  "Rules": [{
    "ID": "MoverAIA",
    "Status": "Enabled",
    "Filter": {"Prefix": "logs/"},
    "Transitions": [{
      "Days": 30,
      "StorageClass": "STANDARD_IA"
    }],
    "Expiration": {"Days": 365}
  }]
}
```

## Encripción

```bash
# Configurar encripción por defecto (SSE-S3)
aws s3api put-bucket-encryption \
    --bucket mi-bucket-ejemplo \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }]
    }'

# Con KMS
aws s3api put-bucket-encryption \
    --bucket mi-bucket-ejemplo \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "aws:kms",
          "KMSMasterKeyID": "arn:aws:kms:region:account:key/12345"
        }
      }]
    }'
```

## Logging

```bash
# Habilitar logging
aws s3api put-bucket-logging \
    --bucket mi-bucket-ejemplo \
    --bucket-logging-status file://logging-config.json

# logging-config.json:
{
  "LoggingEnabled": {
    "TargetBucket": "mi-bucket-logs",
    "TargetPrefix": "s3-logs/"
  }
}
```

## Replication

```bash
# Configurar replicación
aws s3api put-bucket-replication \
    --bucket mi-bucket-origen \
    --replication-configuration file://replication.json \
    --token <token>
```

## Consejos Rápidos

| Tarea | Comando |
|-------|---------|
| Subir archivo | `aws s3 cp local s3://bucket/` |
| Descargar archivo | `aws s3 cp s3://bucket/ local` |
| Sincronizar | `aws s3 sync origen destino` |
| Eliminar todo | `aws s3 rm s3://bucket/ --recursive` |
| URL temporal | `aws s3 presign s3://bucket/archivo` |

## Atajos Útiles

```bash
# Ver tamaño de bucket
aws s3 ls s3://mi-bucket-ejemplo --recursive --human-readable --summarize

# Copiar solo archivos nuevos
aws s3 sync . s3://mi-bucket-ejemplo/ --size-only

# Incluir/excluir patrones
aws s3 sync . s3://mi-bucket-ejemplo/ --include "*.jpg" --exclude "*.tmp"
```
