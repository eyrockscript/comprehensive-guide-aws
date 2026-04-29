# Cheatsheet: Comandos CLI de DynamoDB

## Operaciones CRUD Básicas

### Crear Tabla

```bash
# Tabla simple con clave de partición
aws dynamodb create-table \
    --table-name Usuarios \
    --attribute-definitions AttributeName=usuario_id,AttributeType=S \
    --key-schema AttributeName=usuario_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Tabla con clave compuesta (partición + rango)
aws dynamodb create-table \
    --table-name Pedidos \
    --attribute-definitions \
        AttributeName=usuario_id,AttributeType=S \
        AttributeName=pedido_id,AttributeType=S \
    --key-schema \
        AttributeName=usuario_id,KeyType=HASH \
        AttributeName=pedido_id,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# Tabla con capacidad aprovisionada
aws dynamodb create-table \
    --table-name Productos \
    --attribute-definitions AttributeName=producto_id,AttributeType=S \
    --key-schema AttributeName=producto_id,KeyType=HASH \
    --billing-mode PROVISIONED \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Tabla con índice secundario global (GSI)
aws dynamodb create-table \
    --table-name Empleados \
    --attribute-definitions \
        AttributeName=departamento,AttributeType=S \
        AttributeName=empleado_id,AttributeType=S \
        AttributeName=email,AttributeType=S \
    --key-schema \
        AttributeName=departamento,KeyType=HASH \
        AttributeName=empleado_id,KeyType=RANGE \
    --global-secondary-indexes \
        'IndexName=EmailIndex,KeySchema=[{AttributeName=email,KeyType=HASH}],Projection={ProjectionType=ALL},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}' \
    --billing-mode PROVISIONED \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### Insertar Items

```bash
# Insertar item simple
aws dynamodb put-item \
    --table-name Usuarios \
    --item '{
        "usuario_id": {"S": "user-001"},
        "nombre": {"S": "Juan Pérez"},
        "email": {"S": "juan@ejemplo.com"},
        "edad": {"N": "30"},
        "activo": {"BOOL": true},
        "intereses": {"SS": ["tecnología", "deportes", "música"]}
    }'

# Insertar con condición (no sobrescribir si existe)
aws dynamodb put-item \
    --table-name Usuarios \
    --item '{
        "usuario_id": {"S": "user-002"},
        "nombre": {"S": "María García"}
    }' \
    --condition-expression "attribute_not_exists(usuario_id)"
```

### Obtener Items

```bash
# Get por clave primaria
aws dynamodb get-item \
    --table-name Usuarios \
    --key '{"usuario_id": {"S": "user-001"}}'

# Get con proyección (solo campos específicos)
aws dynamodb get-item \
    --table-name Usuarios \
    --key '{"usuario_id": {"S": "user-001"}}' \
    --projection-expression "nombre, email"

# Get con consistencia fuerte
aws dynamodb get-item \
    --table-name Usuarios \
    --key '{"usuario_id": {"S": "user-001"}}' \
    --consistent-read
```

### Actualizar Items

```bash
# Actualizar atributo específico
aws dynamodb update-item \
    --table-name Usuarios \
    --key '{"usuario_id": {"S": "user-001"}}' \
    --update-expression "SET edad = :edad" \
    --expression-attribute-values '{":edad": {"N": "31"}}'

# Incrementar valor numérico
aws dynamodb update-item \
    --table-name Productos \
    --key '{"producto_id": {"S": "prod-001"}}' \
    --update-expression "SET stock = stock - :cantidad" \
    --expression-attribute-values '{":cantidad": {"N": "1"}}'

# Agregar a lista
aws dynamodb update-item \
    --table-name Usuarios \
    --key '{"usuario_id": {"S": "user-001"}}' \
    --update-expression "SET intereses = list_append(intereses, :nuevo)" \
    --expression-attribute-values '{":nuevo": {"L": [{"S": "viajes"}]}}'

# Eliminar atributo
aws dynamodb update-item \
    --table-name Usuarios \
    --key '{"usuario_id": {"S": "user-001"}}' \
    --update-expression "REMOVE edad"

# Actualización condicional
aws dynamodb update-item \
    --table-name Productos \
    --key '{"producto_id": {"S": "prod-001"}}' \
    --update-expression "SET precio = :nuevo_precio" \
    --condition-expression "precio = :precio_actual" \
    --expression-attribute-values '{
        ":nuevo_precio": {"N": "99.99"},
        ":precio_actual": {"N": "120.00"}
    }'
```

### Eliminar Items

```bash
# Eliminar por clave
aws dynamodb delete-item \
    --table-name Usuarios \
    --key '{"usuario_id": {"S": "user-001"}}'

# Eliminar condicional
aws dynamodb delete-item \
    --table-name Productos \
    --key '{"producto_id": {"S": "prod-001"}}' \
    --condition-expression "stock = :stock" \
    --expression-attribute-values '{":stock": {"N": "0"}}'
```

## Consultas y Escaneos

### Query (Búsqueda por clave)

```bash
# Query por clave de partición
aws dynamodb query \
    --table-name Pedidos \
    --key-condition-expression "usuario_id = :uid" \
    --expression-attribute-values '{":uid": {"S": "user-001"}}'

# Query con rango (between)
aws dynamodb query \
    --table-name Pedidos \
    --key-condition-expression "usuario_id = :uid AND pedido_id BETWEEN :start AND :end" \
    --expression-attribute-values '{
        ":uid": {"S": "user-001"},
        ":start": {"S": "2024-01-01"},
        ":end": {"S": "2024-12-31"}
    }'

# Query con orden descendente
aws dynamodb query \
    --table-name Pedidos \
    --key-condition-expression "usuario_id = :uid" \
    --expression-attribute-values '{":uid": {"S": "user-001"}}' \
    --scan-index-forward false \
    --limit 10

# Query en índice secundario
aws dynamodb query \
    --table-name Empleados \
    --index-name EmailIndex \
    --key-condition-expression "email = :email" \
    --expression-attribute-values '{":email": {"S": "juan@empresa.com"}}'
```

### Scan (Escaneo completo)

```bash
# Scan completo
aws dynamodb scan \
    --table-name Usuarios

# Scan con filtro
aws dynamodb scan \
    --table-name Usuarios \
    --filter-expression "edad > :edad" \
    --expression-attribute-values '{":edad": {"N": "25"}}'

# Scan paginado
aws dynamodb scan \
    --table-name Usuarios \
    --limit 100

# Scan con proyección
aws dynamodb scan \
    --table-name Usuarios \
    --projection-expression "usuario_id, nombre"
```

## Batch Operations

```bash
# Batch Get
aws dynamodb batch-get-item \
    --request-items '{
        "Usuarios": {
            "Keys": [
                {"usuario_id": {"S": "user-001"}},
                {"usuario_id": {"S": "user-002"}},
                {"usuario_id": {"S": "user-003"}}
            ]
        }
    }'

# Batch Write (put + delete)
aws dynamodb batch-write-item \
    --request-items '{
        "Usuarios": [
            {
                "PutRequest": {
                    "Item": {
                        "usuario_id": {"S": "user-004"},
                        "nombre": {"S": "Carlos Ruiz"}
                    }
                }
            },
            {
                "DeleteRequest": {
                    "Key": {
                        "usuario_id": {"S": "user-005"}
                    }
                }
            }
        ]
    }'
```

## Gestión de Tablas

```bash
# Listar tablas
aws dynamodb list-tables

# Describir tabla
aws dynamodb describe-table --table-name Usuarios

# Actualizar throughput
aws dynamodb update-table \
    --table-name Productos \
    --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10

# Habilitar TTL
aws dynamodb update-time-to-live \
    --table-name Sesiones \
    --time-to-live-specification Enabled=true,AttributeName=expira_en

# Describir TTL
aws dynamodb describe-time-to-live --table-name Sesiones

# Crear índice secundario global
aws dynamodb update-table \
    --table-name Pedidos \
    --attribute-definitions AttributeName=estado,AttributeType=S \
    --global-secondary-index-updates '{
        "Create": {
            "IndexName": "EstadoIndex",
            "KeySchema": [{"AttributeName": "estado", "KeyType": "HASH"}],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {
                "ReadCapacityUnits": 5,
                "WriteCapacityUnits": 5
            }
        }
    }'

# Eliminar índice secundario
aws dynamodb update-table \
    --table-name Pedidos \
    --global-secondary-index-updates '{
        "Delete": {"IndexName": "EstadoIndex"}
    }'

# Habilitar Point-in-Time Recovery
aws dynamodb update-continuous-backups \
    --table-name Usuarios \
    --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true

# Eliminar tabla
aws dynamodb delete-table --table-name Usuarios
```

## Transacciones

```bash
# TransactWrite (múltiples operaciones atómicas)
aws dynamodb transact-write-items \
    --transact-items '{
        "TransactItems": [
            {
                "Put": {
                    "TableName": "Pedidos",
                    "Item": {
                        "usuario_id": {"S": "user-001"},
                        "pedido_id": {"S": "pedido-001"},
                        "total": {"N": "100.00"}
                    }
                }
            },
            {
                "Update": {
                    "TableName": "Productos",
                    "Key": {"producto_id": {"S": "prod-001"}},
                    "UpdateExpression": "SET stock = stock - :cantidad",
                    "ExpressionAttributeValues": {":cantidad": {"N": "1"}}
                }
            }
        ]
    }'

# TransactGet
aws dynamodb transact-get-items \
    --transact-items '{
        "TransactItems": [
            {
                "Get": {
                    "TableName": "Usuarios",
                    "Key": {"usuario_id": {"S": "user-001"}}
                }
            },
            {
                "Get": {
                    "TableName": "Pedidos",
                    "Key": {
                        "usuario_id": {"S": "user-001"},
                        "pedido_id": {"S": "pedido-001"}
                    }
                }
            }
        ]
    }'
```

## Backups y Restauración

```bash
# Crear backup bajo demanda
aws dynamodb create-backup \
    --table-name Usuarios \
    --backup-name usuarios-backup-2024

# Listar backups
aws dynamodb list-backups

# Describir backup
aws dynamodb describe-backup --backup-arn arn:aws:dynamodb:us-east-1:123456789012:table/Usuarios/backup/12345678-1234-1234-1234-123456789012

# Restaurar desde backup
aws dynamodb restore-table-from-backup \
    --target-table-name Usuarios-Restaurada \
    --backup-arn arn:aws:dynamodb:us-east-1:123456789012:table/Usuarios/backup/12345678-1234-1234-1234-123456789012

# Exportar a S3
aws dynamodb export-table-to-point-in-time \
    --table-arn arn:aws:dynamodb:us-east-1:123456789012:table/Usuarios \
    --s3-bucket mi-bucket-exports \
    --s3-prefix dynamodb/ \
    --export-format DYNAMODB_JSON

# Importar desde S3
aws dynamodb import-table \
    --s3-bucket-source S3Bucket=mi-bucket-exports,S3KeyPrefix=dynamodb/ \
    --input-format DYNAMODB_JSON \
    --table-name Usuarios-Importada
```

## Consejos Rápidos

| Tarea | Comando |
|-------|---------|
| Crear tabla | `aws dynamodb create-table --table-name <name> --attribute-definitions ... --key-schema ...` |
| Insertar item | `aws dynamodb put-item --table-name <name> --item '<json>'` |
| Obtener item | `aws dynamodb get-item --table-name <name> --key '<json>'` |
| Query | `aws dynamodb query --table-name <name> --key-condition-expression ...` |
| Scan | `aws dynamodb scan --table-name <name>` |
| Eliminar item | `aws dynamodb delete-item --table-name <name> --key '<json>'` |
| Describir tabla | `aws dynamodb describe-table --table-name <name>` |
| Listar tablas | `aws dynamodb list-tables` |

## Tips de Performance

```bash
# Usar parallel scan para grandes volúmenes
aws dynamodb scan \
    --table-name Usuarios \
    --segment 0 \
    --total-segments 4

# Query es más eficiente que Scan
# Siempre diseñar Access Patterns primero
# Usar ProjectionExpression para reducir datos transferidos
# Preferir on-demand billing para cargas variables
```
